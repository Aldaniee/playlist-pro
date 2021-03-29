//
//  AccountSettingsCell.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/29/21.
//

import UIKit

struct AccountCellModel {
    let title: String
    let subtitle: String
    let handler: (() -> Void)
}

class AccountSettingsCell : UITableViewCell {
  
    // Used by tableview controller to identify the cell
    static let identifier = "AccountCell"

    // Height of a cell within the table view
    static let rowHeight = CGFloat(60)
    
    var accountCellModel : AccountCellModel?
    
    // Playlist or Song title
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .blackGray
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(secondaryLabel)
    }
    
    let spacing = CGFloat(20)
    let titleLabelSize = CGFloat(16)
    let secondaryLabelSize = CGFloat(12)
    let optionsButtonHeight = CGFloat(30)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(
            x: contentView.left + spacing,
            y: spacing/2,
            width: contentView.width - spacing,
            height: titleLabelSize+3
        )
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabelSize)

        secondaryLabel.frame = CGRect(
            x: titleLabel.left + spacing/2,
            y: titleLabel.bottom + 5,
            width: contentView.width - spacing,
            height: secondaryLabelSize+3
        )
        secondaryLabel.font = UIFont.systemFont(ofSize: secondaryLabelSize)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func refreshCell() {
        titleLabel.text = accountCellModel?.title ?? "error"
        secondaryLabel.text = accountCellModel?.subtitle ?? "error"
    }
}
