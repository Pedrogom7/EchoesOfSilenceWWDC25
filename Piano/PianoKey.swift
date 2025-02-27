import SpriteKit

class PianoKey {
    static func createWhiteKey(note: String, index: Int, width: CGFloat, scene: SKScene) -> SKSpriteNode {
        let keyHeight = scene.size.height * 0.4
        let keyPosition = CGPoint(x: CGFloat(index) * width + width / 2, y: scene.size.height * 0.2)
        
        let keyContainer = SKSpriteNode(color: .clear, size: CGSize(width: width, height: keyHeight))
        keyContainer.position = keyPosition
        keyContainer.name = note
        keyContainer.zPosition = 2
        
        let keyShape = SKShapeNode(rectOf: CGSize(width: width, height: keyHeight), cornerRadius: 3)
        keyShape.fillColor = .white
        keyShape.strokeColor = .black
        keyShape.lineWidth = 2
        keyContainer.addChild(keyShape)
        
        let label = SKLabelNode(text: note)
        label.fontName = "Avenir-Heavy"
        label.fontSize = 20
        label.fontColor = .black
        label.position = CGPoint(x: 0, y: -keyHeight / 2 + 20)
        label.zPosition = 3
        keyContainer.addChild(label)
        
        scene.addChild(keyContainer)
        return keyContainer
    }
    
    static func createBlackKey(note: String, index: Int, whiteKeyWidth: CGFloat, blackKeyWidth: CGFloat, scene: SKScene) -> SKSpriteNode {
        let blackKeyHeight = scene.size.height * 0.25  
        let blackKey = SKSpriteNode(color: .black, size: CGSize(width: blackKeyWidth, height: blackKeyHeight))
        
        blackKey.anchorPoint = CGPoint(x: 0.5, y: 1) 
        
        let xPosition = (CGFloat(index) + 1) * whiteKeyWidth  
       
        let yPosition = scene.size.height * 0.4 
        
        blackKey.position = CGPoint(x: xPosition, y: yPosition)
        blackKey.zPosition = 2
        blackKey.name = note
        scene.addChild(blackKey)
        
        return blackKey
    }
}
