//
//  QueueSongCell.swift
//  playlist-pro
//
//  Cell to display one song inside the Queue Table View
//

import UIKit

protocol SongCellDelegate {
    func optionsButtonTapped(tag: Int)
}

class SongCell : UITableViewCell {
  
    var delegate: SongCellDelegate?
    
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
    let optionsButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
	
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .clear
		
        self.contentView.addSubview(albumCoverImageView)
        self.contentView.addSubview(titleLabel)
		self.contentView.addSubview(artistLabel)
        self.contentView.addSubview(optionsButton)
        optionsButton.titleLabel!.numberOfLines = 0
        optionsButton.titleLabel!.font = UIFont.systemFont(ofSize: optionsButtonHeight)
        optionsButton.setTitle("···", for: UIControl.State.normal)
        optionsButton.setTitleColor(.black, for: UIControl.State.normal)
        optionsButton.addTarget(self, action: #selector(optionsButtonAction), for: .touchUpInside)

    }
    
    let spacing = CGFloat(20)
    let titleLabelSize = CGFloat(16)
    let artistLabelLabelSize = CGFloat(12)
    let optionsButtonHeight = CGFloat(30)
    
    override func layoutSubviews() {
        let albumCoverImageSize = PlaylistCell.rowHeight - spacing
        albumCoverImageView.frame = CGRect(
            x: spacing/2,
            y: spacing/2,
            width: albumCoverImageSize,
            height: albumCoverImageSize)
        let optionsButtonWidth = optionsButtonHeight*2
        optionsButton.frame = CGRect(
            x: width-optionsButtonWidth,
            y: height/2-optionsButtonHeight/2,
            width: optionsButtonWidth,
            height: optionsButtonHeight
        )
        titleLabel.frame = CGRect(
            x: albumCoverImageView.right + spacing,
            y: spacing,
            width: optionsButton.left - spacing - albumCoverImageView.right,
            height: titleLabelSize
        )
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabelSize)

        artistLabel.frame = CGRect(
            x: albumCoverImageView.right + spacing,
            y: titleLabel.bottom + 5,
            width: optionsButton.left - spacing - albumCoverImageView.right,
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
            self.albumCoverImageView.image = UIImage(data: imgData)!.cropToSquare(size: Double(SongCell.rowHeight - spacing))
		} else {
			self.albumCoverImageView.image = UIImage(named: "placeholder")
		}
        //self.durationLabel.text = songDict["duration"] as? String
		
	}
    
    @objc func optionsButtonAction(_ sender: UIButton) {
        print("song options pressed")
        delegate?.optionsButtonTapped(tag: sender.tag)
    }
}
