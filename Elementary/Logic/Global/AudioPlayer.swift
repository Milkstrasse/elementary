//
//  AudioPlayer.swift
//  Elementary
//
//  Created by Janice Hablützel on 27.01.22.
//

import AVFoundation

/// Plays audio files.
class AudioPlayer {
    static let shared: AudioPlayer = AudioPlayer()
    
    var musicVolume: Float = 1.0
    var musicPlayer: AVAudioPlayer?
    var soundVolume: Float = 1.0
    var soundPlayer: AVAudioPlayer?
    var voiceVolume: Float = 1.0
    var voicePlayer: AVAudioPlayer?
    
    var hapticToggle: Bool = true
    
    let voices: [String] = ["attack1.wav", "attack2.wav", "attack3.wav", "damaged1.wav", "damaged2.wav", "damaged3.wav", "healed1.wav", "healed2.wav", "healed3.wav"]
    
    /// Sets the volume for music.
    /// - Parameter volume: The desired volume
    func setMusicVolume(volume: Float) {
        musicVolume = volume
        musicPlayer?.volume = musicVolume
    }
    
    /// Sets the volume for sounds.
    /// - Parameter volume: The desired volume
    func setSoundVolume(volume: Float) {
        soundVolume = volume
    }
    
    /// Sets the volume for voices.
    /// - Parameter volume: The desired volume
    func setVoiceVolume(volume: Float) {
        voiceVolume = volume
    }
    
    /// Plays the background music outside of an fight.
    func playMenuMusic() {
        do {
            let path = Bundle.main.path(forResource: "LudumDare30-Track6.wav", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = musicVolume
            musicPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    /// Plays the background music during of an fight.
    func playBattleMusic() {
        do {
            let path = Bundle.main.path(forResource: "LudumDare28-Track3.wav", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = musicVolume
            musicPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    /// Plays a basic sound.
    func playStandardSound() {
        do {
            let path = Bundle.main.path(forResource: "abs-pointer-1.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = soundVolume * 0.7
            soundPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    /// Plays a confirm sound.
    func playConfirmSound() {
        do {
            let path = Bundle.main.path(forResource: "abs-confirm-1.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = soundVolume * 0.7
            soundPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    /// Plays a cancel sound.
    func playCancelSound() {
        do {
            let path = Bundle.main.path(forResource: "abs-cancel-1.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = soundVolume * 0.7
            soundPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    /// Plays an attack sound.
    func playAttackSound() {
        let index: Int = Int.random(in: 0 ..< 3)
        
        do {
            let path = Bundle.main.path(forResource: voices[index], ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            voicePlayer = try AVAudioPlayer(contentsOf: url)
            voicePlayer?.volume = voiceVolume
            voicePlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    /// Plays a hurt sound.
    func playHurtSound() {
        let index: Int = Int.random(in: 0 ..< 3)
        
        do {
            let path = Bundle.main.path(forResource: voices[index + 3], ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            voicePlayer = try AVAudioPlayer(contentsOf: url)
            voicePlayer?.volume = voiceVolume
            voicePlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    /// Plays a healing sound.
    func playHealSound() {
        let index: Int = Int.random(in: 0 ..< 3)
        
        do {
            let path = Bundle.main.path(forResource: voices[index + 6], ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            voicePlayer = try AVAudioPlayer(contentsOf: url)
            voicePlayer?.volume = voiceVolume
            voicePlayer?.play()
        } catch {
            print("\(error)")
        }
    }
}
