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
    func refreshQueueVC()
}

public class QueueManager: NSObject {
    
    
    static let shared = QueueManager()
    weak var delegate: QueueManagerDelegate?

    final let PREV_CUTOFF_FOR_SONG_RESTART = 2.0 // seconds before previous restarts the song
    var audioPlayer: YYTAudioPlayer!
    
    var repeatSelection = RepeatType.playlist
    var shuffleStatus = false

    var currentPlaylist : Playlist?
    var nowPlaying = Song()
    var nowPlayingSource = "playlist"
    var playlistQueue : NSMutableArray!
    var addedQueue : NSMutableArray!
    
	override init() {
		super.init()
        
		audioPlayer = YYTAudioPlayer()
        
        playlistQueue = NSMutableArray()
        addedQueue = NSMutableArray()
    }
    
    /// Returns the queue in full which is a combination of the up next song,
    /// addedQueue, and playlistQueue. This is used as the array of songs playback
    func combinedQueue() -> NSMutableArray {
        let combined = NSMutableArray(array: addedQueue.addingObjects(from: playlistQueue as [AnyObject]))
        combined.insert(nowPlaying, at: 0)

        return combined
    }
    
    func setupAudioPlayer() {
        if audioPlayer.setupPlayer(withQueue: combinedQueue()) == false {
            print("setup failure")
        }
        setupRemoteTransportControls()
    }
    
    func setupQueue(with playlist: Playlist, startingAt: Int) {
        self.currentPlaylist = playlist
        self.playlistQueue = NSMutableArray(array: playlist.songList)
        if audioPlayer.isSuspended {
            audioPlayer.unsuspend()
            print("Audio Player Force Unsuspended")
        }
        didSelectSong(index: startingAt)
        if nowPlaying.isEmpty {
            moveQueueForward()
        }
        setupAudioPlayer()
        play()
    }
    
    func addToQueue(songDict: Song) {
        addedQueue.add(songDict)
        delegate?.refreshQueueVC()
    }
    func addToQueue(playlist: Playlist) {
        addedQueue = NSMutableArray(array: NSMutableArray(array: playlist.songList).addingObjects(from: addedQueue as [AnyObject]))
        delegate?.refreshQueueVC()
    }
    
    /// Removes a song from the queue at the position of index
    ///
    func removeFromQueue(section: Int, index: Int) {
        switch (section) {
            case 0:
                if addedQueue.count == 0 {
                    nowPlaying = playlistQueue.object(at: 0) as! Song
                    nowPlayingSource = "playlist"
                    playlistQueue.removeObject(at: 0)
                }
                else {
                    nowPlaying = addedQueue.object(at: 0) as! Song
                    nowPlayingSource = "added"
                    addedQueue.removeObject(at: 0)
                }
                return
            case 1:
                addedQueue.remove(index)
                return
            default:
                playlistQueue.remove(index)
                return
        }
    }
    func removeAllInstancesFromQueue(songID: String) {
        if songID == nowPlaying[SongValues.id] as! String {
            removeFromQueue(section: 0, index: 0)
        }
        for index in 0..<playlistQueue.count {
            let songDict = playlistQueue[index] as! Song
            if songID == songDict[SongValues.id] as! String {
                removeFromQueue(section: 1, index: index)
            }
        }
        for index in 0..<addedQueue.count {
            let songDict = addedQueue[index] as! Song
            if songID == songDict[SongValues.id] as! String {
                removeFromQueue(section: 2, index: index)
            }
        }
    }

    func shuffle() {
        shuffleStatus = !shuffleStatus
        if shuffleStatus {
            playlistQueue = NSMutableArray(array: (playlistQueue as! Array<Dictionary<String,Any>>).shuffled())
        }
        else {
            let playingSongPlaylistIndex = currentPlaylist!.songList.index(of: nowPlaying)
            playlistQueue = NSMutableArray(array: currentPlaylist!.songList)
            moveQueueForward(to: playingSongPlaylistIndex)
        }
    }
	func moveQueueForward() {
        if addedQueue.count == 0 {
            if repeatSelection == RepeatType.playlist && nowPlayingSource == "playlist" {
                if nowPlaying.isEmpty == false {
                    playlistQueue.add(nowPlaying)
                }
            }
            nowPlaying = playlistQueue.object(at: 0) as! Song
            nowPlayingSource = "playlist"
            playlistQueue.removeObject(at: 0)
        }
        else {
            nowPlaying = addedQueue.object(at: 0) as! Song
            nowPlayingSource = "added"
            addedQueue.removeObject(at: 0)
        }
	}
	
	func moveQueueBackward() {
        playlistQueue.add(nowPlaying)
        nowPlaying = playlistQueue.object(at: playlistQueue.endIndex()) as! Song
        nowPlayingSource = "playlist"

        playlistQueue.removeObject(at: playlistQueue.endIndex())
	}
    
    func moveQueueForward(to index: Int) {
        for _ in 0..<index+1 {
            moveQueueForward()
        }
    }
	
	func didSelectSong(index: Int) {
        if !audioPlayer.isSuspended {
            moveQueueForward(to: index)
            print(nowPlaying)
            updateSongPlaying()
        }
        else {
            print("Audio Player Suspended")
        }
    }
    
    func nextButtonAction() {
        if !audioPlayer.isSuspended {
            if repeatSelection == RepeatType.song || playlistQueue.count == 1{
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
        if audioPlayer.setupPlayer(withQueue: combinedQueue()) {
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

