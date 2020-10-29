//
//  Model.swift
//  youtube-onedaybuild
//
//  Created by Aidan Lee on 10/29/20.
//

import Foundation

class Model {
    
    func getVideos() {
        
        // Create a URL object
        let url = URL(string: Constants.API_URL)
        
        guard url != nil else {
            return
        }
        // Get a URLSession Object
        let session = URLSession.shared
        
        // Get a data task (a single call to the API)
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            // check if there were any errors
            if error != nil {
                return
            }
            
            do {
                // Parse the data into video objects
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let response = try decoder.decode(Response.self, from: data!)
                dump(response)
            }
            catch {
                
            }
        }
        
        // Start the task
        dataTask.resume()
    }
    
}
