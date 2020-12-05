//
//  Model.swift
//  youtube-onedaybuild
//
//  Created by Aidan Lee on 10/29/20.
//

import Foundation

protocol ModelDelegate {
     
    func videosFetched(_ video:[Video])
    func searchResultsFetched(_ searchResults: [Video])

}

class Model {
    
    var delegate: ModelDelegate?
    
    func getVideos() {
        
        // Create a URL object
        let url = getSearchURL(withText: "Hello - Adele")

        // Get a URLSession Object
        let session = URLSession.shared
        
        // Get a data task (a single call to the API)
        let dataTask = session.dataTask(with: url) { (data, response, error) in
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
                if response.items != nil {
                    DispatchQueue.main.async {
                        // Call the "videosFetched" method of the delegate
                        self.delegate?.videosFetched(response.items!)
                    }
                }
                dump(response)
            }
            catch {
                print(error)
            }
        }
        
        // Start the task
        dataTask.resume()
    }

    func search(searchText text : String) {
        
        // Create a URL object
        let url = getSearchURL(withText: text)

        // Get a URLSession Object
        let session = URLSession.shared
        
        // Get a data task (a single call to the API)
        let dataTask = session.dataTask(with: url) { (data, response, error) in
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
                if response.items != nil {
                    DispatchQueue.main.async {
                        // Call the "videosFetched" method of the delegate
                        self.delegate?.videosFetched(response.items!)
                    }
                }
                dump(response)
            }
            catch {
                print(error)
            }
        }
        
        // Start the task
        dataTask.resume()
    }
    
    private func getSearchURL(withText text : String) -> URL {
        let searchableText = text.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url = URL(string: Constants.API_SEARCHLIST_URL_PT1 + searchableText + Constants.API_SEARCHLIST_URL_PT2)!
        return url
    }
    
}
