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
    let songTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.backgroundColor = .clear
        lbl.textColor = .white
        lbl.textAlignment = .left
        return lbl
    }()
    let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.backgroundColor = .clear
        lbl.textColor = .darkGray
        lbl.textAlignment = .left
        return lbl
    }()

    let progressBar: CustomSlider = {
        let pBar = CustomSlider()
        pBar.tintColor = .darkPink
        pBar.backgroundColor = .clear
        pBar.minimumTrackTintColor = .darkPink
        pBar.maximumTrackTintColor = .darkGray
        return pBar
    }()

    // MARK: Playback Controls
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
    // MARK: Bottom Bar
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
        imgView.image = UIImage(systemName: "chevron.down", withConfiguration: configuration)
        imgView.tintColor = .darkPink
        return imgView
    }()
    /*let playbackRateButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .orange
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        btn.setTitle("x1", for: .normal)
        return btn
    }()*/
    let spacing = CGFloat(40)

    // MARK: Tab Bar
    let tabBarHeight = CGFloat(18)
    let closeButtonScaleConstant = CGFloat(1.5)
    // MARK: Playback Display
    let artistLabelHeight = CGFloat(14)
    let progressBarHeight = CGFloat(5)
    let progressBarThumbHeight = CGFloat(20)
    let progressBarThumbWidth = CGFloat(3)
    let pausePlaySize = CGFloat(80)
    let nextPrevSize = CGFloat(30)
    let repeatShuffleSize = CGFloat(20)
    // MARK: Playback Controls
    let timeLabelSize = CGFloat(10)
    let timeLabelScaleConstant = CGFloat(3.5)
    // MARK: Bottom Bar
    let queueButtonSize = CGFloat(20)
    let editButtonSize = CGFloat(38)
    let editButtonTextSize = CGFloat(18)
    let editButtonImageViewSize = CGFloat(10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blackGray
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        // MARK: Playback Display
        view.addSubview(albumCoverImageView)
        view.addSubview(progressBar)
        let thumbView = UIImageView()
        thumbView.backgroundColor = .darkPink

        thumbView.frame = CGRect(x: 0,
                                 y: progressBarThumbWidth/2,
                                 width: progressBarThumbWidth,
                                 height: progressBarThumbHeight)
        let thumbImage = UIGraphicsImageRenderer(bounds: thumbView.bounds).image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
        progressBar.setThumbImage(thumbImage, for: UIControl.State.normal)
        view.addSubview(songTitleLabel)
        
        songTitleLabel.font = UIFont.boldSystemFont(ofSize: tabBarHeight)
        view.addSubview(artistLabel)
        artistLabel.font = UIFont.systemFont(ofSize: artistLabelHeight)

        view.addSubview(currentTimeLabel)
        currentTimeLabel.font = UIFont.boldSystemFont(ofSize: timeLabelSize)
        view.addSubview(timeLeftLabel)
        timeLeftLabel.font = UIFont.boldSystemFont(ofSize: timeLabelSize)

        
        // MARK: Playback Controls
        view.addSubview(shuffleButton)
        view.addSubview(repeatButton)
        view.addSubview(pausePlayButton)
        view.addSubview(previousButton)
        view.addSubview(nextButton)

        // MARK: Bottom Bar
        view.addSubview(queueButton)
        view.addSubview(editButton)
        editButton.addSubview(editButtonTextLabel)
        editButtonTextLabel.font = UIFont.systemFont(ofSize: editButtonTextSize)
        editButton.addSubview(editButtonImageView)
        albumCoverImageView.frame = CGRect(
            x: -50,
            y: 0,
            width: view.width+100,
            height: view.width+100
        )
    }
    
    func presentAnimations() {
        self.albumCoverImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let edgePadding = spacing/2

        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 47
        statusBarBackground.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: statusBarHeight
        )
        // MARK: Playback View
        songTitleLabel.frame = CGRect(
            x: edgePadding,
            y: albumCoverImageView.bottom + spacing,
            width: view.width-spacing,
            height: tabBarHeight
        )
        artistLabel.frame = CGRect(
            x: edgePadding,
            y: songTitleLabel.bottom + 5,
            width: view.width-spacing,
            height: artistLabelHeight
        )
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
        
        // MARK: Playback Controls
        let progressBarToControlsCenterLineSpacing = progressBar.bottom+spacing*2
        
        shuffleButton.frame = CGRect(x: progressBar.left,
                                     y: progressBarToControlsCenterLineSpacing-repeatShuffleSize/2,
                                     width: repeatShuffleSize,
                                     height: repeatShuffleSize)
        repeatButton.frame = CGRect(x: progressBar.right-repeatShuffleSize,
                                    y: progressBarToControlsCenterLineSpacing-repeatShuffleSize/2,
                                    width: repeatShuffleSize,
                                    height: repeatShuffleSize)
        pausePlayButton.frame = CGRect(x: view.center.x-pausePlaySize/2,
                                       y: progressBarToControlsCenterLineSpacing-pausePlaySize/2,
                                       width: pausePlaySize,
                                       height: pausePlaySize)
        let pausePlayToPrevNextSpacing = spacing*2
        previousButton.frame = CGRect(x: view.center.x-pausePlayToPrevNextSpacing-nextPrevSize,
                                       y: progressBarToControlsCenterLineSpacing-nextPrevSize/2,
                                       width: nextPrevSize,
                                       height: nextPrevSize)
        nextButton.frame = CGRect(x: view.center.x + pausePlayToPrevNextSpacing,
                                       y: progressBarToControlsCenterLineSpacing-nextPrevSize/2,
                                       width: nextPrevSize,
                                       height: nextPrevSize)
        let playPauseBottomToBottomBar = CGFloat(60)
        // MARK: Bottom Bar
        queueButton.frame = CGRect(x: edgePadding,
                                   y: pausePlayButton.bottom + playPauseBottomToBottomBar - queueButtonSize/2,
                                   width: queueButtonSize,
                                   height: queueButtonSize)
        let editButtonWidth = editButtonSize*3.5
        editButton.frame = CGRect(x: view.center.x-editButtonWidth/2,
                                  y: pausePlayButton.bottom + playPauseBottomToBottomBar - editButtonTextSize/2,
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
    }
    

    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways, only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        let scale = 1 + ((translation.y) / view.height)
        print(scale)
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
