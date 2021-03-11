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
        view.addSubview(tableView)
        view.insertSubview(blurView, at: 0)

        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .clear
    }
    override func viewDidLayoutSubviews() {
        tableView.frame = view.frame
        blurView.frame = view.frame
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
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
        pBar.tintColor = Constants.UI.darkPink
        return pBar
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
        cell.songDict = QueueManager.shared.queue[indexPath.row + indexPath.section] as! Dictionary<String, Any>
        cell.refreshCell()
        cell.setDarkStyle()
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
    // Create a standard header that includes the returned text.
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        if section == 0 {
            return "Now Playing"
        }
        else {
            return "Up Next"
        }
    }

}
