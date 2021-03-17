//
//  QueueViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/18/21.
//

import UIKit

class QueueViewController: UIViewController {
    
    let spacing = CGFloat(30)
    let tableViewDist = CGFloat(160)
    let pausePlaySize = CGFloat(80)
    let nextPrevSize = CGFloat(30)
    let repeatShuffleSize = CGFloat(20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.insertSubview(blurView, at: 0)

        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .clear
        
        // MARK: Playback Controls
        view.addSubview(shuffleButton)
        view.addSubview(repeatButton)
        view.addSubview(pausePlayButton)
        view.addSubview(previousButton)
        view.addSubview(nextButton)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(
            x: 0, y: 0, width: view.width, height: view.height - tableViewDist
        )
        blurView.frame = view.frame
        
        // MARK: Playback Controls
        let playbackCenter = view.bottom - tableViewDist/2
        pausePlayButton.frame = CGRect(
            x: view.center.x - pausePlaySize/2,
            y: playbackCenter - (pausePlaySize/2),
            width: pausePlaySize,
            height: pausePlaySize
        )
        nextButton.frame = CGRect(
            x: pausePlayButton.right + spacing,
            y: playbackCenter - nextPrevSize/2,
            width: nextPrevSize,
            height: nextPrevSize
        )
        previousButton.frame = CGRect(
            x: pausePlayButton.left - nextPrevSize - spacing,
            y: playbackCenter - nextPrevSize/2,
            width: nextPrevSize,
            height: nextPrevSize
        )
        shuffleButton.frame = CGRect(
            x: previousButton.left - repeatShuffleSize - spacing,
            y: playbackCenter - repeatShuffleSize/2,
            width: repeatShuffleSize,
            height: repeatShuffleSize
        )
        repeatButton.frame = CGRect(
            x: nextButton.right + spacing,
            y: playbackCenter - repeatShuffleSize/2,
            width: repeatShuffleSize,
            height: repeatShuffleSize
        )
        
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongPlaylistCell.self, forCellReuseIdentifier: SongPlaylistCell.identifier)
        tableView.backgroundColor = .clear

        return tableView
    }()
    let blurView : UIVisualEffectView = {
        let vis = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        vis.translatesAutoresizingMaskIntoConstraints = false
        return vis
    }()
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textAlignment = .left
        return lbl
    }()
    let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Constants.UI.darkGray
        lbl.font = UIFont.systemFont(ofSize: 18)
        lbl.textAlignment = .left
        return lbl
    }()
    let previousButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.imageView!.contentMode = .scaleAspectFit
        let font = UIFont.systemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        btn.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: configuration), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    let pausePlayButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.imageView!.contentMode = .scaleAspectFit
        let font = UIFont.systemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        btn.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    let nextButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.imageView!.contentMode = .scaleAspectFit
        let font = UIFont.systemFont(ofSize: 999) // max size so the icon scales to the image frame
        let configuration = UIImage.SymbolConfiguration(font: font)
        btn.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: configuration), for: UIControl.State.normal)
        btn.tintColor = .white
        return btn
    }()
    let closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "xmark"), for: UIControl.State.normal)
        return btn
    }()

    let progressBar: UISlider = {
        let pBar = UISlider()
        pBar.tintColor = Constants.UI.darkPink
        return pBar
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
    
}
extension QueueViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        print("here")
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
            case 0:
                return 1
            default:
                print(QueueManager.shared.queue.count - 1)
                return QueueManager.shared.queue.count - 1
         }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongPlaylistCell.identifier, for: indexPath) as! SongPlaylistCell
        cell.songDict = QueueManager.shared.queue[indexPath.row + indexPath.section] as? Dictionary<String, Any>
        cell.refreshCell()
        cell.setDarkStyle()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SongPlaylistCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SongPlaylistCell

        print("Selected cell number \(indexPath.row) -> \(cell.songDict!["title"] ?? "")")
        
        QueueManager.shared.didSelectSong(songDict: cell.songDict!)
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            QueueManager.shared.queue.removeObject(at: (QueueManager.shared.queue.count - 2 - indexPath.row) % QueueManager.shared.queue.count)
            tableView.reloadData()
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor = .clear
        var title = "Next From: \(QueueManager.shared.currentPlaylist?.title ?? "")"
        if section == 0 {
            title = "Now Playing"
        }
        let label: UILabel = {
            let lbl = UILabel()
            lbl.textColor = .white
            lbl.font = UIFont.boldSystemFont(ofSize: 18)
            lbl.textAlignment = .left
            lbl.text = title
            return lbl
        }()
        headerView.addSubview(label)
        label.frame = CGRect(x: 10, y: 10, width: headerView.width, height: 18)
        return headerView
    }
}
