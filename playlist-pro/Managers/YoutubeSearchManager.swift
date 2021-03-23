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
                dump(response)
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
    func downloadYouTubeVideo(video: Video, vc: UIViewController, playlistTitle: String?) {
        let videoID = video.videoId
        let title = video.title
        let artistArray = NSMutableArray(object: video.artist)
        print("Loading url: https://www.youtube.com/embed/\(videoID)")
        vc.showSpinner(onView: vc.view, withTitle: "Loading...")
        XCDYouTubeClient.default().getVideoWithIdentifier(videoID) { (video, error) in
            guard video != nil else {
                print(error?.localizedDescription as Any)
                vc.removeSpinner()
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler:nil))
                vc.present(alert, animated: true, completion: nil)
                return
            }
            vc.removeSpinner()
            LibraryManager.shared.addSongToLibrary(songTitle: title, artists: artistArray, songUrl: video!.streamURL!, songExtension: "mp4", thumbnailUrl: video!.thumbnailURLs![video!.thumbnailURLs!.count/2], songID: videoID, playlistTitle: playlistTitle, completion: nil)
        }
    }
}
