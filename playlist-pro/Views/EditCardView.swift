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
    let timelineLabel: UILabel = {
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
    let startLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Start"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .gray
        return lbl
    }()
    let startTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "0:00"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .gray
        return lbl
    }()
    let endLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "End"
        lbl.textAlignment = .right
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .gray
        return lbl
    }()
    let endTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "0:00"
        lbl.textAlignment = .right
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .gray
        return lbl
    }()
    let editTransitionsLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Edit Transitions"
        lbl.numberOfLines = 0
        lbl.backgroundColor = .clear
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    let startTransitionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Start Transition", for: .normal)
        btn.titleLabel!.font = .systemFont(ofSize: 14)
        btn.titleLabel!.textColor = .white
        btn.contentHorizontalAlignment = .right
        return btn
    }()
    
    let endTransitionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("End Transition", for: .normal)
        btn.titleLabel!.font = .systemFont(ofSize: 14)
        btn.titleLabel!.textColor = .white
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    let fadeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Fade", for: .normal)
        btn.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        btn.titleLabel!.font = .systemFont(ofSize: 12)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5
        btn.titleLabel!.textColor = .white
        return btn
    }()
    
    let crossFadeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cross-fade", for: .normal)
        btn.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        btn.titleLabel!.font = .systemFont(ofSize: 12)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5
        btn.titleLabel!.textColor = .white
        return btn
    }()
    
    let cutButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cut", for: .normal)
        btn.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        btn.titleLabel!.font = .systemFont(ofSize: 12)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5
        btn.titleLabel!.textColor = .white
        return btn
    }()
    
    let queueButtonSize = CGFloat(20)
    let editButtonSize = CGFloat(38)
    let editButtonTextSize = CGFloat(18)
    let editButtonImageViewSize = CGFloat(10)
    let sliderHeight = CGFloat(85)
    let spacing: CGFloat = 40
    let edgePadding: CGFloat = 20 // spacing/2
    let editLabelHeight = CGFloat(14)
    let startEndTransitionButtonHeight: CGFloat = 12
    let transitionButtonHeight: CGFloat = 20

    override init(frame: CGRect) {
        super.init(frame: frame)
        // MARK: Edit Card
        self.addSubview(queueButton)
        
        // Edit button
        editButton.addSubview(editButtonTextLabel)
        editButtonTextLabel.font = .systemFont(ofSize: editButtonTextSize)
        editButton.addSubview(editButtonImageView)
        self.addSubview(timelineLabel)
        self.addSubview(editButton)
        self.addSubview(waveFormView)
        self.addSubview(progressWaveFormView)
        self.addSubview(positionSlider)
        
        self.addSubview(startLabel)
        self.addSubview(startTimeLabel)
        self.addSubview(endLabel)
        self.addSubview(endTimeLabel)
        
        self.addSubview(editTransitionsLabel)
        self.addSubview(startTransitionButton)
        self.addSubview(endTransitionButton)
        self.addSubview(fadeButton)
        self.addSubview(crossFadeButton)
        self.addSubview(cutButton)

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
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
        queueButton.frame = CGRect(x: edgePadding,
                                   y: editButtonTextSize/2-queueButtonSize/2,
                                   width: queueButtonSize,
                                   height: queueButtonSize)
        timelineLabel.frame = CGRect(
            x: edgePadding,
            y: editButton.bottom + spacing,
            width: self.width-spacing,
            height: editLabelHeight
        )
        positionSlider.frame = CGRect(
            x: edgePadding,
            y: timelineLabel.bottom + spacing/4,
            width: self.width-spacing,
            height: sliderHeight
        )
        waveFormView.frame = positionSlider.frame
        progressWaveFormView.frame = positionSlider.frame

        startLabel.frame = CGRect(
            x: waveFormView.left,
            y: waveFormView.bottom,
            width: 30,
            height: 15
        )
        endLabel.frame = CGRect(
            x: waveFormView.right - 30,
            y: startLabel.top,
            width: 30,
            height: 15
        )
        startTimeLabel.frame = CGRect(
            x: waveFormView.left,
            y: endLabel.bottom + 3,
            width: 30,
            height: 15
        )
        endTimeLabel.frame = CGRect(
            x: waveFormView.right - 30,
            y: startTimeLabel.top,
            width: 30,
            height: 15
        )
        editTransitionsLabel.frame = CGRect(
            x: edgePadding,
            y: endTimeLabel.bottom,
            width: self.width-spacing,
            height: editLabelHeight
        )
        startTransitionButton.frame = CGRect(
            x: 0,
            y: editTransitionsLabel.bottom+10,
            width: self.width/2-5,
            height: transitionButtonHeight+3
        )
        endTransitionButton.frame = CGRect(
            x: startTransitionButton.right+10,
            y: editTransitionsLabel.bottom+10,
            width: self.width/2-5,
            height: transitionButtonHeight+3
        )
        crossFadeButton.frame = CGRect(
            x: self.width/2-40,
            y: endTransitionButton.bottom+5,
            width: 80,
            height: transitionButtonHeight
        )
        fadeButton.frame = CGRect(
            x: crossFadeButton.left - 40 - 10,
            y: endTransitionButton.bottom+5,
            width: 40,
            height: transitionButtonHeight
        )
        cutButton.frame = CGRect(
            x: crossFadeButton.right + 10,
            y: endTransitionButton.bottom+5,
            width: 40,
            height: transitionButtonHeight
        )
        
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
