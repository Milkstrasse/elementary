//
//  AudioPlayer.swift
//  Magiko
//
//  Created by Janice Hablützel on 27.01.22.
//

import AVFoundation

class AudioPlayer {
    static let shared: AudioPlayer = AudioPlayer()
    
    var musicVolume: Float = 1.0
    var musicPlayer: AVAudioPlayer?
    var soundVolume: Float = 1.0
    var soundPlayer: AVAudioPlayer?
    
    func setMusicVolume(volume: Float) {
        musicVolume = volume
        musicPlayer?.volume = musicVolume
    }
    
    func setSoundVolume(volume: Float) {
        soundVolume = volume
    }
    
    func playMenuMusic() {
        do {
            let path = Bundle.main.path(forResource: "AltusStratum.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = musicVolume
            musicPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func playBattleMusic() {
        do {
            let path = Bundle.main.path(forResource: "Avenger.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = musicVolume
            musicPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func playStandardSound() {
        do {
            let path = Bundle.main.path(forResource: "abs-pointer-1.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = soundVolume
            soundPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func playConfirmSound() {
        do {
            let path = Bundle.main.path(forResource: "abs-confirm-1.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = soundVolume
            soundPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func playCancelSound() {
        do {
            let path = Bundle.main.path(forResource: "abs-cancel-1.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = soundVolume
            soundPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
}
