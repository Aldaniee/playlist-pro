//
//  QueueManager.swift
//  Playlist Pro
//
//  Manages the backend queue organizing
//

import UIKit
import MediaPlayer

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
    
    var repeatSelection = RepeatType.playlist
    var shuffleStatus = false

    var queue = NSMutableArray()

	override init() {
		super.init()
		audioPlayer = YYTAudioPlayer()
        audioPlayer.delegate = self
        

        queue = LibraryManager.shared.songLibrary.getSongList()
        if audioPlayer.setupPlayer(withQueue: queue) == false {
            print("setup failure")
        }
        setupRemoteTransportControls()

    }
    func shuffle() {
        shuffleStatus = !shuffleStatus
        if shuffleStatus {
            var newQueue = queue.mutableCopy() as! NSMutableArray
            newQueue.removeObject(at: 0)
            newQueue = NSMutableArray(array: (newQueue as! Array<Dictionary<String,Any>>).shuffled())
            newQueue.add(queue.object(at: 0))
            queue = newQueue
            
        }
        else {
            queue = LibraryManager.shared.songLibrary.getSongList()
        }
        if audioPlayer.setupPlayer(withQueue: queue) == false {
            print("setup failure")
        }
    }
	func moveQueueForward() {
        if repeatSelection == RepeatType.playlist {
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
                if repeatSelection == RepeatType.playlist {
                    queue.add(queue.object(at: 0))
                }
                queue.removeObject(at: 0)
            }
            updateSongPlaying()
        }

    }
    
    func next() {
        if !audioPlayer.isSuspended {
            if repeatSelection == RepeatType.song || queue.count == 1{
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
            if audioPlayer.audioPlayer?.currentTime ?? 0 < PREV_CUTOFF_FOR_SONG_RESTART && repeatSelection != RepeatType.song {
                moveQueueBackward()
                updateSongPlaying()
            } else {
                audioPlayer.audioPlayer.currentTime = 0.0
            }
        }
    }
    func nextRepeatType() {
        if repeatSelection == RepeatType.none {
            repeatSelection = RepeatType.playlist
        }
        else if repeatSelection == RepeatType.playlist {
            repeatSelection = RepeatType.song
        }
        else {
            repeatSelection = RepeatType.none
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
    // MARK: Control from Control Center
    /*
    Support controlling background audio from the Control Center and iOS Lock screen.
    */
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.nextTrackCommand.removeTarget(nil)
        commandCenter.previousTrackCommand.removeTarget(nil)
        commandCenter.changePlaybackPositionCommand.removeTarget(nil)

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            print("Play command - is playing: \(!self.isPlaying())")
            if !self.isPlaying() {
                self.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            print("Pause command - is playing: \(!self.isPlaying())")
            if self.isPlaying() {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            print("Next track command pressed")
            self.next()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            print("Previous track command pressed")
            self.prev()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            let e = event as? MPChangePlaybackPositionCommandEvent
            audioPlayer.audioPlayer.currentTime = e!.positionTime
            return .success
        }
    }
}

extension NSMutableArray {
    func endIndex() -> Int {
        return count-1
    }
}

