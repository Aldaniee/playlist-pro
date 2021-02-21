//
//  PlaylistCell.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/18/21.
//

import UIKit

class PlaylistCell : UITableViewCell {
  
    static let identifier = "PlaylistCell"
    static let rowHeight = CGFloat(80)
    
    var playlist : Playlist!
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshCell() {
        self.titleLabel.text = playlist.title
        if playlist.count() > 0 {
            let firstSong = playlist.getSongList().object(at: 0) as! Dictionary<String, Any>
            let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(firstSong["id"] as? String ?? "").jpg"))
            if let imgData = imageData {
                self.thumbnailImageView.image = cropToBounds(image: UIImage(data: imgData)!, height: 15.0)
            } else {
                self.thumbnailImageView.image = UIImage(systemName: "list.bullet")
                print("here")
            }
        }
        else {
            self.thumbnailImageView.image = UIImage(systemName: "plus")
            print("here")
        }
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
