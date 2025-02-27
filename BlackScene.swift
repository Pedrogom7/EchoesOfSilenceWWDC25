import SpriteKit

class BlackScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.7),
            SKAction.run {
                let scene = BeethovenIntroductionScene(size: self.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1))
            }
        ]))
    }
}
