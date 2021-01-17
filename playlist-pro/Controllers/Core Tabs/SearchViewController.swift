//
//  ViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 10/27/20.
//

import UIKit
import Combine
import XCDYouTubeKit

class SearchViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SearchModelDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let LM = LibraryManager()
    var model = SearchModel()
    var videos = [Video]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set itself as the datasource and the delegate
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        model.delegate = self
        
        model.getVideos()
    }
    
    func loadYouTubeVideo(videoID: String) {
        print("Loading url: https://www.youtube.com/embed/\(videoID)")
        self.showSpinner(onView: self.view, withTitle: "Loading...")
        XCDYouTubeClient.default().getVideoWithIdentifier(videoID) { (video, error) in
            guard video != nil else {
                print(error?.localizedDescription as Any)
                self.removeSpinner()
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler:nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.removeSpinner()
            self.LM.addSongToLibrary(songTitle: video!.title, songUrl: video!.streamURL!, songExtension: "mp4", thumbnailUrl: video!.thumbnailURLs![video!.thumbnailURLs!.count/2], songID: videoID, completion: nil)
        }
    }
    
    // MARK: – Model Delegate Methods
    func videosFetched(_ videos: [Video]) {
        self.videos = videos
        tableView.reloadData()
    }
    // MARK: - Search Delegate Methods
    func searchResultsFetched(_ searchResults: [Video]) {
        self.videos = searchResults
        tableView.reloadData()
    }
    
    // MARK: – TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.YT.VIDEOCELL_ID, for: indexPath) as! VideoTableViewCell
        
        // Configure the cell with the data
        let video = self.videos[indexPath.row]
        cell.setCell(video)
        
        // Return the cell
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Confirm that a video was selected
        guard tableView.indexPathForSelectedRow != nil else {
            return
        }
        
        // Get a reference to the video that was tapped on
        let selectedVideo = videos[tableView.indexPathForSelectedRow!.row]
        
        // Download the selected video
        loadYouTubeVideo(videoID: selectedVideo.videoId)
    }
    // MARK: - SearchBar Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            model.search(searchText: searchBar.text!)
        }
        else {
            
        }
    }
/*
    @IBAction func didTapImportSpotify(_ sender: Any) {
        self.performSegue(withIdentifier: "import", sender: sender)
    }
    
    @IBSegueAction func showPlaylistImport(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: ImportViewController())
    }
    */
}

