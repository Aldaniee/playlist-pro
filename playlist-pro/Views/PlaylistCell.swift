//
//  PlaylistCell.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/18/21.
//
//  Cell controller for cells within the PlaylistViewController tab, each holding and representing one playlist

import UIKit

class PlaylistCell : UITableViewCell {
    
    // Used by tableview controller to identify the cell
    static let identifier = "PlaylistCell"
    
    // Height of a cell within the table view
    static let rowHeight = CGFloat(80)
    
    // Playlist to be displayed
    var playlist : Playlist!
    
    // Display image for playlist
    let playlistCoverImageView: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    // Playlist title
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        return lbl
    }()
    // Playlist description
    let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = Constants.UI.darkGray
        return lbl
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        
        self.contentView.addSubview(playlistCoverImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descriptionLabel)

    }
    
    let spacing = CGFloat(20)
    let titleLabelSize = CGFloat(20)
    let descriptionLabelSize = CGFloat(16)

    override func layoutSubviews() {
        let thumbnailImageSize = PlaylistCell.rowHeight - spacing
        playlistCoverImageView.frame = CGRect(
            x: spacing/2,
            y: spacing/2,
            width: thumbnailImageSize,
            height: thumbnailImageSize)
        titleLabel.frame = CGRect(
            x: playlistCoverImageView.right + spacing,
            y: spacing,
            width: width - spacing - playlistCoverImageView.right,
            height: titleLabelSize
        )
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabelSize)
        
        descriptionLabel.frame = CGRect(
            x: playlistCoverImageView.right + spacing,
            y: titleLabel.bottom + 5,
            width: width - spacing - playlistCoverImageView.right,
            height: descriptionLabelSize
        )
        descriptionLabel.font = UIFont.systemFont(ofSize: descriptionLabelSize)


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshCell() {
        if playlist.title == LibraryManager.shared.LIBRARY_KEY {
            self.titleLabel.text = LibraryManager.shared.LIBRARY_DISPLAY
            self.descriptionLabel.text = "\(LibraryManager.shared.songLibrary.getSongList().count) songs"
        }
        else {
            self.titleLabel.text = playlist.title
        }
        
        if playlist.count() > 0 {
            let firstSong = playlist.getSongList().object(at: 0) as! Dictionary<String, Any>
            let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(firstSong["id"] as? String ?? "").jpg"))
            if let imgData = imageData {
                self.playlistCoverImageView.image = cropToBounds(image: UIImage(data: imgData)!, height: 15.0)
            } else {
                self.playlistCoverImageView.image = UIImage(systemName: "list.bullet")
            }
        }
        else {
            self.playlistCoverImageView.image = UIImage(systemName: "list.bullet")
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
