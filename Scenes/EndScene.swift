import SpriteKit

class EndScene: SKScene {
    private let textLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    
    override func didMove(to view: SKView) {
        scaleMode = .aspectFill
        backgroundColor = .black
        setupTextLabel()
        showMessages()
    }
    
    private func setupTextLabel() {
        textLabel.fontColor = .white
        let baseFontSize: CGFloat = 20
        textLabel.fontSize = min(size.width * 0.045, baseFontSize)
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = size.width * 0.8
        textLabel.verticalAlignmentMode = .center
        textLabel.horizontalAlignmentMode = .center
        textLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        textLabel.zPosition = 1
        addChild(textLabel)
    }
    
    private func showMessages() {
        let messages: [String] = [
            "You just experienced a glimpse of what Beethoven did!",
            "Becoming deaf didn’t stop him from doing what he loved!",
            "Music has no limits, no barriers.",
            "It is not only to be heard, but also to be lived and felt!",
            "Even today, many deaf musicians continue to create music that touches the world."
        ]
        
        showMessagesSequentially(messages) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self?.transitionToHomeScene()
            }
        }
    }
    
    private func showMessagesSequentially(_ messages: [String], completion: @escaping () -> Void) {
        func showNextMessage(index: Int) {
            if index < messages.count {
                startTypingAnimation(for: messages[index]) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showNextMessage(index: index + 1)
                    }
                }
            } else {
                completion()
            }
        }
        showNextMessage(index: 0)
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
    
    private func transitionToHomeScene() {
        NotificationCenter.default.post(name: NSNotification.Name("ReturnToHomeScene"), object: nil)
    }
}
