//
//  PlaylistManager.swift
//  YouTag
//
//  Created by Youstanzr on 3/19/20.
//  Copyright © 2020 Youstanzr. All rights reserved.
//

import UIKit

class QueueManager: NSObject, PlaylistLibraryViewDelegate, NowPlayingViewDelegate {
	
	var nowPlayingView: NowPlayingView!
	var playlistLibraryView: PlaylistLibraryView!
	var audioPlayer: YYTAudioPlayer!
	
	override init() {
		super.init()
		audioPlayer = YYTAudioPlayer(playlistManager: self)
		playlistLibraryView = PlaylistLibraryView()
		playlistLibraryView.PLDelegate = self
		nowPlayingView = NowPlayingView(frame: .zero, audioPlayer: audioPlayer)
		nowPlayingView.NPDelegate = self
		refreshNowPlayingView()
	}
				
	func updatePlaylistLibrary(toPlaylist newPlaylist: NSMutableArray) {
		playlistLibraryView.playlistArray = newPlaylist
		playlistLibraryView.refreshTableView()
		refreshNowPlayingView()
	}
	
	func refreshNowPlayingView() {
		let songDict: Dictionary<String, Any>
		if playlistLibraryView.playlistArray.count > 0 {
			audioPlayer.unsuspend()
			songDict = playlistLibraryView.playlistArray.object(at: playlistLibraryView.playlistArray.count-1) as! Dictionary<String, Any>
		} else {
			audioPlayer.suspend()
			songDict = Dictionary<String, Any>()
		}

		let songID = songDict["id"] as? String ?? ""
		nowPlayingView.songID = songID
		nowPlayingView.titleLabel.text = songDict["title"] as? String ?? ""
		nowPlayingView.artistLabel.text = ((songDict["artists"] as? NSArray ?? NSArray())!.componentsJoined(by: ", "))
		
		let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songID).jpg"))
		if let imgData = imageData {
			nowPlayingView.thumbnailImageView.image = UIImage(data: imgData)
		} else {
			nowPlayingView.thumbnailImageView.image = UIImage(named: "placeholder")
		}

		let oldPlaybackRate = audioPlayer.getPlayerRate()
		
		if playlistLibraryView.playlistArray.count > 0 {
			_ = audioPlayer.setupPlayer(withPlaylist: NSMutableArray(array: playlistLibraryView.playlistArray.reversed()))
		}

		//nowPlayingView.playbackRateButton.titleLabel?.text = "x\(oldPlaybackRate == 1.0 ? 1 : oldPlaybackRate)"
		nowPlayingView.progressBar.value = 0.0
		//nowPlayingView.currentTimeLabel.text = "00:00"
		//nowPlayingView.timeLeftLabel.text = (songDict["duration"] as? String) ?? "00:00"
	}
	
	func refreshPlaylistLibraryView() {
		playlistLibraryView.refreshTableView()
		refreshNowPlayingView()
	}
	
	func moveQueueForward() {
		playlistLibraryView.playlistArray.insert(playlistLibraryView.playlistArray.lastObject!, at: 0)
		playlistLibraryView.playlistArray.removeObject(at: playlistLibraryView.playlistArray.count - 1)
		playlistLibraryView.reloadData()
		refreshNowPlayingView()
	}
	
	func moveQueueBackward() {
		playlistLibraryView.playlistArray.add(playlistLibraryView.playlistArray.object(at: 0))
		playlistLibraryView.playlistArray.removeObject(at: 0)
		playlistLibraryView.reloadData()
		refreshNowPlayingView()
	}
	
	func didSelectSong(songDict: Dictionary<String, Any>) {
		refreshNowPlayingView()
		nowPlayingView.pausePlayButtonAction(sender: nil)
	}
	
	func shuffleQueue() {
		if playlistLibraryView.playlistArray.count <= 1 {
			return
		}
		let lastObject = playlistLibraryView.playlistArray.object(at: playlistLibraryView.playlistArray.count - 1)
		let whatsNextArr = playlistLibraryView.playlistArray
		whatsNextArr.removeLastObject()
		let shuffledArr = NSMutableArray(array: whatsNextArr.shuffled())
		shuffledArr.add(lastObject)
		playlistLibraryView.playlistArray = shuffledArr
		playlistLibraryView.refreshTableView()
	}

	// MARK: Filter processing functions
	func computeQueue() {
        let newPlaylist = playlistLibraryView.LM.songLibrary.getSongList()
		updatePlaylistLibrary(toPlaylist: newPlaylist)
	}
	
//	fileprivate func isValue(_ val: Double, inBoundList durationList: NSMutableArray) -> Bool {
//		var durationBound: NSMutableArray
//		var lowerBound: Double
//		var upperBound: Double
//		for j in 0 ..< durationList.count {
//			durationBound = durationList.object(at: j) as! NSMutableArray
//			lowerBound = durationBound.object(at: 0) as! Double
//			upperBound = durationBound.object(at: 1) as! Double
//			if val < lowerBound || val > upperBound {
//				return false
//			}
//		}
//		return true
//	}
			
}
