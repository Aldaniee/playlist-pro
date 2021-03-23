//
//  SpotifyPlaylist.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/19/21.
//

import Foundation

struct SpotifyPlaylist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: SpotifyUser
}

struct SpotifyUser: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
