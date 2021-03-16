//
//  QueueSongCell.swift
//  playlist-pro
//
//  Cell to display one song inside the Queue Table View
//

import UIKit

protocol SongPlaylistCellDelegate {
    func optionsButtonTapped(tag: Int)
}

class SongPlaylistCell : UITableViewCell {
  
    var delegate: SongPlaylistCellDelegate?
    
    // Used by tableview controller to identify the cell
    static let identifier = "SongPlaylistCell"

    // Height of a cell within the table view
    static let rowHeight = CGFloat(80)
    
    // Song to be displayed
    var songDict : Dictionary<String, Any>?
    
    // Playlist to be displayed
    var playlist : Playlist?
    
    // Display image for playlist or album cover for song
	let coverImageView: UIImageView = {
		let imgView = UIImageView()
        return imgView
	}()
    // Playlist or Song title
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        return lbl
    }()
    // Artist Label or Playlist description
    let secondaryLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Constants.UI.darkGray
        lbl.textAlignment = .left
        return lbl
    }()
    // ... Options button on the right-hand side
    let optionsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("···", for: UIControl.State.normal)
        btn.setTitleColor(.black, for: UIControl.State.normal)
        btn.titleLabel!.numberOfLines = 0
        return btn
    }()
	
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .clear
		
        self.contentView.addSubview(coverImageView)
        self.contentView.addSubview(titleLabel)
		self.contentView.addSubview(secondaryLabel)
        self.contentView.addSubview(optionsButton)
        optionsButton.titleLabel!.font = UIFont.systemFont(ofSize: optionsButtonHeight)
        optionsButton.addTarget(self, action: #selector(optionsButtonAction), for: .touchUpInside)
    }
    
    let spacing = CGFloat(20)
    let titleLabelSize = CGFloat(16)
    let artistLabelLabelSize = CGFloat(12)
    let optionsButtonHeight = CGFloat(30)
    
    override func layoutSubviews() {
        let albumCoverImageSize = SongPlaylistCell.rowHeight - spacing
        coverImageView.frame = CGRect(
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
            x: coverImageView.right + spacing,
            y: spacing,
            width: optionsButton.left - spacing - coverImageView.right,
            height: titleLabelSize
        )
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabelSize)

        secondaryLabel.frame = CGRect(
            x: coverImageView.right + spacing,
            y: titleLabel.bottom + 5,
            width: optionsButton.left - spacing - coverImageView.right,
            height: artistLabelLabelSize
        )
        secondaryLabel.font = UIFont.systemFont(ofSize: artistLabelLabelSize)


    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setDarkStyle() {
        titleLabel.textColor = .white
        secondaryLabel.textColor = Constants.UI.lightGray
    }
	func refreshCell() {
        if (songDict != nil) {
            self.titleLabel.text = songDict!["title"] as? String
            self.secondaryLabel.text = (songDict!["artists"] as? NSArray ?? NSArray())!.componentsJoined(by: ", ")
            let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songDict!["id"] as? String ?? "").jpg"))
            if let imgData = imageData {
                self.coverImageView.image = UIImage(data: imgData)!.cropToSquare(size: Double(SongPlaylistCell.rowHeight - spacing))
            } else {
                self.coverImageView.image = UIImage(named: "placeholder")
            }
            //self.durationLabel.text = songDict["duration"] as? String
        }
        if (playlist != nil) {
            if playlist!.title == LibraryManager.shared.LIBRARY_KEY {
                self.titleLabel.text = LibraryManager.shared.LIBRARY_DISPLAY
                self.secondaryLabel.text = "\(LibraryManager.shared.songLibrary.songList.count) songs"
            }
            else {
                self.titleLabel.text = playlist!.title
            }
            
            if playlist!.songList.count > 0 {
                let firstSong = playlist!.songList.object(at: 0) as! Dictionary<String, Any>
                let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(firstSong["id"] as? String ?? "").jpg"))
                if let imgData = imageData {
                    self.coverImageView.image = UIImage(data: imgData)!.cropToSquare(size: 15.0)
                } else {
                    self.coverImageView.image = UIImage(systemName: "list.bullet")
                }
            }
        }
	}
    
    @objc func optionsButtonAction(_ sender: UIButton) {
        print("options pressed")
        delegate?.optionsButtonTapped(tag: sender.tag)
    }
}
