//
//  TabBarViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class TabBarViewController: UITabBarController, MiniPlayerViewDelegate {
    
    var miniPlayerView = MiniPlayerView(frame: .zero)
    var nowPlayingView = NowPlayingViewController()
    let interactor = Interactor()
    
    func showNowPlayingView() {
        print("Showing Now Playing View Controller")
        nowPlayingView.modalPresentationStyle = .fullScreen
        nowPlayingView.transitioningDelegate = self
        nowPlayingView.interactor = interactor
        present(nowPlayingView, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let home = HomeViewController()
        let search = SearchViewController()
        let library = LibraryViewController()
        
        home.title = "Playlists"
        search.title = "Search"
        library.title = "Library"
        
        home.navigationItem.largeTitleDisplayMode = .always
        search.navigationItem.largeTitleDisplayMode = .always
        library.navigationItem.largeTitleDisplayMode = .always

        let navHome = UINavigationController(rootViewController: home)
        let navSearch = UINavigationController(rootViewController: search)
        let navLibrary = UINavigationController(rootViewController: library)
        
        navHome.navigationBar.prefersLargeTitles = true
        navSearch.navigationBar.prefersLargeTitles = true
        navLibrary.navigationBar.prefersLargeTitles = true
        
        navHome.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        navSearch.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        navLibrary.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "list.bullet"), tag: 1)
        

        setViewControllers([navHome, navSearch, navLibrary], animated: false)
        addMiniPlayerView()
        miniPlayerView.delegate = self
    }
    private func addMiniPlayerView() {
        self.view.addSubview(miniPlayerView)
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        miniPlayerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        miniPlayerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        miniPlayerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.10).isActive = true
        miniPlayerView.updateDisplayedSong()
    }

}
extension TabBarViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
