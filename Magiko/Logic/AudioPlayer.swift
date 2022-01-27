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
    
    func playMusic() {
        let path = Bundle.main.path(forResource: "AltusStratum.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = musicVolume
            musicPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func playStandardSound() {
        let path = Bundle.main.path(forResource: "abs-pointer-1.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = soundVolume
            soundPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func playConfirmSound() {
        let path = Bundle.main.path(forResource: "abs-confirm-1.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = soundVolume
            soundPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func playCancelSound() {
        let path = Bundle.main.path(forResource: "abs-cancel-1.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = soundVolume
            soundPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
}
