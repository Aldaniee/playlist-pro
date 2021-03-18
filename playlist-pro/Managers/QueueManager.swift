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
    func audioPlayerPeriodicUpdate(currentTime: Float, duration: Float)
}

public class QueueManager: NSObject {
    
    
    static let shared = QueueManager()
    weak var delegate: QueueManagerDelegate?

    final let PREV_CUTOFF_FOR_SONG_RESTART = 2.0 // seconds before previous restarts the song
    var audioPlayer: YYTAudioPlayer!
    
    var repeatSelection = RepeatType.playlist
    var shuffleStatus = false

    var currentPlaylist : Playlist?
    
    var queue : NSMutableArray!

	override init() {
		super.init()
        
		audioPlayer = YYTAudioPlayer()
        
        queue = NSMutableArray()
    }
    func setupAudioPlayer() {
        if audioPlayer.setupPlayer(withQueue: queue) == false {
            print("setup failure")
        }
        setupRemoteTransportControls()
    }
    func setupQueue(with playlist: Playlist, startingAt: Int) {
        self.currentPlaylist = playlist
        self.queue = NSMutableArray(array: playlist.songList)
        if audioPlayer.isSuspended {
            audioPlayer.unsuspend()
            print("Audio Player Force Unsuspended")
        }
        didSelectSong(index: startingAt)
        setupAudioPlayer()
        play()
    }
    func removeFromQueue(songID: String) {
        for index in 0..<queue.count {
            let songDict = queue[index] as! Dictionary<String, Any>
            if songDict[SongValues.id] as! String == songID {
                if index == 0 {
                    removePlayingSong()
                }
                else {
                    queue.removeObject(at: index)
                }
                return
            }
        }
    }
    func removePlayingSong() {
        audioPlayer.pause()
        updateSongPlaying()
        queue.removeObject(at: 0)
        pause()
        updateSongPlaying()
    }
    func shuffle() {
        shuffleStatus = !shuffleStatus
        let playingSong = queue.object(at: 0)
        if shuffleStatus {
            var newQueue = NSMutableArray(array: queue)
            newQueue.removeObject(at: 0)
            newQueue = NSMutableArray(array: (newQueue as! Array<Dictionary<String,Any>>).shuffled())
            newQueue.insert(playingSong, at: 0)
            queue = newQueue
        }
        else {
            let playingSongPlaylistIndex = currentPlaylist!.songList.index(of: playingSong)
            queue = NSMutableArray(array: currentPlaylist!.songList)
            moveQueueForward(to: playingSongPlaylistIndex)
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
    
    func moveQueueForward(to index: Int) {
        for _ in 0..<index {
            moveQueueForward()
        }
    }
	
	func didSelectSong(index: Int) {
        if !audioPlayer.isSuspended {
            moveQueueForward(to: index)
            updateSongPlaying()
        }
        else {
            print("Audio Player Suspended")
        }
    }
    
    func nextButtonAction() {
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
    
    func prevButtonAction() {
        if !audioPlayer.isSuspended  {
            if audioPlayer.audioPlayer?.currentTime ?? 0 < PREV_CUTOFF_FOR_SONG_RESTART && repeatSelection != RepeatType.song {
                moveQueueBackward()
                updateSongPlaying()
            } else {
                audioPlayer.audioPlayer.currentTime = 0.0
            }
        }
    }
    
    func toggleRepeatType() {
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
        if audioPlayer.setupPlayer(withQueue: queue) {
            play()
        }
        else {
            print("Setup Failure")
        }
        delegate?.updateDisplayedSong()
    }
    func play() {
        audioPlayer.play()
    }
    func pause() {
        audioPlayer.pause()
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
            self.nextButtonAction()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            print("Previous track command pressed")
            self.prevButtonAction()
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

