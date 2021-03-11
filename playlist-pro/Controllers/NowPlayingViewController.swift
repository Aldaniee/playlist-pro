//
//  SongViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/17/21.
//

import UIKit

class NowPlayingViewController: UIViewController {
    
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

    var interactor: Interactor? = nil
    
    // MARK: Background
    let blurView : UIVisualEffectView = {
        let vis = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        vis.translatesAutoresizingMaskIntoConstraints = false
        return vis
    }()
    // MARK: Tab Bar
    let closeButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        let font = UIFont.systemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        btn.setImage(UIImage(systemName: "chevron.down", withConfiguration: configuration), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    let tabBarTitle: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.backgroundColor = .clear
        lbl.textAlignment = .center
        lbl.text = "Now Playing"
        lbl.textColor = .white
        return lbl
    }()
    let optionsButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.tintColor = .white
        return btn
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
        lbl.textColor = Constants.UI.darkGray
        lbl.textAlignment = .left
        return lbl
    }()

    let progressBar: UISlider = {
        let pBar = UISlider()
        pBar.tintColor = Constants.UI.darkPink
        pBar.backgroundColor = .clear
        pBar.minimumTrackTintColor = Constants.UI.darkPink
        pBar.maximumTrackTintColor = Constants.UI.darkGray
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
        imgView.tintColor = Constants.UI.darkPink
        return imgView
    }()
    /*let playbackRateButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = Constants.UI.orange
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        btn.setTitle("x1", for: .normal)
        return btn
    }()*/
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.UI.blackGray
        //overlayView.addGestureRecognizer(UIPanGestureRecognizer(target:self, action: #selector(handleGesture)))

        //view.addSubview(overlayView)
        
        // MARK: Tab Bar
        view.addSubview(closeButton)
        view.addSubview(tabBarTitle)
        tabBarTitle.font = UIFont.boldSystemFont(ofSize: tabBarHeight)
        view.addSubview(optionsButton)
        optionsButton.titleLabel!.numberOfLines = 0
        optionsButton.titleLabel!.font = UIFont.systemFont(ofSize: tabBarHeight)
        optionsButton.setTitle("···", for: UIControl.State.normal)


        
        // MARK: Playback Display
        view.addSubview(albumCoverImageView)
        view.addSubview(progressBar)
        let thumbView = UIImageView()
        thumbView.backgroundColor = Constants.UI.darkPink

        thumbView.frame = CGRect(x: 0, y: progressBarThumbWidth/2, width: progressBarThumbWidth, height: progressBarThumbHeight)
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
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let edgePadding = spacing/2

        // MARK: Tab Bar
        let topToTabBarMiddle = CGFloat(70)
        let closeButtonWidth = tabBarHeight*closeButtonScaleConstant
        closeButton.frame = CGRect(
            x: edgePadding,
            y: topToTabBarMiddle-tabBarHeight/2,
            width: closeButtonWidth,
            height: tabBarHeight
        )
        tabBarTitle.frame = CGRect(
            x: spacing + closeButtonWidth,
            y: topToTabBarMiddle-tabBarHeight/2,
            width: view.width-spacing-closeButtonWidth-tabBarHeight-spacing,
            height: tabBarHeight
        )
        optionsButton.frame = CGRect(
            x: view.width-edgePadding-tabBarHeight,
            y: topToTabBarMiddle-tabBarHeight/2,
            width: tabBarHeight,
            height: tabBarHeight
        )
        
        // MARK: Playback View
        let tabBarTitleBottomToAlbumTop = CGFloat(52)
        
        albumCoverImageView.frame = CGRect(x: edgePadding,
                                          y: tabBarTitle.bottom + tabBarTitleBottomToAlbumTop,
                                          width: view.width - spacing,
                                          height: view.width - spacing)
        songTitleLabel.frame = CGRect(x: edgePadding,
                                  y: albumCoverImageView.bottom + spacing,
                                  width: view.width-spacing,
                                  height: tabBarHeight)
        artistLabel.frame = CGRect(x: edgePadding,
                                   y: songTitleLabel.bottom + 5,
                                   width: view.width-spacing,
                                   height: artistLabelHeight)
        progressBar.frame = CGRect(x: edgePadding,
                                   y: songTitleLabel.bottom + spacing,
                                   width: view.width-spacing,
                                   height: progressBarHeight)
        let timeLabelWidth = timeLabelSize*timeLabelScaleConstant
        let progressBarToTimeLabels = spacing/4
        currentTimeLabel.frame = CGRect(x: progressBar.left,
                                        y: progressBar.bottom+progressBarToTimeLabels,
                                        width: timeLabelWidth,
                                        height: timeLabelSize)
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
    
    /*private func addPlaybackRateButton() {
        playbackRateButton.addTarget(self, action: #selector(playbackRateButtonAction), for: .touchUpInside)
        songControlView.addSubview(playbackRateButton)
        playbackRateButton.translatesAutoresizingMaskIntoConstraints = false
        playbackRateButton.leadingAnchor.constraint(equalTo: timeLeftLabel.trailingAnchor, constant: 2.5).isActive = true
        playbackRateButton.trailingAnchor.constraint(equalTo: songControlView.trailingAnchor, constant: -2.5).isActive = true
        playbackRateButton.centerYAnchor.constraint(equalTo: songControlView.centerYAnchor).isActive = true
        playbackRateButton.heightAnchor.constraint(equalTo: songControlView.heightAnchor).isActive = true

    }*/

    /*
    @objc func handleGesture(sender: UIPanGestureRecognizer) {

        let percentThreshold:CGFloat = 0.3

        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }*/

}
