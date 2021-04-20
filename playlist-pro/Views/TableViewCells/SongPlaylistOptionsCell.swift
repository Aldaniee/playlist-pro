//
//  SongOptionsCell.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/14/21.
//

import UIKit

class SongPlaylistOptionsCell: UITableViewCell {
    
    static let identifier = "SongOptionsCell"
    
    var model : SongPlaylistOptionsCellModel!
    
    let symbolImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.tintColor = .lightGray
        return imgView
    }()
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = .lightGray
        return lbl
    }()
    
    let spacing = CGFloat(20)
    let titleLabelSize = CGFloat(20)
    let symbolSize = CGFloat(30)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        
        self.contentView.addSubview(symbolImageView)
        self.contentView.addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: titleLabelSize)

    }
    override func layoutSubviews() {
        symbolImageView.frame = CGRect(
            x: spacing*2,
            y: contentView.height/2 - symbolSize/2,
            width: symbolSize,
            height: symbolSize
        )
        let titleLabelX = symbolImageView.right + spacing/2
        titleLabel.frame = CGRect(
            x: titleLabelX,
            y: contentView.height/2 - titleLabelSize/2,
            width: contentView.width - titleLabelX,
            height: titleLabelSize+3
        )
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func refreshCell() {
        self.symbolImageView.image = model.symbol
        self.titleLabel.text = model.title        
    }
}
