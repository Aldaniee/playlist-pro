//
//  YoutubeSearchManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/19/21.
//

import Foundation
import UIKit
import XCDYouTubeKit

class YoutubeSearchManager {
    static let shared = YoutubeSearchManager()
    
    func search(searchText text: String, completion: @escaping ([Video]?)-> ()) {
                
        // Create a URL object
        let url = getSearchURL(withText: text)
        
        // Start the task
        sendRequest(url: url) { response in
            if let response = response {
                if response.items != nil {
                    completion(response.items!)
                }
            }
        }
        completion(nil)
    }
    
    func sendRequest(url: URL, completion: @escaping (Response?) -> ()) {
        // Get a data task (a single call to the API)
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // check if there were any errors
            if error != nil {
                print(error!)
                return
            }
            
            do {
                // Parse the data into video objects
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(Response.self, from: data!)
                completion(response)
                //dump(response)
            }
            catch {
                completion(nil)
                print(error)
            }
        }.resume()
    }
    
    func getSearchURL(withText text : String) -> URL {
        let searchableText = text.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url = URL(string: Constants.YT.SEARCHLIST_URL_PT1 + searchableText + Constants.YT.SEARCHLIST_URL_PT2)!
        return url
    }
    func downloadYouTubeVideo(videoID: String, title: String, artistArray: NSMutableArray, playlistTitle: String?) {
        //let vc = UIApplication.getCurrentViewController()
        print("Loading url: https://www.youtube.com/embed/\(videoID)")
        //vc?.showSpinner(onView: vc!.view, withTitle: "Loading...")
        XCDYouTubeClient.default().getVideoWithIdentifier(videoID) { (video, error) in
            guard video != nil else {
                print(error?.localizedDescription as Any)
                //vc?.removeSpinner()
                //let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                //alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler:nil))
                //vc?.present(alert, animated: true, completion: nil)
                return
            }
            //vc?.removeSpinner()
            LibraryManager.shared.addSongToLibrary(songTitle: title, artists: artistArray, songUrl: video!.streamURL!, songExtension: "mp4", thumbnailUrl: video!.thumbnailURLs![video!.thumbnailURLs!.count/2], videoID: videoID, playlistTitle: playlistTitle, completion: nil)
        }
    }
    
    /// Given the library of songDicts is correct, download all of the missing audio files from youtube
    func downloadMissingLibraryFiles(oldLibrary: NSMutableArray, newLibrary: NSMutableArray) {
        for element in newLibrary {
            let song = element as! Song
            let songName = song[SongValues.title] as! String
            var songID = song[SongValues.id] as! String
            if (!oldLibrary.contains(songID)) {
                print("File not found for song: \(songName). Downloading audio.")
                let title = song[SongValues.title] as! String
                let artistArray = NSMutableArray(array: song[SongValues.artists] as! NSArray)
                if songID.contains("yt_") {
                    songID = songID.substring(fromIndex: 3)
                    songID = songID.substring(toIndex: 11)
                }
                downloadYouTubeVideo(videoID: songID, title: title, artistArray: artistArray, playlistTitle: nil)
            }
            print("Song already found for: \(songName), skipping download")
        }

    }
}
