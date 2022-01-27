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
    
    func playSound(name: String) {
        let path = Bundle.main.path(forResource: name, ofType: nil)!
            let url = URL(fileURLWithPath: path)

            do {
                //create your audioPlayer in your parent class as a property
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("couldn't load the file")
            }
    }
}
