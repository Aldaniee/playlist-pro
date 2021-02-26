//
//  QueueViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/18/21.
//

import UIKit

class QueueViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        closeButton.addTarget(self, action: #selector(dismiss(animated:completion:)), for: .touchUpInside)

        view.addSubview(closeButton)

        tableView.frame = view.frame
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
    }
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
        return tableView
    }()
    
    var songID = ""
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textAlignment = .left
        return lbl
    }()
    let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Constants.UI.gray
        lbl.font = UIFont.systemFont(ofSize: 18)
        lbl.textAlignment = .left
        return lbl
    }()
    let previousButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "previous"), for: UIControl.State.normal)
        return btn
    }()
    let pausePlayButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        return btn
    }()
    let nextButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "next"), for: UIControl.State.normal)
        return btn
    }()
    let closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "xmark"), for: UIControl.State.normal)
        return btn
    }()

    let progressBar: UISlider = {
        let pBar = UISlider()
        pBar.tintColor = Constants.UI.gray
        return pBar
    }()
    
    func updateDisplayedSong() {
        let displayedSong: Dictionary<String, Any>
        if QueueManager.shared.queue.count > 0 {
            QueueManager.shared.unsuspend()
            displayedSong = QueueManager.shared.queue.object(at: 0) as! Dictionary<String, Any>
        } else {
            QueueManager.shared.suspend()
            displayedSong = Dictionary<String, Any>()
        }

        let songID = displayedSong["id"] as? String ?? ""
        self.songID = songID
        titleLabel.text = displayedSong["title"] as? String ?? ""
        artistLabel.text = ((displayedSong["artists"] as? NSArray ?? NSArray())!.componentsJoined(by: ", "))

        progressBar.value = 0.0
    }
}
extension QueueViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        QueueManager.shared.queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
        cell.songDict = QueueManager.shared.queue[indexPath.row] as! Dictionary<String, Any>
        cell.refreshCell()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SongCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SongCell

        print("Selected cell number \(indexPath.row) -> \(cell.songDict["title"] ?? "")")
        
        QueueManager.shared.didSelectSong(songDict: cell.songDict)
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            QueueManager.shared.queue.removeObject(at: (QueueManager.shared.queue.count - 2 - indexPath.row) % QueueManager.shared.queue.count)
            tableView.reloadData()
        }
    }
}
