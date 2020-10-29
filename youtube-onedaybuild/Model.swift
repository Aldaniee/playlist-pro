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
            
            // Parse the data into video objects
        }
        
        // Start the task
        dataTask.resume()
    }
    
}
