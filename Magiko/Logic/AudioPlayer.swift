//
//  AudioPlayer.swift
//  Magiko
//
//  Created by Janice Hablützel on 27.01.22.
//

import AVFoundation

class AudioPlayer {
    static let shared: AudioPlayer = AudioPlayer()
    
    var soundVolume: Float = 1.0
    var soundPlayer: AVAudioPlayer?
    
    func setSoundVolume(volume: Float) {
        soundVolume = volume
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
