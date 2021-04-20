//
//  SongCell.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/17/21.
//

import UIKit

protocol SongCellDelegate {
    func optionsButtonTapped(tag: Int)
}

class SongCell : UITableViewCell {
  
    var delegate: SongCellDelegate?
    
    // Used by tableview controller to identify the cell
    static let identifier = "SongCell"

    // Height of a cell within the table view
    static let rowHeight = CGFloat(60)
    
    // Song to be displayed
    var song : Song?
    
    // Background view for selection color
    let pressedBackgroundView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
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
        lbl.textColor = .darkGray
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
        self.selectedBackgroundView = pressedBackgroundView
        self.contentView.addSubview(coverImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(secondaryLabel)
        self.contentView.addSubview(optionsButton)
        optionsButton.titleLabel!.font = UIFont.systemFont(ofSize: optionsButtonHeight)
        optionsButton.addTarget(self, action: #selector(optionsButtonAction), for: .touchUpInside)
    }
    
    let spacing = CGFloat(20)
    let titleLabelSize = CGFloat(12)
    let artistLabelLabelSize = CGFloat(9)
    let optionsButtonHeight = CGFloat(20)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .clear

        let albumCoverImageSize = SongCell.rowHeight - spacing
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
        let labelsCenter = coverImageView.center.y
        titleLabel.frame = CGRect(
            x: coverImageView.right + spacing/2,
            y: labelsCenter - titleLabelSize - 1,
            width: optionsButton.left - spacing - coverImageView.right,
            height: titleLabelSize+3
        )
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabelSize)

        secondaryLabel.frame = CGRect(
            x: coverImageView.right + spacing/2,
            y: titleLabel.bottom + 2,
            width: optionsButton.left - spacing - coverImageView.right,
            height: artistLabelLabelSize+3
        )
        secondaryLabel.font = UIFont.systemFont(ofSize: artistLabelLabelSize)


    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setDarkStyle() {
        titleLabel.textColor = .white
        secondaryLabel.textColor = .lightGray
        contentView.backgroundColor = .clear
        self.selectedBackgroundView = pressedBackgroundView
        optionsButton.setTitleColor(.white, for: .normal)
    }
    func refreshCell() {
        if (song != nil) {
            self.titleLabel.text = song!.title
            self.secondaryLabel.text = (NSArray(array: song!.artists).componentsJoined(by: ", "))
            if let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(song!.id).jpg")) {
                self.coverImageView.image = UIImage(data: imageData)!.cropToSquare(sideLength: Double(SongCell.rowHeight - spacing))
            }
            else {
                self.coverImageView.image = UIImage(systemName: "music.note.house")
            }
        }
    }
    
    @objc func optionsButtonAction(_ sender: UIButton) {
        print("options pressed")
        delegate?.optionsButtonTapped(tag: sender.tag)
    }
}
