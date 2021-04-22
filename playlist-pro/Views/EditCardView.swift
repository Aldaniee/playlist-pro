//
//  EditCardView.swift
//  playlist-pro
//
//  Created by Aidan Lee on 4/22/21.
//

import UIKit

class EditCardView: UIView {
    
    var waveformURL: URL?
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
    
    static let currentPositionThumbImage: UIImage = {
        let currentPositionThumb = UIImageView()
        currentPositionThumb.backgroundColor = .clear
        currentPositionThumb.frame = CGRect(x: 0, y: 60/2, width: 3, height: 60)
        let currentPositionThumbImage = UIGraphicsImageRenderer(bounds: currentPositionThumb.bounds).image { rendererContext in
            currentPositionThumb.layer.render(in: rendererContext.cgContext)
        }
        return currentPositionThumbImage
    }()
    
    static let endThumbImage: UIImage = {
        let endThumb = UIImageView()
        endThumb.backgroundColor = .white
        endThumb.frame = CGRect(x: 0, y: 80/2, width: 3, height: 80)
        let endThumbImage = UIGraphicsImageRenderer(bounds: endThumb.bounds).image { rendererContext in
            endThumb.layer.render(in: rendererContext.cgContext)
        }
        return endThumbImage
    }()
    
    let positionSlider: CustomSlider = {
        let slider = CustomSlider()
        slider.tintColor = .clear
        slider.backgroundColor = .clear
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.setThumbImage(currentPositionThumbImage, for: UIControl.State.normal)
        return slider
    }()
    let waveFormView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    let progressWaveFormView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    let queueButtonSize = CGFloat(20)
    let editButtonSize = CGFloat(38)
    let editButtonTextSize = CGFloat(18)
    let editButtonImageViewSize = CGFloat(10)
    let sliderHeight = CGFloat(85)
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
        self.addSubview(editButton)
        self.addSubview(waveFormView)
        self.addSubview(progressWaveFormView)
        self.addSubview(positionSlider)

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
        positionSlider.frame = CGRect(
            x: edgePadding,
            y: editSliderLabel.bottom + spacing/2,
            width: self.width-spacing,
            height: sliderHeight
        )
        waveFormView.frame = positionSlider.frame
        progressWaveFormView.frame = positionSlider.frame

        displayWaveForm()
    }
    
    func displayWaveForm() {
        let waveformImageDrawer = WaveformImageDrawer()
        if waveformURL == nil {
            return
        }
        let waveformConfig = WaveformConfiguration(size: waveFormView.bounds.size, backgroundColor: .clear, style: .striped(.darkGray), position: .middle, scale: UIScreen.main.scale, paddingFactor: nil, stripeWidth: 5, stripeSpacing: 10, shouldAntialias: false)
        waveformImageDrawer.waveformImage(fromAudioAt: waveformURL!,
                                          with: waveformConfig) { image in
            
            DispatchQueue.main.async {
                self.waveFormView.image = image
            }
        }
        let progressWaveformConfig = WaveformConfiguration(size: waveFormView.bounds.size, backgroundColor: .clear, style: .striped(.darkPink), position: .middle, scale: UIScreen.main.scale, paddingFactor: nil, stripeWidth: 5, stripeSpacing: 10, shouldAntialias: false)
        waveformImageDrawer.waveformImage(fromAudioAt: waveformURL!,
                                          with: progressWaveformConfig) { image in
            
            // need to jump back to main queue
            DispatchQueue.main.async {
                self.progressWaveFormView.image = image
            }
        }
    }
    func updateProgressWaveform(_ progress: Double) {
        let newWidth = Double(progressWaveFormView.width) * progress
        
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(waveFormView.height))
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path

        progressWaveFormView.layer.mask = maskLayer
    }
}
