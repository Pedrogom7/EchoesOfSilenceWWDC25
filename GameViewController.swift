import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = SKView()
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.ignoresSiblingOrder = true
        view.addSubview(skView)
        

        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        

        let blackScreen = UIView()
        blackScreen.backgroundColor = .black
        blackScreen.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blackScreen)
        
        NSLayoutConstraint.activate([
            blackScreen.topAnchor.constraint(equalTo: view.topAnchor),
            blackScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blackScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            blackScreen.removeFromSuperview()
            let scene = BeethovenIntroductionScene(size: skView.bounds.size)
            scene.scaleMode = .resizeFill 
            skView.presentScene(scene)
        }
    }
}
