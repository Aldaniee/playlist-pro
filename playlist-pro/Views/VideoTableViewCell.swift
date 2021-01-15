//
//  VideoTableViewCell.swift
//  playlist-pro
//
//  Created by Aidan Lee on 11/2/20.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    //@IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    //@IBOutlet weak var dateLabel: UILabel!
    
    var video: Video?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(_ video: Video) {
        
        self.video = video
        
        // Ensure we have a video
        guard self.video != nil else {
            return
        }
        
        // Set the title label
        self.titleLabel.text = self.video?.title
        
        
        // Check cache before downloadiong data
//        if let cachedData = CacheManager.getVideoCache(self.video!.thumbnail) {
//            // if we are in here we know we found the data in cache
//
//            //self.thumbnailImageView.image = UIImage(data: cachedData)
//            return
//        }
        
        // Download the thumbnail data
        let url = URL(string: self.video!.thumbnail)
        
        // Get the shared URL Session object
        let session = URLSession.shared
        
        // Create a data task
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                // Save the data in the Cache
                CacheManager.setVideoCache(url!.absoluteString, data)
                
                // Check that the downloaded thumbnail matches the current video url
                
                if url!.absoluteString != self.video?.thumbnail {
                    return
                }
            }
            
            // Create the image object
            //let image = UIImage(data: data!)
            
            // Set the imageview
            //DispatchQueue.main.async {
            //    self.thumbnailImageView.image = image
            //}
        }
        // Start data task
        dataTask.resume()
    }
    
}
