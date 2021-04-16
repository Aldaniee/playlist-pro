//
//  ViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 10/27/20.
//

import UIKit
import Combine

class SearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, SearchModelDelegate {

    let searchBar = UISearchBar()
    
    private var isSearching = false
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchVideoCell.self,
                           forCellReuseIdentifier: SearchVideoCell.identifier)
        tableView.rowHeight = 80
        return tableView
    }()

    var model = SearchModel()
    var videos = [Video]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"

        // Set itself as the datasource and the delegate
        tableView.dataSource = self
        tableView.delegate = self
        model.delegate = self
        searchBar.delegate = self
        
        searchBar.sizeToFit()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = "Search"
        
        navigationItem.titleView = searchBar
        
        view.addSubview(tableView)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: view.width,
                                 height: view.height)
    }
    
    // MARK: – Model Delegate Methods
    func videosFetched(_ videos: [Video]) {
        self.videos = videos
        reloadTableView()
    }
    // MARK: - Search Delegate Methods
    func searchResultsFetched(_ searchResults: [Video]) {
        self.videos = searchResults
        reloadTableView()
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
        reloadTableView()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
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
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearching == true) {
            return videos.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchVideoCell.identifier,
                                                 for: indexPath) as! SearchVideoCell
        
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
        YoutubeManager.shared.downloadYouTubeVideoAddToLibrary(inVideo: selectedVideo, completion: { success in
            if success {
                print("Downloaded from Search View")
            }
        })
    }
    
}
