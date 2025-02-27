import SpriteKit
import ARKit
import UIKit

class MusicStudioScene: SKScene {
    private let beethoven = SKSpriteNode(imageNamed: "Beethoven1")
    private let textBox = SKShapeNode()
    private let textLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let pianoBox = SKShapeNode()
    private let pianoImage = SKSpriteNode(imageNamed: "PianoImage")
    private let arButtonBox = SKShapeNode()
    private let arButton = SKLabelNode(text: "View Piano in AR")
    private let noThanksButton = SKLabelNode(text: "No, thanks!")
    private let playButton = SKLabelNode(text: "Play Piano!")
    
    private let messages = [
        "Welcome to my studio.",
        "This is a piano! It has white keys and black keys, flats and sharps.",
        "But we don't need to enter this concept right now!",
        "Let's start from the beginning.",
        "If you want to, you can experience a real piano in your room. Wanna try it out?"
    ]
    
    override func didMove(to view: SKView) {
        scaleMode = .aspectFill
        setupBackground()
        setupBeethoven()
        setupTextBox()
        setupPianoBox()
        setupButtons()
        showMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleARSceneDismissed), name: NSNotification.Name("ARSceneDismissed"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "backgroundMusicStudio")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -1
        addChild(background)
    }
    
    private func setupBeethoven() {
        let maxWidth = size.width * 0.25
        let maxHeight = size.height * 0.25
        let aspectRatio = beethoven.size.width / beethoven.size.height
        
        var finalWidth = maxWidth
        var finalHeight = maxWidth / aspectRatio
        if finalHeight > maxHeight {
            finalHeight = maxHeight
            finalWidth = maxHeight * aspectRatio
        }
        
        beethoven.size = CGSize(width: finalWidth, height: finalHeight)
        beethoven.position = CGPoint(x: size.width * 0.25, y: size.height * 0.25)
        beethoven.anchorPoint = CGPoint(x: 0.5, y: 0)
        beethoven.zPosition = 2
        addChild(beethoven)
        beethoven.run(SKAction.fadeIn(withDuration: 1.0))
    }
    
    private func setupTextBox() {
        let boxWidth = size.width * 0.75
        let boxHeight = size.height * 0.2
        
        textBox.path = UIBezierPath(roundedRect: CGRect(x: -boxWidth / 2, y: -boxHeight / 2, width: boxWidth, height: boxHeight), cornerRadius: 20).cgPath
        textBox.fillColor = UIColor(white: 1, alpha: 0.8)
        textBox.strokeColor = .black
        textBox.lineWidth = 4
        textBox.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        textBox.zPosition = 1
        addChild(textBox)
        
        textLabel.fontColor = .black
        let baseFontSize: CGFloat = 20
        let fontSize = min(size.width * 0.045, baseFontSize)
        textLabel.fontSize = fontSize
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = boxWidth - (fontSize * 2)
        textLabel.verticalAlignmentMode = .center
        textLabel.horizontalAlignmentMode = .center
        textLabel.position = CGPoint.zero
        textLabel.zPosition = 1
        textBox.addChild(textLabel)
    }
    
    private func setupPianoBox() {
        let boxSize = size.width * 0.25 
        pianoBox.path = UIBezierPath(roundedRect: CGRect(x: -boxSize / 2, y: -boxSize / 2, width: boxSize, height: boxSize), cornerRadius: 20).cgPath
        pianoBox.fillColor = UIColor(white: 1, alpha: 0.8) 
        pianoBox.strokeColor = .black
        pianoBox.lineWidth = 4 
        pianoBox.position = CGPoint(x: size.width / 2, y: size.height * 0.65) 
        pianoBox.zPosition = 1
        pianoBox.isHidden = true
        addChild(pianoBox)
        
        let imageSize = boxSize * 0.9
        pianoImage.size = CGSize(width: imageSize * 1.3, height: imageSize)
        pianoImage.position = CGPoint.zero
        pianoImage.zPosition = 2
        pianoBox.addChild(pianoImage)
    }
    
    private func setupButtons() {
        let buttonWidth = size.width * 0.25
        let buttonHeight = size.height * 0.05
        
        arButtonBox.path = UIBezierPath(roundedRect: CGRect(x: -buttonWidth / 2, y: -buttonHeight / 2, width: buttonWidth, height: buttonHeight), cornerRadius: 10).cgPath
        arButtonBox.fillColor = .orange
        arButtonBox.strokeColor = .black
        arButtonBox.lineWidth = 2
        arButtonBox.position = CGPoint(x: size.width / 2, y: size.height * 0.40)
        arButtonBox.zPosition = 1
        arButtonBox.isHidden = true
        addChild(arButtonBox)
        
        arButton.fontSize = textLabel.fontSize
        arButton.fontColor = .white
        arButton.fontName = "Avenir-Heavy"
        arButton.position = CGPoint(x: 0, y: -buttonHeight * 0.2)
        arButton.name = "arButton"
        arButtonBox.addChild(arButton)
        
        noThanksButton.fontSize = textLabel.fontSize
        noThanksButton.fontName = "Avenir-Heavy"
        noThanksButton.fontColor = .white
        noThanksButton.position = CGPoint(x: size.width / 2, y: size.height * 0.33)
        noThanksButton.name = "noThanksButton"
        noThanksButton.isHidden = true
        addChild(noThanksButton)
        
        playButton.fontSize = textLabel.fontSize
        playButton.fontName = "Avenir-Heavy"
        playButton.fontColor = .white
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.33)
        playButton.name = "playButton"
        playButton.isHidden = true
        addChild(playButton)
    }
    
    private func showMessages() {
        var messageIndex = 0
        
        func displayNextMessage() {
            guard messageIndex < self.messages.count else {
                self.arButtonBox.isHidden = false
                self.noThanksButton.isHidden = false
                self.arButtonBox.run(SKAction.fadeIn(withDuration: 0.5))
                self.noThanksButton.run(SKAction.fadeIn(withDuration: 0.5))
                return
            }
            
            let message = self.messages[messageIndex]
            self.startTypingAnimation(for: message) {
                if messageIndex == 0 {
                    self.pianoBox.isHidden = false
                    self.pianoBox.run(SKAction.fadeIn(withDuration: 0.5))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    messageIndex += 1
                    displayNextMessage()
                }
            }
        }
        
        displayNextMessage()
    }
    
    private func startTypingAnimation(for text: String, completion: @escaping () -> Void) {
        textLabel.text = ""
        let characters = Array(text)
        var charIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            
            if charIndex < characters.count {
                textLabel.text?.append(characters[charIndex])
                charIndex += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: completion)
            }
        }
    }
    
    private func switchToPlayPianoButton() {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let sequence = SKAction.sequence([scaleDown, scaleUp, fadeOut])
        
        noThanksButton.run(sequence) { self.noThanksButton.removeFromParent() }
        arButtonBox.run(sequence) { self.arButtonBox.removeFromParent() }
        
        startTypingAnimation(for: "Now that you know what a piano is, let's try to play it.") { [weak self] in
            guard let self = self else { return }
            if self.playButton.parent == nil { 
                self.addChild(self.playButton)
            }
            self.playButton.isHidden = false
            self.playButton.zPosition = 1 
            self.playButton.run(SKAction.fadeIn(withDuration: 0.5))
        }
    }
    
    @objc private func handleARSceneDismissed() {
        switchToPlayPianoButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
        
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        if node.name == "arButton" || node == arButtonBox {
            arButtonBox.run(sequence) { self.transitionToARExperience() }
        } else if node.name == "noThanksButton" {
            noThanksButton.run(sequence) { self.switchToPlayPianoButton() }
        } else if node.name == "playButton" {
            playButton.run(sequence) { self.transitionToPianoScene() }
        }
    }
    
    private func transitionToARExperience() {
        guard let viewController = view?.window?.rootViewController else {
            print("❌ Unable to find rootViewController")
            return
        }
        
        DispatchQueue.main.async {
            if let topVC = self.getTopViewController() {
                let arPianoVC = ARPianoScene()
                arPianoVC.modalPresentationStyle = .fullScreen
                topVC.present(arPianoVC, animated: true) {
                    print("✅ AR Scene Presented Successfully!")
                }
            }
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        var topVC = UIApplication.shared.windows.first?.rootViewController
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
    
    private func transitionToPianoScene() {
        let pianoScene = PianoScene(size: size)
        pianoScene.scaleMode = .aspectFill
        view?.presentScene(pianoScene, transition: SKTransition.fade(withDuration: 1.0))
    }
}
