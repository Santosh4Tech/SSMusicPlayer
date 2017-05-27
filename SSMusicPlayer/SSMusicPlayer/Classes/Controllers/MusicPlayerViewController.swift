//
//  MusicPlayerViewController.swift
//  SSMusicPlayer
//
//  Created by Santosh Kumar Sahoo on 5/20/17.
//
//

import UIKit
import AVFoundation
import MediaPlayer
import SDWebImage

class MusicPlayerViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak fileprivate var progressSlider: UISlider!
    @IBOutlet weak fileprivate var playButton: UIButton!
    @IBOutlet weak fileprivate var musicImageView: UIImageView!
    @IBOutlet weak fileprivate var startDurationLabel: UILabel!
    @IBOutlet weak fileprivate var endDurationLabel: UILabel!
    
    
    //MARK: - Properties
    fileprivate var player: AVAudioPlayer?
    fileprivate var album: Album?
    fileprivate var currentTrackIndex = 0
    lazy var audioSession = AVAudioSession.sharedInstance()
    fileprivate var timer: Timer?
    
    //MARK: - ViewLife cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            
        }
        queueTrack(nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        player = nil
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event, event.type == .remoteControl {
            switch event.subtype {
            case .remoteControlPlay:
                play()
            case .remoteControlPause:
                pause()
            case .remoteControlNextTrack:
                nextSong(songFinishedPlaying: false)
            case .remoteControlPreviousTrack:
                previousSong()
            default:
                break
            }
        }
    }
    
    //MARK: - class method

    /// Call this method to get the instance of Current Class
    ///
    /// - Parameters:
    ///   - album: Music album which contains a list of song
    ///   - index: Currently playing song index
    /// - Returns: instance of MusicPlayerViewController
    class func getViewController(with album: Album?, andSongIndex index: Int) -> MusicPlayerViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicPlayerViewController") as! MusicPlayerViewController
        viewController.album = album
        viewController.currentTrackIndex = index
        return viewController
    }
    
    
    
    func sliderViewSetup(_ song: Song) {
        progressSlider.maximumValue = Float(song.duration)
        endDurationLabel.text = getFormattedTimeAsString(isForDuration: true)
        progressSlider.minimumValue = Float(player?.currentTime ?? 0.0)
    }
    
    func updateProgressBar() {
        if player?.isPlaying == true {
            progressSlider.setValue(Float(player?.currentTime ?? 0.0), animated: true)
            startDurationLabel.text = getFormattedTimeAsString(isForDuration: false)
        }
    }
    
    //MARK: - IBAction methods
    @IBAction func didTapPlayButton(_ sender: UIButton) {
        if player?.isPlaying == true {
            pause()
            timer?.invalidate()
        } else {
            play()
            startTimer()
        }
    }
    
    @IBAction func didTapNextTrackButton(_ sender: UIButton) {
        nextSong(songFinishedPlaying: false)
        startTimer()
    }
    
    @IBAction func didTapPreviousTrackButton(_ sender: UIButton) {
        previousSong()
        startTimer()
    }
    
    @IBAction func didDragSlider(_ sender: UISlider) {
        player?.currentTime = TimeInterval(sender.value)
    }
    
}

//MARK: - private method
fileprivate extension MusicPlayerViewController {
    
    /// Will play the current track
    func play() {
        if player?.isPlaying == false {
            playButton.isSelected = true
            player?.play()
        }
    }
    
    /// will pause the current track
    func pause() {
        if player?.isPlaying == true {
            playButton.isSelected = false
            player?.pause()
        }
    }
    
    
    /// Will do required work to play next song
    ///
    /// - Parameter songFinishedPlaying: it will true if song is finished
    func nextSong(songFinishedPlaying:Bool){
        var playerWasPlaying = false
        if player?.isPlaying == true {
            //playButton.isSelected = false
            player?.stop()
            playerWasPlaying = true
        }
        currentTrackIndex += 1
        if currentTrackIndex >= (album?.songs.count ?? 0) {
            currentTrackIndex = 0
        }
        queueTrack {[weak self] (success: Bool) in
            if success {
                if playerWasPlaying || songFinishedPlaying {
                    self?.play()
                }
            } else {
                let alert = UIAlertView(title: "Error", message: "Unable to load the song.", delegate: nil, cancelButtonTitle: "Cancel")
                alert.show()
            }
        }
    }
    
    
    /// Will create the player object for each song
    ///
    /// - Parameter handler: execute when download get finish
    func queueTrack(_ handler: ((_ success: Bool)-> Void)?) {
        let activityIndicatorView = MainActivityIndicatorView.getMainActivityIndicatorView()
        activityIndicatorView?.showView(view)
        if let song = album?.songs[currentTrackIndex] {
            if (player != nil) {
                player = nil
            }
            navigationItem.title = song.name ?? ""
            musicImageView.setImageFromUrlPath(song.iconUrl)
            NetworkManager.fetchData(from: song.songUrl, completionHandler: {[weak self] (data: Data?, error: NSError?) in
                activityIndicatorView?.hideView()
                if let error = error {
                    if error.code == Error_Code_NoInternet_Connection {
                        let noInternetView = NoInternetView.getNoInternetView(with: self)
                        noInternetView?.showView(self?.view)
                    } else {
                        let alert = UIAlertView(title: "Error !", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    print(error)
                } else if let soundData = data {
                    do {
                        self?.player = try AVAudioPlayer(data: soundData)
                        self?.player?.prepareToPlay()
                        self?.player?.delegate = self
                        var dict = [String:Any]()
                        dict[MPMediaItemPropertyTitle] = song.name
                        dict[MPMediaItemPropertyPlaybackDuration] = song.duration
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = dict
                        self?.sliderViewSetup(song)
                        handler?(true)
                    } catch {
                        handler?(false)
                        print("error")
                    }
                }
            })
        }
    }
    
    /// Will do required work to play previous song
    func previousSong() {
        var playerWasPlaying = false
        if player?.isPlaying == true {
            player?.stop()
            playerWasPlaying = true
        }
        currentTrackIndex -= 1
        if currentTrackIndex < 0 {
            currentTrackIndex = (album?.songs.count ?? 0) - 1
        }
        queueTrack {[weak self] (sucess: Bool) in
            if sucess {
                if playerWasPlaying {
                    self?.play()
                }
            } else {
                let alert = UIAlertView(title: "Error", message: "Unable to load the song.", delegate: nil, cancelButtonTitle: "Cancel")
                alert.show()
            }
        }
    }
    
    /// Convenience method to get the current time & duration of plyer
    ///
    /// - Returns: current time in string
    func getFormattedTimeAsString(isForDuration: Bool) -> String {
        var seconds = 0
        var minutes = 0
        if let time = isForDuration ? player?.duration : player?.currentTime {
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    
    /// This will start timer to update slider bar
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
    }

}

//MARK: - AVAudioPlayerDelegate methods
extension MusicPlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        nextSong(songFinishedPlaying: true)
    }
}

//MARK: - NoInternetDelegate method
extension MusicPlayerViewController: NoInternetDelegate {
    func noInternetView(_ view: UIView?, didSelectRefreshButton isTapped: Bool) {
        view?.removeFromSuperview()
        queueTrack(nil)
    }
}

