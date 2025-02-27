import AVFoundation

class PianoSoundManager {
    static var players: [String: AVAudioPlayer] = [:]
    
    enum PitchLevel {
        case normal, low, veryLow, lower, almostGone
    }
    
    static func playSound(for note: String) {
        guard let url = Bundle.main.url(forResource: note, withExtension: "mp3") else {
            print("Sound file for \(note) not found")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.enableRate = true 
            applyCurrentPitch(to: player)
            players[note] = player
            player.play()
        } catch {
            print("Error playing sound for \(note): \(error)")
        }
    }
    
    private static var currentPitchLevel: PitchLevel = .normal
    
    static func adjustPitch(to level: PitchLevel) {
        currentPitchLevel = level
        for player in players.values {
            applyCurrentPitch(to: player)
        }
    }
    
    private static func applyCurrentPitch(to player: AVAudioPlayer) {
        switch currentPitchLevel {
        case .normal:
            player.rate = 1.0   
            player.volume = 1.0
        case .low:
            player.rate = 0.8   
            player.volume = 0.7
        case .veryLow:
            player.rate = 0.6   
            player.volume = 0.4
        case .lower:
            player.rate = 0.5   
            player.volume = 0.2
        case .almostGone:
            player.rate = 0.4  
            player.volume = 0.1
        }
    }
    
    static func resetPitch() {
        adjustPitch(to: .normal)
    }
}
