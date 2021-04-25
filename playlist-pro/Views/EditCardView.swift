//
//  EditCardView.swift
//  playlist-pro
//
//  Created by Aidan Lee on 4/22/21.
//

import UIKit
import MultiSlider

class EditCardView: UIView {
    
    var selectedCropThumbIndex: Int! {
        didSet {
            if selectedCropThumbIndex == 0 {
                waveFormSlider.thumbViews[0].image = EditCardView.selectedThumbImage
                waveFormSlider.thumbViews[2].image = EditCardView.unselectedThumbImage
                startTransitionButton.titleLabel!.textColor = .white
                endTransitionButton.titleLabel!.textColor = .darkGray
                startLabel.textColor = .white
                startTimeLabel.textColor = .white
                endLabel.textColor = .darkGray
                endTimeLabel.textColor = .darkGray
            }
            else if selectedCropThumbIndex == 2 {
                waveFormSlider.thumbViews[2].image = EditCardView.selectedThumbImage
                waveFormSlider.thumbViews[0].image = EditCardView.unselectedThumbImage
                endTransitionButton.titleLabel!.textColor = .white
                startTransitionButton.titleLabel!.textColor = .darkGray
                startLabel.textColor = .darkGray
                startTimeLabel.textColor = .darkGray
                endLabel.textColor = .white
                endTimeLabel.textColor = .white
            }
            else {
                waveFormSlider.thumbViews[2].image = EditCardView.unselectedThumbImage
                waveFormSlider.thumbViews[0].image = EditCardView.unselectedThumbImage
                endTransitionButton.titleLabel!.textColor = .white
                startTransitionButton.titleLabel!.textColor = .white
                print("Invalid index")
            }
        }
    }
    var selectedTransition: Int! {
        didSet {
            if selectedTransition == 0 {
                fadeButton.backgroundColor = .darkPink
                crossFadeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
                cutButton.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
            }
            else if selectedTransition == 1 {
                crossFadeButton.backgroundColor = .darkPink
                fadeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
                cutButton.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
            }
            else if selectedTransition == 2 {
                cutButton.backgroundColor = .darkPink
                fadeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
                crossFadeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
            }
            else {
                cutButton.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
                fadeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
                crossFadeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
                print("Invalid index")
            }
        }
    }

    
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
    static let unselectedThumbImage: UIImage = {
        let endThumb = UIImageView()
        endThumb.frame = CGRect(x: 0, y: 80/2, width: 10, height: 80)
        endThumb.image = UIImage(named: "unselected.thumb")
        let endThumbImage = UIGraphicsImageRenderer(bounds: endThumb.bounds).image { rendererContext in
            endThumb.layer.render(in: rendererContext.cgContext)
        }
        return endThumbImage
    }()
    static let selectedThumbImage: UIImage = {
        let endThumb = UIImageView()
        endThumb.frame = CGRect(x: 0, y: 80/2, width: 10, height: 80)
        endThumb.image = UIImage(named: "selected.thumb")
        let endThumbImage = UIGraphicsImageRenderer(bounds: endThumb.bounds).image { rendererContext in
            endThumb.layer.render(in: rendererContext.cgContext)
        }
        return endThumbImage
    }()
    let waveFormSlider: MultiSlider = {
        let horizontalMultiSlider = MultiSlider()
        horizontalMultiSlider.orientation = .horizontal
        horizontalMultiSlider.minimumValue = 0
        horizontalMultiSlider.maximumValue = 1
        horizontalMultiSlider.outerTrackColor = .gray
        horizontalMultiSlider.value = [0, 0.5, 1]
        horizontalMultiSlider.valueLabelColor = .clear
        horizontalMultiSlider.tintColor = .clear
        horizontalMultiSlider.trackWidth = 0
        horizontalMultiSlider.showsThumbImageShadow = false
        horizontalMultiSlider.thumbViews[0].image = selectedThumbImage
        horizontalMultiSlider.thumbViews[1].image = currentPositionThumbImage
        horizontalMultiSlider.thumbViews[2].image = unselectedThumbImage
        return horizontalMultiSlider
    }()
    let waveFormView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    let progressWaveFormView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    let cropWaveFormView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    let startLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Start"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .darkGray
        return lbl
    }()
    let startTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "0:00"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .darkGray
        return lbl
    }()
    let endLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "End"
        lbl.textAlignment = .right
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .darkGray
        return lbl
    }()
    let endTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "0:00"
        lbl.textAlignment = .right
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .darkGray
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
        selectedCropThumbIndex = 0
        selectedTransition = 2
        // MARK: Edit Card
        self.addSubview(queueButton)
        // Edit button
        editButton.addSubview(editButtonTextLabel)
        editButtonTextLabel.font = .systemFont(ofSize: editButtonTextSize)
        editButton.addSubview(editButtonImageView)
        // Lower Card
        self.addSubview(timelineLabel)
        self.addSubview(editButton)
        self.addSubview(cropWaveFormView)
        self.addSubview(waveFormView)
        self.addSubview(progressWaveFormView)
        // Horizontal Sldier
        self.addConstrainedSubview(waveFormSlider, constrain: .leftMargin, .rightMargin, .topMargin)

        //self.addSubview(positionSlider)
        
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
        
        startTransitionButton.addTarget(self, action: #selector(startTransitionAction), for: .touchUpInside)
        endTransitionButton.addTarget(self, action: #selector(endTransitionAction), for: .touchUpInside)
        fadeButton.addTarget(self, action: #selector(fadeAction), for: .touchUpInside)
        crossFadeButton.addTarget(self, action: #selector(crossFadeAction), for: .touchUpInside)
        cutButton.addTarget(self, action: #selector(cutAction), for: .touchUpInside)
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
        self.layoutMargins = UIEdgeInsets(
            top: timelineLabel.bottom + spacing-10,
            left: edgePadding-5,
            bottom: 0,
            right: edgePadding-5
        )

        cropWaveFormView.frame = CGRect(
            x: edgePadding,
            y: timelineLabel.bottom + spacing/4,
            width: self.width-spacing,
            height: sliderHeight
        )
        waveFormView.frame = cropWaveFormView.frame
        progressWaveFormView.frame = waveFormView.frame

        startLabel.frame = CGRect(
            x: waveFormView.left,
            y: waveFormView.bottom,
            width: 40,
            height: 15
        )
        endLabel.frame = CGRect(
            x: waveFormView.right - 40,
            y: startLabel.top,
            width: 40,
            height: 15
        )
        startTimeLabel.frame = CGRect(
            x: waveFormView.left,
            y: endLabel.bottom + 3,
            width: 40,
            height: 15
        )
        endTimeLabel.frame = CGRect(
            x: waveFormView.right - 40,
            y: startTimeLabel.top,
            width: 40,
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
        let cropWaveformConfig = WaveformConfiguration(size: waveFormView.bounds.size, backgroundColor: .clear, style: .striped(.blackGray), position: .middle, scale: UIScreen.main.scale, paddingFactor: nil, stripeWidth: 5, stripeSpacing: 10, shouldAntialias: false)
        waveformImageDrawer.waveformImage(fromAudioAt: waveformURL!,
                                          with: cropWaveformConfig) { image in
            
            // need to jump back to main queue
            DispatchQueue.main.async {
                self.cropWaveFormView.image = image
            }
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
            
            DispatchQueue.main.async {
                self.progressWaveFormView.image = image
            }
        }
    }
    
    func updateWaveforms(startCrop: CGFloat, progress: CGFloat, endCrop: CGFloat) {
        let width = progressWaveFormView.width
        
        let startCropX = startCrop * width
        let progressWidth = width * progress - startCropX
        
        let progressRect = CGRect(x: startCropX, y: 0.0, width: progressWidth, height: waveFormView.height)
        let progressLayer = CAShapeLayer()
        progressLayer.path = CGPath(rect: progressRect, transform: nil)
        progressWaveFormView.layer.mask = progressLayer

        let endCropX = endCrop * width
        let baseX = startCropX + progressWidth
        let baseWidth = endCropX - baseX
        let baseRect = CGRect(x: baseX, y: 0.0, width: baseWidth, height: waveFormView.height)
        let baseLayer = CAShapeLayer()
        baseLayer.path = CGPath(rect: baseRect, transform: nil)
        waveFormView.layer.mask = baseLayer
    }
    
    @objc func startTransitionAction() {
        selectedCropThumbIndex = 0
    }
    @objc func endTransitionAction() {
        selectedCropThumbIndex = 2
    }
    @objc func fadeAction() {
        selectedTransition = 0
    }
    @objc func crossFadeAction() {
        selectedTransition = 1
    }
    @objc func cutAction() {
        selectedTransition = 2
    }
}
