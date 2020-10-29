//
//  ViewController.swift
//  youtube-onedaybuild
//
//  Created by Aidan Lee on 10/27/20.
//

import UIKit

class ViewController: UIViewController {

    var model = Model()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        model.getVideos()
    }


}

