//
//  CacheManager.swift
//  playlist-pro
//
//  Created by Aidan Lee on 11/2/20.
//

import Foundation

class CacheManager {
    
    static var cache = [String:Data]()
    
    static func setVideoCache(_ url: String, _ data: Data?) {
        
        // String the image data and use the url as the key
        cache[url] = data
    }
    
    static func getVideoCache(_ url: String) -> Data? {
        
        // Try and get the data of the specified url
        return cache[url]
    }
}
