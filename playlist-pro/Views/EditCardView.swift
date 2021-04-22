//
//  EditCardView.swift
//  playlist-pro
//
//  Created by Aidan Lee on 4/22/21.
//

import UIKit

class EditCardView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let queueButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.imageView!.contentMode = .scaleAspectFit
        btn.setImage(UIImage(systemName: "list.bullet"), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    let editButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.tintColor = .white
        return btn
    }()
    let editButtonTextLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "EDIT TRACK"
        lbl.textAlignment = .center
        lbl.backgroundColor = .clear
        lbl.textColor = .white
        return lbl
    }()
    
    let editButtonImageView: UIImageView = {
        let imgView = UIImageView()
        let font = UIFont.boldSystemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        imgView.image = UIImage(systemName: "chevron.up", withConfiguration: configuration)
        imgView.tintColor = .darkPink
        return imgView
    }()
    let editSliderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Timeline"
        lbl.numberOfLines = 0
        lbl.backgroundColor = .clear
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    let editSlider: CustomSlider = {
        let pBar = CustomSlider()
        pBar.tintColor = .darkPink
        pBar.backgroundColor = .clear
        pBar.minimumTrackTintColor = .darkPink
        pBar.maximumTrackTintColor = .lightGray
        let thumbView = UIImageView()
        thumbView.backgroundColor = .darkPink
        let editBarThumbHeight = CGFloat(60)
        let editBarThumbWidth = CGFloat(3)
        thumbView.frame = CGRect(x: 0,
                                 y: editBarThumbWidth/2,
                                 width: editBarThumbWidth,
                                 height: editBarThumbHeight)
        let thumbImage = UIGraphicsImageRenderer(bounds: thumbView.bounds).image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
        pBar.setThumbImage(thumbImage, for: UIControl.State.normal)
        return pBar
    }()
    let queueButtonSize = CGFloat(20)
    let editButtonSize = CGFloat(38)
    let editButtonTextSize = CGFloat(18)
    let editButtonImageViewSize = CGFloat(10)
    let editBarHeight = CGFloat(60)
    let spacing: CGFloat = 40
    let edgePadding: CGFloat = 20 // spacing/2
    let editLabelHeight = CGFloat(14)

    override init(frame: CGRect) {
        super.init(frame: frame)
        // MARK: Edit Card
        self.addSubview(queueButton)
        
        // Edit button
        editButton.addSubview(editButtonTextLabel)
        editButtonTextLabel.font = UIFont.systemFont(ofSize: editButtonTextSize)
        editButton.addSubview(editButtonImageView)
        self.addSubview(editSliderLabel)
        self.addSubview(editSlider)
        self.addSubview(editButton)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        queueButton.frame = CGRect(x: edgePadding,
                                   y: editButtonSize/2-queueButtonSize/2,
                                   width: queueButtonSize,
                                   height: queueButtonSize)
        let editButtonWidth = editButtonSize*3.5
        editButton.frame = CGRect(x: self.center.x-editButtonWidth/2,
                                  y: 0,
                                  width: editButtonWidth,
                                  height: editButtonSize)
        editButtonTextLabel.frame = CGRect(x: 0,
                                           y: 0,
                                           width: editButtonWidth,
                                           height: editButtonTextSize)
        let editButtonImageViewWidth = editButtonImageViewSize*1.5
        editButtonImageView.frame = CGRect(x: editButtonWidth/2-editButtonImageViewWidth/2,
                                           y: editButtonTextLabel.bottom + spacing/4,
                                           width: editButtonImageViewWidth,
                                           height: editButtonImageViewSize)
        editSliderLabel.frame = CGRect(
            x: edgePadding,
            y: editButton.bottom + spacing,
            width: self.width-spacing,
            height: editLabelHeight
        )
        editSlider.frame = CGRect(
            x: edgePadding,
            y: editSliderLabel.bottom + spacing,
            width: self.width-spacing,
            height: editBarHeight
        )
    }
}
