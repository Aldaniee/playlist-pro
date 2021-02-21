//
//  QueueManager.swift
//  Playlist Pro
//
//  Manages the backend queue organizing
//

import UIKit

protocol QueueManagerDelegate: class {
    func updateDisplayedSong()
    func changePlayPauseIcon(isPlaying: Bool)
    func audioPlayerPeriodicUpdate(currentTime: Float, duration: Float)
}

public class QueueManager: NSObject, YYTAudioPlayerDelegate{
    
    
    static let shared = QueueManager()
    weak var delegate: QueueManagerDelegate?

    private var audioPlayer: YYTAudioPlayer!

    var queue = NSMutableArray()

	override init() {
		super.init()
		audioPlayer = YYTAudioPlayer()
        audioPlayer.delegate = self
        
        
        queue = LibraryManager.shared.songLibrary.getSongList()
        if audioPlayer.setupPlayer(withQueue: queue) == false {
            print("setup failure")
        }

    }
	
	func moveQueueForward() {
        queue.add(queue.object(at: 0))
        queue.removeObject(at: 0)
        delegate!.updateDisplayedSong()
	}
	
	func moveQueueBackward() {
        queue.insert(queue.lastObject!, at: 0)
        queue.removeObject(at: queue.count - 1)
        delegate!.updateDisplayedSong()
	}
	
	func didSelectSong(songDict: Dictionary<String, Any>) {
        queue.remove(songDict)
        queue.insert(songDict, at: 0)
        play()
	}
    
    func next() {
        audioPlayer.next()
        delegate?.changePlayPauseIcon(isPlaying: true)
    }
    func prev() {
        audioPlayer.prev()
        delegate?.changePlayPauseIcon(isPlaying: true)
    }
    func play() {
        audioPlayer.play()
        delegate?.changePlayPauseIcon(isPlaying: true)
    }
    func pause() {
        audioPlayer.pause()
        delegate?.changePlayPauseIcon(isPlaying: false)
    }
    func isPlaying() -> Bool {
        return audioPlayer.isPlaying()
    }
    func setPlayerRate(to rate: Float) {
        audioPlayer.setPlayerRate(to: rate)
    }
    func setPlayerCurrentTime(withPercentage percentage: Float) {
        audioPlayer.setPlayerCurrentTime(withPercentage: percentage)
    }
    func suspend() {
        audioPlayer.suspend()
    }
    func unsuspend() {
        audioPlayer.unsuspend()
    }
    func audioPlayerPeriodicUpdate(currentTime: Float, duration: Float) {
        delegate?.audioPlayerPeriodicUpdate(currentTime: currentTime, duration: duration)
    }
    
    func audioPlayerPlayingStatusChanged(isPlaying playing: Bool) {
        delegate?.changePlayPauseIcon(isPlaying: playing)
    }
}
