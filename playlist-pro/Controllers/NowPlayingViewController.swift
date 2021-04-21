//
//  SongViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/17/21.
//

import UIKit

class NowPlayingViewController: UIViewController {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var editMode = false {
        didSet {
            if editMode {
                UIView.animate(withDuration: 0.25) {
                    self.songControlPane.transform = CGAffineTransform(translationX: 0, y: -250)
                    self.albumCoverImageView.transform = CGAffineTransform(translationX: 0, y: -50)
                    self.editButtonImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                    self.progressBar.alpha = 0.0
                    self.timeLeftLabel.alpha = 0.0
                    self.currentTimeLabel.alpha = 0.0
                    
                    self.playbackControls.transform = CGAffineTransform(translationX: 0, y: -50)
                    self.editCard.transform = CGAffineTransform(translationX: 0, y: -80)

                }
            }
            else {
                UIView.animate(withDuration: 0.25) {
                    self.songControlPane.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.albumCoverImageView.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.editButtonImageView.transform = CGAffineTransform(rotationAngle: 0)
                    self.progressBar.alpha = 1.0
                    self.timeLeftLabel.alpha = 1.0
                    self.currentTimeLabel.alpha = 1.0
                    
                    self.playbackControls.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.editCard.transform = CGAffineTransform(translationX: 0, y: 0)

                }
            }
        }
    }
    
