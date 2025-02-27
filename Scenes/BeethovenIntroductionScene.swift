import SpriteKit

class BeethovenIntroductionScene: SKScene {
    private let beethoven = SKSpriteNode(imageNamed: "Beethoven1")
    private let textBox = SKShapeNode()
    private let textLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let buttonBackground = SKShapeNode()
    private let yesButton = SKLabelNode(text: "Yes!")
    
    private let messages = [
        "Hello, there! My name is Beethoven, I'm a pianist and I'll guide you through this interactive journey.",
        "Are you ready?",
        "I'm flattered to meet you.",
        "Please, come with me to my music studio and I'll show you more."
    ]
    
    override func didMove(to view: SKView) {
        scaleMode = .aspectFill
        setupBackground()
        setupBeethoven()
        setupTextBox()
        setupYesButton()
        showMessages()
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "backgroundBetIntroduction")
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
    
    private func setupYesButton() {
        let buttonWidth = size.width * 0.2
        let buttonHeight = size.height * 0.05
        
        buttonBackground.path = UIBezierPath(roundedRect: CGRect(x: -buttonWidth / 2, y: -buttonHeight / 2, width: buttonWidth, height: buttonHeight), cornerRadius: 10).cgPath
        buttonBackground.fillColor = .orange
        buttonBackground.strokeColor = .black
        buttonBackground.lineWidth = 2
        buttonBackground.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        buttonBackground.zPosition = 1
        buttonBackground.isHidden = true
        addChild(buttonBackground)
        
        yesButton.fontColor = .white
        let baseFontSize: CGFloat = 20
        yesButton.fontSize = min(size.width * 0.045, baseFontSize) 
        yesButton.fontName = "Avenir-Heavy"
        yesButton.position = CGPoint(x: 0, y: -buttonHeight * 0.2) 
        yesButton.name = "yesButton"
        yesButton.zPosition = 2
        yesButton.isHidden = true
        buttonBackground.addChild(yesButton)
    }
    
    private func showMessages() {
        var messageIndex = 0
        
        func displayNextMessage() {
            guard messageIndex < self.messages.count else {
                self.transitionToMusicStudio()
                return
            }
            
            let message = self.messages[messageIndex]
            self.startTypingAnimation(for: message) {
                if messageIndex == 1 {
                    self.buttonBackground.isHidden = false
                    self.yesButton.isHidden = false
                    self.buttonBackground.run(SKAction.fadeIn(withDuration: 0.5))
                } else if messageIndex == self.messages.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.transitionToMusicStudio()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        messageIndex += 1
                        displayNextMessage()
                    }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: completion)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "yesButton" || touchedNode == buttonBackground {
            let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let sequence = SKAction.sequence([scaleDown, scaleUp, fadeOut])
            
            buttonBackground.run(sequence) { [weak self] in
                guard let self = self else { return }
                self.buttonBackground.isHidden = true
                self.yesButton.isHidden = true
                self.showNextMessages()
            }
        }
    }
    
    private func showNextMessages() {
        let remainingMessages = Array(messages.dropFirst(2))
        var messageIndex = 0
        
        func displayNextMessage() {
            guard messageIndex < remainingMessages.count else {
                self.transitionToMusicStudio()
                return
            }
            
            let message = remainingMessages[messageIndex]
            self.startTypingAnimation(for: message) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    messageIndex += 1
                    displayNextMessage()
                }
            }
        }
        
        displayNextMessage()
    }
    
    private func transitionToMusicStudio() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let nextScene = MusicStudioScene(size: size)
        nextScene.scaleMode = .aspectFill
        view?.presentScene(nextScene, transition: transition)
    }
}
