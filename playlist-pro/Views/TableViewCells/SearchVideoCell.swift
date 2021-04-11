//
//  SearchTableViewCell.swift
//  playlist-pro
//
//  Created by Aidan Lee on 11/2/20.
//

import UIKit

class SearchVideoCell: UITableViewCell {

    static let identifier = "SearchTableViewCell"
    
    var video: Video?
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        return titleLabel
    }()
    private let artistLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16)
        return titleLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Aspect ratio w:16 h:9
        thumbnailImageView.frame = CGRect(x: 10,
                                 y: (80 - 45) / 2,
                                 width: 45,
                                 height: 45)
        titleLabel.frame = CGRect(x: thumbnailImageView.width + 20,
                                  y: (80 - 45) / 2,
                                  width: contentView.frame.size.width - 10 - thumbnailImageView.width - 10,
                                  height: 21)
        artistLabel.frame = CGRect(x: thumbnailImageView.width + 20,
                                   y: (80 - 45) / 2 + titleLabel.height + 5,
                                  width: contentView.frame.size.width - 10 - thumbnailImageView.width - 10,
                                  height: 19)
    }
    
    func setCell(_ video: Video) {
        self.video = video
        
        // Ensure we have a video
        guard self.video != nil else {
            print("no video found")
            return
        }

        do {
            self.titleLabel.text = try self.video!.title.strippingHTML()
            self.artistLabel.text = try self.video!.artist.strippingHTML()
        }
        catch {
            print("ERROR: strippingHTML error")
        }
        // Set the title label

        // Download the thumbnail data
        let url = URL(string: self.video!.thumbnail)
        
        // Get the shared URL Session object
        let session = URLSession.shared
        
        // Create a data task
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                // Check that the downloaded thumbnail matches the current video url
                if url!.absoluteString != self.video?.thumbnail {
                    return
                }
            }
            
            // Create the image object
            let image = UIImage(data: data!)
            
            // Set the imageview
            DispatchQueue.main.async {
                self.thumbnailImageView.image = image
            }
        }
        // Start data task
        dataTask.resume()
    }
    
}