    // MARK: Background
    let statusBarBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .blackGray
        view.alpha = 0.5
        return view
    }()
    
    let blurView : UIVisualEffectView = {
        let vis = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        vis.translatesAutoresizingMaskIntoConstraints = false
        return vis
    }()
    // MARK: Playback Display
    let albumCoverImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.masksToBounds = true
        return imgView
    }()
    let songControlPane: UIView = {
        let view = UIView()
        view.backgroundColor = .blackGray
        return view
    }()
    let songTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.backgroundColor = .clear
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.backgroundColor = .clear
        lbl.textColor = .darkGray
        lbl.textAlignment = .center
        return lbl
    }()
    
    
    let progressBar: CustomSlider = {
        let pBar = CustomSlider()
        pBar.tintColor = .darkPink
        pBar.backgroundColor = .clear
        pBar.minimumTrackTintColor = .darkPink
        pBar.maximumTrackTintColor = .lightGray
        let thumbView = UIImageView()
        thumbView.backgroundColor = .darkPink
        let progressBarThumbHeight = CGFloat(20)
        let progressBarThumbWidth = CGFloat(3)
        thumbView.frame = CGRect(x: 0,
                                 y: progressBarThumbWidth/2,
                                 width: progressBarThumbWidth,
                                 height: progressBarThumbHeight)
        let thumbImage = UIGraphicsImageRenderer(bounds: thumbView.bounds).image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
        pBar.setThumbImage(thumbImage, for: UIControl.State.normal)

        return pBar
    }()
    let currentTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.backgroundColor = .clear
        lbl.textColor = .white
        return lbl
    }()
    let timeLeftLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.backgroundColor = .clear
        lbl.textColor = .white
        return lbl
    }()
    // MARK: Playback Controls
    let playbackControls = UIView()
    let pausePlayButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        let font = UIFont.systemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        btn.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    let previousButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        let font = UIFont.systemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        btn.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: configuration), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    let nextButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        let font = UIFont.systemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        btn.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: configuration), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    let repeatButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.imageView!.contentMode = .scaleAspectFit
        let font = UIFont.systemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        btn.setImage(UIImage(systemName: "repeat", withConfiguration: configuration), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    let shuffleButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        let font = UIFont.systemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        btn.setImage(UIImage(systemName: "shuffle", withConfiguration: configuration), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    // MARK: Edit Card
    let editCard = UIView()
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
    
    /*let playbackRateButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .orange
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        btn.setTitle("x1", for: .normal)
        return btn
    }()*/
    let spacing: CGFloat = 40
    let edgePadding: CGFloat = 20 // spacing/2
    // MARK: Tab Bar
    let tabBarHeight = CGFloat(18)
    let closeButtonScaleConstant = CGFloat(1.5)
    // MARK: Playback Display
    let artistLabelHeight = CGFloat(14)
    let pausePlaySize = CGFloat(80) // also height of playbackControls view
    let nextPrevSize = CGFloat(30)
    let repeatShuffleSize = CGFloat(20)
    // MARK: Playback Controls
    let progressBarHeight = CGFloat(5)
    let timeLabelSize = CGFloat(10)
    let timeLabelScaleConstant = CGFloat(3.5)
    // MARK: Edit Bar
    let queueButtonSize = CGFloat(20)
    let editButtonSize = CGFloat(38)
    let editButtonTextSize = CGFloat(18)
    let editButtonImageViewSize = CGFloat(10)
    let editBarHeight = CGFloat(60)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blackGray
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
        
        // MARK: Playback Display
        view.addSubview(albumCoverImageView)
        view.addSubview(songControlPane)
        songControlPane.addSubview(songTitleLabel)
        songControlPane.addSubview(artistLabel)
        songTitleLabel.font = UIFont.boldSystemFont(ofSize: tabBarHeight)
        artistLabel.font = UIFont.systemFont(ofSize: artistLabelHeight)
        
        songControlPane.addSubview(progressBar)
        songControlPane.addSubview(currentTimeLabel)
        songControlPane.addSubview(timeLeftLabel)
        currentTimeLabel.font = UIFont.boldSystemFont(ofSize: timeLabelSize)
        timeLeftLabel.font = UIFont.boldSystemFont(ofSize: timeLabelSize)

        
        // MARK: Playback Controls
        playbackControls.addSubview(shuffleButton)
        playbackControls.addSubview(repeatButton)
        playbackControls.addSubview(pausePlayButton)
        playbackControls.addSubview(previousButton)
        playbackControls.addSubview(nextButton)
        
        songControlPane.addSubview(editCard)
        songControlPane.addSubview(playbackControls)

        // MARK: Edit Card
        editCard.addSubview(queueButton)
        
        // Edit button
        editButton.addSubview(editButtonTextLabel)
        editButtonTextLabel.font = UIFont.systemFont(ofSize: editButtonTextSize)
        editButton.addSubview(editButtonImageView)
        editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        editCard.addSubview(editSliderLabel)
        editCard.addSubview(editSlider)
        //editSlider.setThumbImage(thumbImage, for: UIControl.State.normal)
        editCard.addSubview(editButton)

        albumCoverImageView.frame = CGRect(
            x: -50,
            y: 0,
            width: view.width+100,
            height: view.width+100
        )
        songControlPane.frame = CGRect(
            x: 0,
            y: albumCoverImageView.bottom,
            width: view.width,
            height: view.height
        )
        layoutTitles()
        
        progressBar.frame = CGRect(
            x: edgePadding,
            y: songTitleLabel.bottom + spacing,
            width: view.width-spacing,
            height: progressBarHeight
        )
        
        let timeLabelWidth = timeLabelSize*timeLabelScaleConstant
        let progressBarToTimeLabels = spacing/4
        currentTimeLabel.frame = CGRect(
            x: progressBar.left,
            y: progressBar.bottom+progressBarToTimeLabels,
            width: timeLabelWidth,
            height: timeLabelSize
        )
        timeLeftLabel.frame = CGRect(x: progressBar.right-timeLabelWidth,
                                     y: progressBar.bottom+progressBarToTimeLabels,
                                     width: timeLabelWidth,
                                     height: timeLabelSize)
        
        let progressBarToPlaybackControls = spacing*2 - pausePlaySize/2
        
        playbackControls.frame = CGRect(
            x: 0,
            y: progressBar.bottom+progressBarToPlaybackControls,
            width: view.width,
            height: pausePlaySize
        )
        
        layoutPlaybackControls()
        
        let playbackControlsToEditCard = CGFloat(60)
        
        // MARK: Edit Card
        editCard.frame = CGRect(
            x: 0,
            y: playbackControls.bottom + playbackControlsToEditCard,
            width: view.width,
            height: songControlPane.height-playbackControls.bottom+playbackControlsToEditCard
        )
        queueButton.frame = CGRect(x: edgePadding,
                                   y: editButtonSize/2-queueButtonSize/2,
                                   width: queueButtonSize,
                                   height: queueButtonSize)
        let editButtonWidth = editButtonSize*3.5
        editButton.frame = CGRect(x: editCard.center.x-editButtonWidth/2,
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
            width: view.width-spacing,
            height: artistLabelHeight
        )
        editSlider.frame = CGRect(
            x: edgePadding,
            y: editSliderLabel.bottom + spacing,
            width: view.width-spacing,
            height: editBarHeight
        )
    }
    private func layoutTitles() {
        songTitleLabel.frame = CGRect(
            x: edgePadding,
            y: spacing,
            width: view.width-spacing,
            height: tabBarHeight
        )
        artistLabel.frame = CGRect(
            x: edgePadding,
            y: songTitleLabel.bottom + 5,
            width: view.width-spacing,
            height: artistLabelHeight
        )
    }
    private func layoutPlaybackControls() {
        // MARK: Playback Controls
        shuffleButton.frame = CGRect(x: progressBar.left,
                                     y: playbackControls.height/2-repeatShuffleSize/2,
                                     width: repeatShuffleSize,
                                     height: repeatShuffleSize)
        repeatButton.frame = CGRect(x: progressBar.right-repeatShuffleSize,
                                    y: playbackControls.height/2-repeatShuffleSize/2,
                                    width: repeatShuffleSize,
                                    height: repeatShuffleSize)
        pausePlayButton.frame = CGRect(x: view.center.x-pausePlaySize/2,
                                       y: playbackControls.height/2-pausePlaySize/2,
                                       width: pausePlaySize,
                                       height: pausePlaySize)
        let pausePlayToPrevNextSpacing = spacing*2
        previousButton.frame = CGRect(x: view.center.x-pausePlayToPrevNextSpacing-nextPrevSize,
                                       y: playbackControls.height/2-nextPrevSize/2,
                                       width: nextPrevSize,
                                       height: nextPrevSize)
        nextButton.frame = CGRect(x: view.center.x + pausePlayToPrevNextSpacing,
                                       y: playbackControls.height/2-nextPrevSize/2,
                                       width: nextPrevSize,
                                       height: nextPrevSize)
    }
    
    func presentAnimations() {
        self.albumCoverImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        editMode = false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc func editButtonAction() {
        print("Edit button pressed")
        editMode = !editMode
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways, only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)

        let scale = 1 + (translation.y / view.height)
        albumCoverImageView.transform = CGAffineTransform(scaleX: scale, y: scale)

        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.albumCoverImageView.transform = CGAffineTransform(scaleX: 1, y: 1)

                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 0)
                }
            }
        }
    }
    /*private func addPlaybackRateButton() {
        playbackRateButton.addTarget(self, action: #selector(playbackRateButtonAction), for: .touchUpInside)
        songControlView.addSubview(playbackRateButton)
        playbackRateButton.translatesAutoresizingMaskIntoConstraints = false
        playbackRateButton.leadingAnchor.constraint(equalTo: timeLeftLabel.trailingAnchor, constant: 2.5).isActive = true
        playbackRateButton.trailingAnchor.constraint(equalTo: songControlView.trailingAnchor, constant: -2.5).isActive = true
        playbackRateButton.centerYAnchor.constraint(equalTo: songControlView.centerYAnchor).isActive = true
        playbackRateButton.heightAnchor.constraint(equalTo: songControlView.heightAnchor).isActive = true

    }*/

}
