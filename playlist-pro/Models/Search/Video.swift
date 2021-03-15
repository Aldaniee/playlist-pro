//
//  SearchVideo.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/4/20.
//
//  An object to store the downloaded YouTube video from the search result

import Foundation

struct Video : Decodable {
    
    var videoId = ""
    var title = ""
    var description = ""
    var thumbnail = ""
    var published = Date()
    var artist = ""
    
    enum CodingKeys: String, CodingKey {
        
        case snippet
        case thumbnails
        case high
        case id // For search only
        
        case published = "publishedAt"
        case title
        case channel = "channelTitle"
        case description
        case thumbnail = "url"
        case videoId
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        

        // Parse the title and channel name
        let youtubeTitle = try snippetContainer.decode(String.self, forKey: .title)
        if youtubeTitle.contains("-") {
            let dashIndex = youtubeTitle.firstIndex(of: "-")
            let titleStart = youtubeTitle.index(dashIndex!, offsetBy: 2)
            let titleRange = titleStart...
            let artistEndIndex = youtubeTitle.index(dashIndex!, offsetBy: -1)
            let artistRange = ...artistEndIndex
            self.artist = String(youtubeTitle[artistRange])
            self.title = String(youtubeTitle[titleRange])
            print("AAAAAAAAAA  \(title)")
            print("AAAAAAAAAA  \(artist)")
        }
        else {
            self.artist = try snippetContainer.decode(String.self, forKey: .channel)
            self.title = youtubeTitle
        }


        // Parse the description
        self.description = try snippetContainer.decode(String.self, forKey: .description)
        
        // Parse the publish date
        self.published = try snippetContainer.decode(Date.self, forKey: .published)
        
        // Parse thumbnails
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        self.thumbnail = try highContainer.decode(String.self, forKey: .thumbnail)
        
        // Parse Video ID
        let idContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .id)
        self.videoId = try idContainer.decode(String.self, forKey: .videoId)
    }

/*
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        
        // Parse the title
        self.title = try snippetContainer.decode(String.self, forKey: .title)
        
        // Parse the description
        self.description = try snippetContainer.decode(String.self, forKey: .description)
        
        // Parse the publish date
        self.published = try snippetContainer.decode(Date.self, forKey: .published)
        
        // Parse thumbnails
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        self.thumbnail = try highContainer.decode(String.self, forKey: .thumbnail)
        
        // Parse Video ID
        let resourceIdContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .resourceId)
        self.videoId = try resourceIdContainer.decode(String.self, forKey: .videoId)
    }
 */
}
