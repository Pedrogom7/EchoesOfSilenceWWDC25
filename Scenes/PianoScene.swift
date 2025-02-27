import SpriteKit

class PianoScene: SKScene {
    private var pianoKeys: [SKSpriteNode] = []
    private let learnButton = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let beethoven = SKSpriteNode(imageNamed: "Beethoven1")
    private let textBox = SKShapeNode()
    private let textLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let yesButton = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let noButton = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let yesBackground = SKShapeNode()
    private let noBackground = SKShapeNode()
    
    private var tutorialActive = false
    private var tutorialNotes: [String] = []
    private var currentNoteIndex = 0
    private var mistakes = 0
    
    override func didMove(to view: SKView) {
        scaleMode = .aspectFill
        setupPiano()
        setupBeethoven()
        setupTextBox()
        setupChoiceButtons()
        setupLearnButton()
        showBeethovenDialogue() 
    }
    
    private func setupPiano() {
        let whiteNotes: [String] = ["C", "D", "E", "F", "G", "A", "B", "C2", "D2", "E2"]
        let blackNotes: [String] = ["C#", "D#", "F#", "G#", "A#", "C#2", "D#2"]
        let blackKeyPositions: Set<Int> = [0, 1, 3, 4, 5, 7, 8]
        
        let whiteKeyWidth = size.width / 10
        let blackKeyWidth = whiteKeyWidth * 0.6
        
        for (index, note) in whiteNotes.enumerated() {
            let key = PianoKey.createWhiteKey(note: note, index: index, width: whiteKeyWidth, scene: self)
            key.name = note
            pianoKeys.append(key)
        }
        
        var blackIndex = 0
        for index in 0..<whiteNotes.count {
            if blackKeyPositions.contains(index) {
                let note = blackNotes[blackIndex]
                let key = PianoKey.createBlackKey(note: note, index: index, whiteKeyWidth: whiteKeyWidth, blackKeyWidth: blackKeyWidth, scene: self)
                key.name = note
                pianoKeys.append(key)
                blackIndex += 1
            }
        }
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
        beethoven.position = CGPoint(x: size.width * 0.20, y: size.height * 0.77)
        beethoven.anchorPoint = CGPoint(x: 0.5, y: 0)
        beethoven.zPosition = 2
        beethoven.alpha = 0
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
        textBox.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
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
    
    private func setupLearnButton() {
        learnButton.text = "Learn a Song"
        let baseFontSize: CGFloat = 20
        learnButton.fontSize = min(size.width * 0.045, baseFontSize)
        learnButton.fontColor = .white
        learnButton.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        learnButton.name = "learnButton"
        learnButton.alpha = 0
        learnButton.zPosition = 2
        addChild(learnButton)
        
        let buttonWidth = size.width * 0.25
        let buttonHeight = size.height * 0.05
        let learnBackground = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        learnBackground.fillColor = .orange
        learnBackground.strokeColor = .black
        learnBackground.lineWidth = 2
        learnBackground.position = learnButton.position
        learnBackground.zPosition = 1
        learnBackground.alpha = 0
        addChild(learnBackground)
        
        learnButton.userData = NSMutableDictionary()
        learnButton.userData?.setValue(learnBackground, forKey: "background")
    }
    
    private func showLearnButton() {
        learnButton.run(SKAction.fadeIn(withDuration: 1.0))
        if let background = learnButton.userData?["background"] as? SKShapeNode {
            background.run(SKAction.fadeIn(withDuration: 1.0))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        if let topNode = nodesAtPoint.first(where: { $0.name == "learnButton" }) {
            topNode.run(sequence) { self.startTutorial() }
        } else if let topNode = nodesAtPoint.first(where: { $0.name == "yesButton" }) {
            topNode.run(sequence) { self.proceedToNextPhase() }
        } else if let topNode = nodesAtPoint.first(where: { $0.name == "noButton" }) {
            topNode.run(sequence) { self.restartTutorial() }
        } else if let keyNode = nodesAtPoint.first(where: { $0.name != nil }) {
            handleKeyPress(keyNode)
        }
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
    
    private func showBeethovenDialogue() {
        let messages: [String] = [
            "Ahhh. Welcome",
            "I see you have found the most marvelous instrument of them all",
            "The piano",
            "This instrument can hold up to 88 keys",
            "Each key is a doorway to endless melodies",
            "Every key has a whole scale to play. It's an infinite world to be explored.",
            "With those keys, you can express joy, sorrow, passion...",
            "Go on. Press a key.",
            "Listen closely - music is all around you",
            "Feel free to explore the Piano and it sounds how you want. After, I'll teach you a very special song to me!",
        ]
        
        showMessages(messages) { [weak self] in
            self?.showLearnButton()
        }
    }
    
    private func showMessages(_ messages: [String], completion: @escaping () -> Void) {
        func showNextMessage(index: Int) {
            if index < messages.count {
                startTypingAnimation(for: messages[index]) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showNextMessage(index: index + 1)
                    }
                }
            } else {
                completion()
            }
        }
        showNextMessage(index: 0)
    }
    
    private func startTutorial() {
        tutorialActive = true
        tutorialNotes = ["E2", "D#2", "E2", "D#2", "E2", "B", "D2", "C2", "A", "C", "E", "A", "B", "E", "G#", "B", "C2", "E", "E2", "D#2", "E2", "D#2", "E2", "B", "D2", "C2", "A", "C", "E", "A", "B", "E", "C2", "B", "A"]
        currentNoteIndex = 0
        mistakes = 0
        
        let messages = [
            "Let's try to play a song.",
            "This is a song I wrote in 1810, called *For Elise*.",
            "I'll highlight the keys you need to play."
        ]
        
        learnButton.run(SKAction.fadeOut(withDuration: 0.5))
        if let background = learnButton.userData?["background"] as? SKShapeNode {
            background.run(SKAction.fadeOut(withDuration: 0.5))
        }
        
        showMessages(messages) { [weak self] in
            self?.highlightCurrentNote()
        }
    }
    
    private func handleKeyPress(_ keyNode: SKNode) {
        let note = keyNode.name ?? ""
        PianoSoundManager.playSound(for: note)
        
        guard let spriteNode = keyNode as? SKSpriteNode else { return }
        
        if tutorialActive {
            guard currentNoteIndex < tutorialNotes.count else { return }
            if note == tutorialNotes[currentNoteIndex] {
                let isBlackKey = note.contains("#")
                let originalColor: UIColor = isBlackKey ? .black : .white
                
                if isBlackKey {
                    spriteNode.color = UIColor.green
                    spriteNode.colorBlendFactor = 1.0
                } else if let shapeNode = spriteNode.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                    shapeNode.fillColor = UIColor.green
                }
                
                spriteNode.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.2),
                    SKAction.run {
                        if isBlackKey {
                            spriteNode.color = originalColor
                        } else if let shapeNode = spriteNode.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                            shapeNode.fillColor = originalColor
                        }
                    }
                ]))
                
                currentNoteIndex += 1
                if currentNoteIndex < tutorialNotes.count {
                    highlightCurrentNote()
                } else {
                    endTutorial()
                }
            } else {
                mistakes += 1
                if note.contains("#") {
                    spriteNode.color = UIColor.red
                    spriteNode.colorBlendFactor = 1.0
                } else if let shapeNode = spriteNode.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                    shapeNode.fillColor = UIColor.red
                }
                
                spriteNode.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.2),
                    SKAction.run {
                        let isBlackKey = note.contains("#")
                        if isBlackKey {
                            spriteNode.color = isBlackKey ? .black : .white
                        } else if let shapeNode = spriteNode.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                            shapeNode.fillColor = isBlackKey ? .black : .white
                        }
                    }
                ]))
            }
        }
    }
    
    private func highlightCurrentNote() {
        for key in pianoKeys {
            let isBlackKey = key.name?.contains("#") ?? false
            if isBlackKey {
                key.color = .black
                key.colorBlendFactor = 1.0
            } else if let shapeNode = key.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                shapeNode.fillColor = .white
            }
        }
        
        if currentNoteIndex >= tutorialNotes.count {
            endTutorial()
            return
        }
        
        let targetNote = tutorialNotes[currentNoteIndex]
        for key in pianoKeys {
            if key.name == targetNote {
                let isBlackKey = targetNote.contains("#")
                if isBlackKey {
                    key.color = .orange
                    key.colorBlendFactor = 1.0
                } else if let shapeNode = key.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                    shapeNode.fillColor = .orange
                }
            }
        }
    }
    
    private func restartTutorial() {
        yesButton.run(SKAction.fadeOut(withDuration: 0.5))
        noButton.run(SKAction.fadeOut(withDuration: 0.5))
        yesBackground.run(SKAction.fadeOut(withDuration: 0.5))
        noBackground.run(SKAction.fadeOut(withDuration: 0.5))
        
        let messages = ["Alright, let’s practice one more time!"]
        showMessages(messages) { [weak self] in
            self?.startTutorial()
        }
    }
    
    private func endTutorial() {
        tutorialActive = false
        
        let messages: [String]
        if mistakes <= 5 {
            messages = [
                "Wow! You’re such a great pianist.",
                "I think you are ready to perform this song.",
                "Let's go to the Steve Jobs Theater, and perform this song to the world!",
                "Do you feel ready?"
            ]
            showMessages(messages) { [weak self] in
                self?.showChoiceButtons()
            }
        } else {
            messages = [
                "Wow. You are getting better at this",
                "We should practice this song a little bit more."
            ]
            showMessages(messages) { [weak self] in
                self?.restartTutorial()
            }
        }
    }
    
    private func setupChoiceButtons() {
        let buttonWidth = size.width * 0.25
        let buttonHeight = size.height * 0.05
        
        yesBackground.path = UIBezierPath(roundedRect: CGRect(x: -buttonWidth / 2, y: -buttonHeight / 2, width: buttonWidth, height: buttonHeight), cornerRadius: 10).cgPath
        yesBackground.fillColor = .orange
        yesBackground.strokeColor = .black
        yesBackground.lineWidth = 2
        yesBackground.position = CGPoint(x: size.width / 2, y: size.height * 0.59)
        yesBackground.zPosition = 2
        yesBackground.alpha = 0
        addChild(yesBackground)
        
        yesButton.text = "Yes! Let's do it!"
        let baseFontSize: CGFloat = 20
        yesButton.fontSize = min(size.width * 0.045, baseFontSize)
        yesButton.fontColor = .white
        yesButton.position = CGPoint(x: size.width / 2, y: size.height * 0.59)
        yesButton.name = "yesButton"
        yesButton.alpha = 0
        yesButton.zPosition = 3
        addChild(yesButton)
        
        noBackground.path = UIBezierPath(roundedRect: CGRect(x: -buttonWidth / 2, y: -buttonHeight / 2, width: buttonWidth, height: buttonHeight), cornerRadius: 10).cgPath
        noBackground.fillColor = .orange
        noBackground.strokeColor = .black
        noBackground.lineWidth = 2
        noBackground.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        noBackground.zPosition = 2
        noBackground.alpha = 0
        addChild(noBackground)
        
        noButton.text = "No! Let's practice again!"
        noButton.fontSize = min(size.width * 0.045, baseFontSize)
        noButton.fontColor = .white
        noButton.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        noButton.name = "noButton"
        noButton.alpha = 0
        noButton.zPosition = 3
        addChild(noButton)
    }
    
    private func showChoiceButtons() {
        yesBackground.run(SKAction.fadeIn(withDuration: 0.5))
        yesButton.run(SKAction.fadeIn(withDuration: 0.5))
        noBackground.run(SKAction.fadeIn(withDuration: 0.5))
        noButton.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    private func proceedToNextPhase() {
        yesButton.run(SKAction.fadeOut(withDuration: 0.5))
        noButton.run(SKAction.fadeOut(withDuration: 0.5))
        yesBackground.run(SKAction.fadeOut(withDuration: 0.5))
        noBackground.run(SKAction.fadeOut(withDuration: 0.5))
        
        let messages = ["Great! Let’s head to the Theater!"]
        showMessages(messages) { [weak self] in
            guard let self = self else { return }
            let performanceScene = PerformanceScene(size: self.size)
            performanceScene.scaleMode = .aspectFill
            self.view?.presentScene(performanceScene, transition: SKTransition.fade(withDuration: 1.0))
        }
    }
}
