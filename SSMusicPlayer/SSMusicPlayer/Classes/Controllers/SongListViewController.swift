//
//  SongListViewController.swift
//  SSMusicPlayer
//
//  Created by Santosh Kumar Sahoo on 5/22/17.
//
//

import UIKit
import AVFoundation

class SongListViewController: UIViewController {

    @IBOutlet weak fileprivate var tableView: UITableView!
    
    fileprivate var album: Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 76
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.title = "SSMusicPlayer"
        getAlbum()
    }
}
//MARK: - Private methods

fileprivate extension SongListViewController {

    // This method will get the album which contains a list of song
    func getAlbum() {
        let activityIndicatorView = MainActivityIndicatorView.getMainActivityIndicatorView()
        activityIndicatorView?.showView(view)
        NetworkManager.getAlbumWith {[weak self] (album: Album?, error: NSError?) in
            if let error = error {
                if error.code == Error_Code_NoInternet_Connection {
                    let noInternetView = NoInternetView.getNoInternetView(with: self)
                    noInternetView?.showView(self?.view)
                    activityIndicatorView?.hideView()
                } else {
                    let alert = UIAlertView(title: "Error !", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                print(error.localizedDescription)
            } else if let album = album {
                self?.album = album
                activityIndicatorView?.hideView()
                self?.tableView.reloadData()
            }
        }
    }
}

//MARK: - TableViewDataSource methods
extension SongListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return album?.songs.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MusicTrackCell.getCellIdentifier() , for: indexPath) as! MusicTrackCell
        cell.configureCellWith(album?.songs[indexPath.row])
        return cell
    }
}

//MARK: - TableViewDelegate methods
extension SongListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = MusicPlayerViewController.getViewController(with: album, andSongIndex: indexPath.row)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

//MARK: - NoInternetDelegate method
extension SongListViewController: NoInternetDelegate {
    func noInternetView(_ view: UIView?, didSelectRefreshButton isTapped: Bool) {
        view?.removeFromSuperview()
        getAlbum()
    }
}
