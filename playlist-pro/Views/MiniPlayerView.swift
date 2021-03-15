//
//  NowPlayingView.swift
//  Playlist Pro
//
//
//  Tab bar playback controller view
//
import UIKit


class MiniPlayerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(miniPlayerButton)
        addSubview(progressBar)
        addSubview(albumCover)
        addSubview(pausePlayButton)
        addSubview(titleLabel)
        addSubview(artistLabel)
    }

    let progressBarThumbSize = CGFloat(3)
    let titleSize = CGFloat(14)
    let artistSize = CGFloat(12)
    let spacing = CGFloat(10)
    
    override func layoutSubviews() {
        miniPlayerButton.frame = bounds
        albumCover.frame = CGRect(
            x: 0,
            y: 0,
            width: height,
            height: height
        )
        let pausePlayButtonSize = height/2
        pausePlayButton.frame = CGRect(
            x: width-spacing-pausePlayButtonSize,
            y: height/2-pausePlayButtonSize/2,
            width: pausePlayButtonSize,
            height: pausePlayButtonSize
        )
        titleLabel.frame = CGRect(
            x: albumCover.right + spacing,
            y: height/2-titleSize,
            width: pausePlayButton.left - albumCover.width - spacing,
            height: titleSize
        )
        titleLabel.font = UIFont.systemFont(ofSize: titleSize)

        artistLabel.frame = CGRect(
            x: albumCover.right + spacing,
            y: titleLabel.bottom + spacing/2,
            width: pausePlayButton.left - albumCover.width,
            height: artistSize
        )
        artistLabel.font = UIFont.systemFont(ofSize: artistSize)

        progressBar.frame = CGRect(
            x: -5,
            y: -5,
            width: width+10,
            height: 5
        )
        progressBar.setThumbImage(makeThumbImage(), for: UIControl.State.normal)

    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
	var songID = ""
    let miniPlayerButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.backgroundColor = Constants.UI.blackGray
        button.setTitleColor(.black, for: .normal)
        return button
    }()
	let albumCover: UIImageView = {
		let imgView = UIImageView()
		imgView.layer.masksToBounds = true
		return imgView
	}()
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .left
        return lbl
    }()
    let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Constants.UI.lightGray
        lbl.textAlignment = .left
        return lbl
    }()
	let pausePlayButton: UIButton = {
		let btn = UIButton()
		btn.setImage(UIImage(systemName: "play.fill"), for: UIControl.State.normal)
        btn.tintColor = .white
		return btn
	}()
    let progressBar: UISlider = {
        let pBar = UISlider()
        pBar.tintColor = Constants.UI.darkPink
        pBar.backgroundColor = .clear
        pBar.minimumTrackTintColor = Constants.UI.darkPink
        pBar.maximumTrackTintColor = Constants.UI.darkGray
        return pBar
    }()
    
    func makeThumbImage() -> UIImage {

        let thumbView = UIImageView()
        thumbView.backgroundColor = Constants.UI.darkPink
        thumbView.frame = CGRect(x: 0,
                                 y: progressBarThumbSize/2,
                                 width: progressBarThumbSize,
                                 height: progressBarThumbSize)
        let thumbImage = UIGraphicsImageRenderer(bounds: thumbView.bounds).image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
        return thumbImage
    }
}
