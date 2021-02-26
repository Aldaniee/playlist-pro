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

    final let PREV_CUTOFF_FOR_SONG_RESTART = 2.0 //seconds
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
        if audioPlayer.repeatType == RepeatType.playlist {
            queue.add(queue.object(at: 0))
        }
        queue.removeObject(at: 0)
	}
	
	func moveQueueBackward() {
        queue.insert(queue.lastObject!, at: 0)
        queue.removeObject(at: queue.endIndex())
	}
	
	func didSelectSong(songDict: Dictionary<String, Any>) {
        if !audioPlayer.isSuspended {
            for _ in 0..<queue.index(of: songDict) {
                if audioPlayer.repeatType == RepeatType.playlist {
                    queue.add(queue.object(at: 0))
                }
                queue.removeObject(at: 0)
            }
            updateSongPlaying()
        }

    }
    
    func next() {
        if !audioPlayer.isSuspended {
            if audioPlayer.repeatType == RepeatType.song || queue.count == 1{
                audioPlayer.audioPlayer.currentTime = 0.0
            }
            else {
                moveQueueForward()
            }
            updateSongPlaying()
        }
    }
    
    func prev() {
        if !audioPlayer.isSuspended  {
            if audioPlayer.audioPlayer?.currentTime ?? 0 < PREV_CUTOFF_FOR_SONG_RESTART {
                updateSongPlaying()
            } else {
                audioPlayer.audioPlayer.currentTime = 0.0
            }
        }
    }
    /// Displays and plays the first song of the queue
    private func updateSongPlaying() {
        delegate!.updateDisplayedSong()
        if audioPlayer.setupPlayer() {
            play()
        }
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

extension NSMutableArray {
    func endIndex() -> Int {
        return count-1
    }
}

