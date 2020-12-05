//
//  SpotifyImportViewController.swift
//  youtube-onedaybuild
//
//  Created by Aidan Lee on 12/5/20.
//

import UIKit
import SwiftUI

class SpotifyImportViewController: UIViewController {
    
    let spotify = Spotify()
    static let animation = Animation.spring()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spotify.authorize()
    }
    
}
