//
//  Model.swift
//  playlist-pro
//
//  Created by Aidan Lee on 10/29/20.
//

import Foundation

protocol SearchModelDelegate {
     
    func videosFetched(_ video:[Video])
}

class SearchModel {
        
    var delegate: SearchModelDelegate?

    func search(searchText text : String) {
        YoutubeSearchManager.shared.search(searchText: text) { (videos) in
            if videos != nil {
                DispatchQueue.main.async {
                    self.delegate?.videosFetched(videos!)
                }
            }
        }
    }
}
