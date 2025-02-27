import UIKit
import ARKit
import AVFoundation

class ARPianoScene: UIViewController, ARSCNViewDelegate {
    private var sceneView: ARSCNView!
    private let pianoModelName = "Piano.usdz"
    private var coachingOverlay: ARCoachingOverlayView!
    private var moveDeviceLabel: UILabel!
    private var tapToPlaceLabel: UILabel!
    private var planeDetected = false
    private var pianoPlaced = false
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupCoachingOverlay()
        setupInstructionLabels()
        setupBackButton()
        setupAudio()
        startARSession()
        print("🎹 ARPianoScene Loaded Successfully!")
    }
    
    private func setupSceneView() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true 
        sceneView.scene = SCNScene()
        view.addSubview(sceneView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    private func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic 
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        print("🔹 AR Session started")
    }
    
    private func setupCoachingOverlay() {
        coachingOverlay = ARCoachingOverlayView(frame: view.bounds)
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            coachingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            coachingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coachingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupInstructionLabels() {
        moveDeviceLabel = UILabel()
        moveDeviceLabel.translatesAutoresizingMaskIntoConstraints = false
        moveDeviceLabel.text = "Move your device to find a surface"
        moveDeviceLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        moveDeviceLabel.textColor = .white
        moveDeviceLabel.textAlignment = .center
        moveDeviceLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        moveDeviceLabel.layer.cornerRadius = 12
        moveDeviceLabel.clipsToBounds = true
        view.addSubview(moveDeviceLabel)
        
        tapToPlaceLabel = UILabel()
        tapToPlaceLabel.translatesAutoresizingMaskIntoConstraints = false
        tapToPlaceLabel.text = "Tap to place the piano"
        tapToPlaceLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        tapToPlaceLabel.textColor = .white
        tapToPlaceLabel.textAlignment = .center
        tapToPlaceLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        tapToPlaceLabel.layer.cornerRadius = 12
        tapToPlaceLabel.clipsToBounds = true
        tapToPlaceLabel.isHidden = true
        view.addSubview(tapToPlaceLabel)
        
        NSLayoutConstraint.activate([
            moveDeviceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moveDeviceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            moveDeviceLabel.widthAnchor.constraint(equalToConstant: 280),
            moveDeviceLabel.heightAnchor.constraint(equalToConstant: 50),
            
            tapToPlaceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tapToPlaceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
            tapToPlaceLabel.widthAnchor.constraint(equalToConstant: 220),
            tapToPlaceLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "pianoChord", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.5
            audioPlayer?.prepareToPlay()
        } catch {
            print("⚠️ Failed to load piano chord sound: \(error)")
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard planeDetected, !pianoPlaced else {
            if !planeDetected { print("⚠️ Wait for a plane to be detected.") }
            return
        }
        
        let location = sender.location(in: sceneView)
        guard let query = sceneView.raycastQuery(from: location, allowing: .existingPlaneInfinite, alignment: .horizontal),
              let result = sceneView.session.raycast(query).first else {
            print("⚠️ No plane detected at tap location.")
            return
        }
        
        placePiano(on: result)
    }
    
    private func placePiano(on hitResult: ARRaycastResult) {
        guard let pianoScene = try? SCNScene(named: pianoModelName) else {
            print("⚠️ Failed to load \(pianoModelName).")
            return
        }
        
        let pianoNode = pianoScene.rootNode.clone()
        
        pianoNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                 hitResult.worldTransform.columns.3.y + 0.4, 
                                 hitResult.worldTransform.columns.3.z)
        pianoNode.position = position
        
        let anchor = ARAnchor(transform: hitResult.worldTransform)
        sceneView.session.add(anchor: anchor)
        sceneView.scene.rootNode.addChildNode(pianoNode)
        
        pianoNode.opacity = 0
        let animation = SCNAction.sequence([
            SCNAction.fadeIn(duration: 0.5),
            SCNAction.move(by: SCNVector3(0, 0.05, 0), duration: 0.3),
            SCNAction.move(by: SCNVector3(0, -0.05, 0), duration: 0.3)
        ])
        pianoNode.runAction(animation)
        
        audioPlayer?.play()
        
        pianoPlaced = true
        coachingOverlay.setActive(false, animated: true)
        tapToPlaceLabel.runFadeOut()
        
        print("🎹 Piano placed at \(pianoNode.position)")
    }
    
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back to Studio", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backButton.layer.cornerRadius = 10
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backToStudio), for: .touchUpInside)
        
        backButton.addTarget(self, action: #selector(buttonHighlighted), for: .touchDown)
        backButton.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside])
        
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.widthAnchor.constraint(equalToConstant: 150),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func buttonHighlighted() {
        UIView.animate(withDuration: 0.2) {
            self.view.subviews.last?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.2) {
            self.view.subviews.last?.transform = .identity
        }
    }
    
    @objc private func backToStudio() {
        sceneView.session.pause()
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("ARSceneDismissed"), object: nil)
        }
        print("🔙 Returning to Studio")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        print("🛑 AR Session paused")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor, !planeDetected else { return }
        planeDetected = true
        DispatchQueue.main.async { [weak self] in
            self?.moveDeviceLabel.runFadeOut()
            self?.tapToPlaceLabel.isHidden = false
            self?.tapToPlaceLabel.alpha = 0
            self?.tapToPlaceLabel.runFadeIn()
        }
        print("✅ Horizontal plane detected")
    }
}

extension ARPianoScene: ARCoachingOverlayViewDelegate {
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("✅ Coaching overlay deactivated")
    }
}

extension UIView {
    func runFadeIn(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }
    
    func runFadeOut(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
}
