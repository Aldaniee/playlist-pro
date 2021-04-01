//
//  SpotifyPlaylistCell.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/19/21.
//

import Foundation

import UIKit
import SDWebImage

class SpotifyPlaylistCell : UITableViewCell {
      
    // Used by tableview controller to identify the cell
    static let identifier = "SpotifyPlaylistCell"

    // Height of a cell within the table view
    static let rowHeight = CGFloat(70)
    
    // Display image for playlist or album cover for song
    let coverImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    // Playlist or Song title
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = .white
        lbl.numberOfLines = 1

        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.clipsToBounds = true

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
    }
    let spacing = CGFloat(20)
    let titleLabelSize = CGFloat(16)
    
    override func layoutSubviews() {
        let albumCoverImageSize = PlaylistCell.rowHeight - spacing
        coverImageView.frame = CGRect(
            x: spacing/2,
            y: spacing/2,
            width: albumCoverImageSize,
            height: albumCoverImageSize)

        titleLabel.frame = CGRect(
            x: coverImageView.right + spacing,
            y: spacing,
            width: width - spacing - coverImageView.right,
            height: titleLabelSize
        )
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabelSize)

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: SpotifyPlaylistCellViewModel) {
        titleLabel.text = viewModel.title
        coverImageView.sd_setImage(with: viewModel.imageURL, placeholderImage: UIImage(systemName: "photo"), completed: nil)
    }
}
