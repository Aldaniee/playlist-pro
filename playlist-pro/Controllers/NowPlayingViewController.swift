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
    var albumCoverImage: UIImage = UIImage(){
        didSet {
            self.albumCoverImageView.image = albumCoverImage
            self.backgroundAlbum.image = albumCoverImage.sd_rotatedImage(withAngle: CGFloat(Double.pi), fitSize: false)
        }
    }
    var editMode = false {
        didSet {
            if editMode {
                UIView.animate(withDuration: 0.25) {
                    self.songControlPane.transform = CGAffineTransform(translationX: 0, y: -250)
                    self.albumCoverImageView.transform = CGAffineTransform(translationX: 0, y: -50)
                    self.editCardView.editButtonImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                    self.progressBar.alpha = 0.0
                    self.timeLeftLabel.alpha = 0.0
                    self.currentTimeLabel.alpha = 0.0
                    
                    self.playbackControls.transform = CGAffineTransform(translationX: 0, y: -50)
                    self.editCardView.transform = CGAffineTransform(translationX: 0, y: -80)

                }
            }
            else {
                UIView.animate(withDuration: 0.25) {
                    self.songControlPane.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.albumCoverImageView.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.editCardView.editButtonImageView.transform = CGAffineTransform(rotationAngle: 0)
                    self.progressBar.alpha = 1.0
                    self.timeLeftLabel.alpha = 1.0
                    self.currentTimeLabel.alpha = 1.0
                    
                    self.playbackControls.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.editCardView.transform = CGAffineTransform(translationX: 0, y: 0)

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
        return view
    }()
    let backgroundAlbum: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    let grayOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    let blurOverlay: UIVisualEffectView = {
        let vis = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
        vis.translatesAutoresizingMaskIntoConstraints = false
        return vis
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
        let slider = CustomSlider()
        slider.tintColor = .darkPink
        slider.backgroundColor = .clear
        slider.minimumTrackTintColor = .darkPink
        slider.maximumTrackTintColor = .lightGray
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
        slider.setThumbImage(thumbImage, for: UIControl.State.normal)

        return slider
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
    let editCardView = EditCardView(frame: .zero)
    
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
        songControlPane.addSubview(backgroundAlbum)
        songControlPane.addSubview(grayOverlay)
        songControlPane.addSubview(blurOverlay)

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
        
        songControlPane.addSubview(editCardView)
        songControlPane.addSubview(playbackControls)
        
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
        grayOverlay.frame = songControlPane.bounds
        blurOverlay.frame = songControlPane.bounds

        backgroundAlbum.frame = songControlPane.bounds

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
        editCardView.editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        editCardView.frame = CGRect(
            x: 0,
            y: playbackControls.bottom + playbackControlsToEditCard,
            width: view.width,
            height: songControlPane.height-playbackControls.bottom+playbackControlsToEditCard
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

    @objc func editButtonAction() {
        print("Edit button pressed")
        editMode = !editMode
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways, only want straight up oupdater down
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
}
