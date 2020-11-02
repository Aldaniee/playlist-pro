//
//  DetailViewController.swift
//  youtube-onedaybuild
//
//  Created by Aidan Lee on 11/2/20.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var textView: UITextView!
    
    var video: Video?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Clear the feilds
        titleLabel.text = ""
        dateLabel.text = ""
        textView.text = ""
        
        // Check if there's a video
        guard video != nil else {
            return
        }
        // Create the embed URL
        let embedUrlString = Constants.YT_EMBED_URL + video!.videoId
        
        // Load it into the webview
        let url = URL(string: embedUrlString)
        let request = URLRequest(url: url!)
        webView.load(request)
        
        // Set the title
        titleLabel.text = video!.title
        
        // Set the date
        dateLabel.text = DateHelper.getFormattedDate(video!.published)
        
        // Set the Description
        textView.text = video?.description
    }


}
