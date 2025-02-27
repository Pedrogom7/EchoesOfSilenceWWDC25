import SpriteKit

class TextAnimator {
    static func animateText(_ messages: [String], label: SKLabelNode, completion: @escaping () -> Void) {
        var index = 0
        
        func showNextMessage() {
            if index < messages.count {
                startTypingAnimation(for: messages[index], label: label) {
                    index += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showNextMessage()
                    }
                }
            } else {
                completion()
            }
        }
        
        showNextMessage()
    }
    
    private static func startTypingAnimation(for text: String, label: SKLabelNode, completion: @escaping () -> Void) {
        var currentText = ""
        var typingIndex = 0
        
        let typingTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { timer in
            if typingIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: typingIndex)
                currentText.append(text[index])
                label.text = currentText
                typingIndex += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: completion)
            }
        }
    }
}
