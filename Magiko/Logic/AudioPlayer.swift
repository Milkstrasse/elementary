//
//  AudioPlayer.swift
//  Magiko
//
//  Created by Janice Hablützel on 27.01.22.
//

import AVFoundation

class AudioPlayer {
    static let shared: AudioPlayer = AudioPlayer()
    
    var audioPlayer: AVAudioPlayer?
    
    func playStandardSound() {
        let path = Bundle.main.path(forResource: "abs-pointer-1.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func playConfirmSound() {
        let path = Bundle.main.path(forResource: "abs-confirm-1.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
    
    func playCancelSound() {
        let path = Bundle.main.path(forResource: "abs-cancel-1.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("\(error)")
        }
    }
}
