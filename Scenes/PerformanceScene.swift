import SpriteKit
import AVFoundation
import UIKit

class PerformanceScene: SKScene {
    private let background = SKSpriteNode(imageNamed: "backgroundSteveJobsTheater")
    private let beethoven = SKSpriteNode(imageNamed: "Beethoven1")
    private let textBox = SKShapeNode()
    private let textLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let playButton = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let playButtonBackground = SKShapeNode()
    private var pianoKeys: [SKSpriteNode] = []
    private var tutorialNotes: [String] = []
    private var currentNoteIndex = 0
    private var mistakes = 0
    private var audioPlayer: AVAudioPlayer?
    private var isPerforming = false
    
    override func didMove(to view: SKView) {
        scaleMode = .aspectFill
        setupBackground()
        setupBeethoven()
        setupTextBox()
        setupPlayButton()
        showInitialDialogue()
    }
    
    private func setupBackground() {
        background.size = size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 0
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
    
    private func setupPlayButton() {
        let buttonWidth = size.width * 0.25
        let buttonHeight = size.height * 0.05
        
        playButtonBackground.path = UIBezierPath(roundedRect: CGRect(x: -buttonWidth / 2, y: -buttonHeight / 2, width: buttonWidth, height: buttonHeight), cornerRadius: 10).cgPath
        playButtonBackground.fillColor = .orange
        playButtonBackground.strokeColor = .black
        playButtonBackground.lineWidth = 2
        playButtonBackground.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        playButtonBackground.zPosition = 1
        playButtonBackground.alpha = 0
        addChild(playButtonBackground)
        
        playButton.text = "Play Piano"
        let baseFontSize: CGFloat = 20
        playButton.fontSize = min(size.width * 0.045, baseFontSize)
        playButton.fontColor = .white
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        playButton.name = "playButton"
        playButton.alpha = 0
        playButton.zPosition = 2
        addChild(playButton)
    }
    
    private func showInitialDialogue() {
        let messages: [String] = [
            "Welcome to the Steve Jobs Theater.",
            "Ah... This grand hall. Created in honor of a man dared to change the world",
            "Innovation. Art. Passion",
            "This theater stands to a man much like composers of old, crafted something timeless",
            "And tonight you add your name to this history too!",
            "Our friend Steve once said: ‘The people who are crazy enough to think they can change the world are the ones who do.",
            "And music is no different, my friend.",
            "Take a deep breath",
            "Feel the weight of history in your fingers...",
            "Now, let the music flow"
        ]
        playCrowdSound()
        showMessages(messages) { [weak self] in
            self?.playButtonBackground.run(SKAction.fadeIn(withDuration: 0.5))
            self?.playButton.run(SKAction.fadeIn(withDuration: 0.5))
        }
    }
    
    private func playCrowdSound() {
        guard let url = Bundle.main.url(forResource: "crowdCheering", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.audioPlayer?.stop()
            }
        } catch {
            print("Error playing crowd sound: \(error)")
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
    
    private func setupPiano() {
        background.run(SKAction.setTexture(SKTexture(imageNamed: "backgroundPerformanceView")))
        playButtonBackground.run(SKAction.fadeOut(withDuration: 0.5))
        playButton.run(SKAction.fadeOut(withDuration: 0.5))
        
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
        
        let singleFurElise: [String] = ["E2", "D#2", "E2", "D#2", "E2", "B", "D2", "C2", "A", "C", "E", "A", "B", "E", "G#", "B", "C2", "E", "E2", "D#2", "E2", "D#2", "E2", "B", "D2", "C2", "A", "C", "E", "A", "B", "E", "C2", "B", "A"]
        tutorialNotes = singleFurElise + singleFurElise
        currentNoteIndex = 0
        mistakes = 0
        isPerforming = true
        highlightCurrentNote()
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
            endPerformance()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.15)
        let scaleSettle = SKAction.scale(to: 1.0, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let playAnimation = SKAction.sequence([
            scaleDown,
            scaleUp,
            scaleSettle,
            fadeOut,
            SKAction.run { self.setupPiano() }
        ])
        
        if let topNode = nodesAtPoint.first(where: { $0.name == "playButton" }) {
            topNode.run(playAnimation)
            if let background = playButtonBackground.parent == self ? playButtonBackground : nil {
                background.run(playAnimation)
            }
        } else if isPerforming, let keyNode = nodesAtPoint.first(where: { $0.name != nil }) {
            handleKeyPress(keyNode)
        }
    }
    
    private func handleKeyPress(_ keyNode: SKNode) {
        let note = keyNode.name ?? ""
        PianoSoundManager.playSound(for: note)
        
        guard let spriteNode = keyNode as? SKSpriteNode else { return }
        
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
            
            if currentNoteIndex == tutorialNotes.count / 4 { 
                PianoSoundManager.adjustPitch(to: .low)
                showBeethovenMidPerformanceDialogue()
            } else if currentNoteIndex == tutorialNotes.count / 2 {
                PianoSoundManager.adjustPitch(to: .veryLow)
                startHapticFeedback()
            } else if currentNoteIndex == tutorialNotes.count * 3 / 4 { 
                PianoSoundManager.adjustPitch(to: .lower)
            } else if currentNoteIndex == tutorialNotes.count * 9 / 10 {
                PianoSoundManager.adjustPitch(to: .almostGone)
            }
            
            if currentNoteIndex < tutorialNotes.count {
                highlightCurrentNote()
            } else {
                endPerformance()
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
    
    private func showBeethovenMidPerformanceDialogue() {
        let messages = [
            "Whoa! That’s strange.",
            "We must be tired. But don’t stop playing.",
            "I'll ask haptic feedback to help you!",
            "We're in this together"
        ]
        showMessages(messages) {}
    }
    
    private func startHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        
        let hapticAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { generator.impactOccurred() },
                SKAction.wait(forDuration: 0.3)
            ])
        )
        run(hapticAction, withKey: "hapticFeedback")
    }
    
    private func endPerformance() {
        isPerforming = false
        removeAction(forKey: "hapticFeedback")
        PianoSoundManager.resetPitch()
        
        let messages = ["Well done, my friend! We got it!"]
        showMessages(messages) { [weak self] in
            guard let self = self else { return }
            let endScene = EndScene(size: self.size)
            endScene.scaleMode = .aspectFill
            self.view?.presentScene(endScene, transition: SKTransition.crossFade(withDuration: 1.5))
        }
    }
}
