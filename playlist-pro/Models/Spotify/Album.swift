//
//  Album.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/19/21.
//

import Foundation

struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    let id: String
    var images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}
