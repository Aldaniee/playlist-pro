//
//  QueueSongCell.swift
//  playlist-pro
//
//  Cell to display one song inside the Queue Table View
//

import UIKit

class SongCell : UITableViewCell {
  
    static let identifier = "SongCell"
    
    static let rowHeight = CGFloat(80)
    
	var songDict = Dictionary<String, Any>()
	let albumCoverImageView: UIImageView = {
		let imgView = UIImageView()
        return imgView
	}()
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        return lbl
    }()
    let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Constants.UI.darkGray
        lbl.textAlignment = .left
        return lbl
    }()
	
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .clear
		
        self.contentView.addSubview(albumCoverImageView)
        self.contentView.addSubview(titleLabel)
		self.contentView.addSubview(artistLabel)

    }
    
    let spacing = CGFloat(20)
    let titleLabelSize = CGFloat(20)
    let artistLabelLabelSize = CGFloat(16)
    override func layoutSubviews() {
        let albumCoverImageSize = PlaylistCell.rowHeight - spacing
        albumCoverImageView.frame = CGRect(
            x: spacing/2,
            y: spacing/2,
            width: albumCoverImageSize,
            height: albumCoverImageSize)
        titleLabel.frame = CGRect(
            x: albumCoverImageView.right + spacing,
            y: spacing,
            width: width - spacing - albumCoverImageView.right,
            height: titleLabelSize
        )
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabelSize)

        artistLabel.frame = CGRect(
            x: albumCoverImageView.right + spacing,
            y: titleLabel.bottom + 5,
            width: width - spacing - albumCoverImageView.right,
            height: artistLabelLabelSize
        )
        artistLabel.font = UIFont.systemFont(ofSize: artistLabelLabelSize)


    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setDarkStyle() {
        titleLabel.textColor = .white
        artistLabel.textColor = Constants.UI.lightGray
    }
	func refreshCell() {
		self.titleLabel.text = songDict["title"] as? String
		self.artistLabel.text = (songDict["artists"] as? NSArray ?? NSArray())!.componentsJoined(by: ", ")
		let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songDict["id"] as? String ?? "").jpg"))
		if let imgData = imageData {
            self.albumCoverImageView.image = cropToBounds(image: UIImage(data: imgData)!, height: Double(SongCell.rowHeight - spacing))
		} else {
			self.albumCoverImageView.image = UIImage(named: "placeholder")
		}
        //self.durationLabel.text = songDict["duration"] as? String
		
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
