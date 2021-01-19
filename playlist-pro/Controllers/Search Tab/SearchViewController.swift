//
//  ViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 10/27/20.
//

import UIKit
import Combine
import XCDYouTubeKit

class SearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, SearchModelDelegate {

    private let searchBar = UISearchBar()
    
    private var isSearching = false
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchTableViewCell.self,
                           forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.rowHeight = 80
        return tableView
    }()

    
    let LM = LibraryManager()
    var model = SearchModel()
    var videos = [Video]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set itself as the datasource and the delegate
        tableView.dataSource = self
        tableView.delegate = self
        model.delegate = self
        searchBar.delegate = self
        
        searchBar.sizeToFit()
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Search"
        
        navigationItem.titleView = searchBar
        
        view.addSubview(tableView)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: view.width,
                                 height: view.height)
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
    
    // MARK: - SearchBar Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            model.search(searchText: searchBar.text!)
            closeSearch()
        }
        else {
            
        }
    }
    
    private func closeSearch() {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("search bar opened")
        searchBar.showsCancelButton = true
        isSearching = true
        searchBar.becomeFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel pressed")
        searchBar.text = ""
        isSearching = false
        closeSearch()
    }
}

extension SearchViewController: UITableViewDataSource {
    // MARK: – TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearching == true) {
            return videos.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier,
                                                 for: indexPath) as! SearchTableViewCell
        
        // Show search Results
        if(isSearching == true) {
            let video = self.videos[indexPath.row]
            cell.setCell(video)
        }
        // Show the previously downloaded videos
        else {
            
        }
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
    
}
