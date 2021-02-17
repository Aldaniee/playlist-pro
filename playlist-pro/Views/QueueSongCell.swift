//
//  LibraryCell.swift
//  YouTag
//
//  Created by Youstanzr on 2/28/20.
//  Copyright © 2020 Youstanzr. All rights reserved.
//

import UIKit

class QueueSongCell : UITableViewCell {
  
    static let identifier = "SongCell"
    static let rowHeight = CGFloat(80)
    
	var songDict = Dictionary<String, Any>()
	let thumbnailImageView: UIImageView = {
		let imgView = UIImageView()
        return imgView
	}()
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Constants.UI.gray
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
	let durationLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = UIFont.systemFont(ofSize: 12)
		lbl.textAlignment = .right
		return lbl
	}()

	
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .clear
		
        self.contentView.addSubview(thumbnailImageView)
		thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
		thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
		thumbnailImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		thumbnailImageView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -15).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor).isActive = true
        thumbnailImageView.frame = CGRect(x: 20, y: contentView.width/2, width: 15.0, height: 15.0)

        self.contentView.addSubview(titleLabel)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 30).isActive = true
		titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
		titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 5).isActive = true
		titleLabel.heightAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0.55, constant: -5).isActive = true
		
		self.contentView.addSubview(artistLabel)
		artistLabel.translatesAutoresizingMaskIntoConstraints = false
		artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
		artistLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.8).isActive = true
		artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
		artistLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor).isActive = true

		self.contentView.addSubview(durationLabel)
		durationLabel.translatesAutoresizingMaskIntoConstraints = false
		durationLabel.leadingAnchor.constraint(equalTo: artistLabel.trailingAnchor).isActive = true
		durationLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.2).isActive = true
		durationLabel.topAnchor.constraint(equalTo: artistLabel.topAnchor).isActive = true
		durationLabel.heightAnchor.constraint(equalTo: artistLabel.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func refreshCell() {
		self.titleLabel.text = songDict["title"] as? String
		self.artistLabel.text = (songDict["artists"] as? NSArray ?? NSArray())!.componentsJoined(by: ", ")
		let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songDict["id"] as? String ?? "").jpg"))
		if let imgData = imageData {
            self.thumbnailImageView.image = cropToBounds(image: UIImage(data: imgData)!, height: 15.0)
		} else {
			self.thumbnailImageView.image = UIImage(named: "placeholder")
		}
		self.durationLabel.text = songDict["duration"] as? String
		
	}
    private func cropToBounds(image: UIImage, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage = UIImage(cgImage: cgimage)
        let contextSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth = CGFloat(height)
        var cgheight = CGFloat(height)

        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        return UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
    }
}
