//
//  DetailMediaPlayerView.swift
//  Depo
//
//  Created by Konstantin Studilin on 09.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
import Player

final class DetailMediaPlayerView: UIView, FromNib {

    @IBOutlet weak var playerContainerView: UIView! {
        willSet {
            newValue.backgroundColor = .clear
            newValue.addSubview(mediaPlayer.view)
        }
    }
    @IBOutlet private weak var playbackControlsView: UIView! {
        willSet {
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var playPauseButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.imageView?.contentMode = .scaleAspectFit
            newValue.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    @IBOutlet private weak var timeAfter: UILabel! {
        willSet {
            newValue.text = "00:00"
            newValue.font = .GTAmericaStandardMediumFont(size: 12)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var timeBefore: UILabel! {
        willSet {
            newValue.text = "00:00"
            newValue.font = .GTAmericaStandardMediumFont(size: 12)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var progressSlider: UISlider! {
        willSet {
            newValue.isContinuous = false
            newValue.maximumValue = 1.0
            newValue.minimumValue = 0.0
            newValue.setValue(0, animated: false)
            newValue.tintColor = .white
            newValue.thumbTintColor = .white
            newValue.isUserInteractionEnabled = false
            newValue.addTarget(self, action: #selector(seekWithSliderRatio), for: .valueChanged)
        }
    }
    
    private lazy var mediaPlayer: Player = {
        let player = Player()
        
        player.fillMode = .resizeAspect
        player.playbackLoops = true
        
        player.playerDelegate = self
        player.playbackDelegate = self

        return player
    }()
    
    
    //MARK: Override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let containerView = setupFromNib()
        
        containerView.backgroundColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let containerView = setupFromNib()
        containerView.backgroundColor = .black
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mediaPlayer.view.frame = playerContainerView.bounds
    }
    
    
    //MARK: Public
    
  
    func addPlayer(on controller: UIViewController) {
        controller.addChildViewController(mediaPlayer)
        controller.didMove(toParentViewController: controller)
    }
    
    func set(url: URL) {
        mediaPlayer.url = url
    }
    
    func play() {
        if mediaPlayer.url != nil {
            mediaPlayer.playFromCurrentTime()
        }
    }
    
    func pause() {
        mediaPlayer.pause()
    }
    
    func stop() {
        mediaPlayer.stop()
        mediaPlayer.url = nil
    }
    
    //MARK: Private
    
    @IBAction func onPlayPause(_ sender: Any) {
        switch mediaPlayer.playbackState {
            case .playing:
                pause()
                
            case .paused, .stopped:
                play()
                
            case .failed:
                return
        }
    }
    
    @objc
    private func seekWithSliderRatio() {
        let time = mediaPlayer.maximumDuration * Double(progressSlider.value)
        mediaPlayer.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
}

extension DetailMediaPlayerView: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        progressSlider.isUserInteractionEnabled = true
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        switch mediaPlayer.playbackState {
            case .playing:
                playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                
            case .paused, .stopped:
                playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                
            case .failed:
                playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        
    }
}


extension DetailMediaPlayerView: PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
        let afterStart = player.currentTimeInterval
        let beforeEnd = player.maximumDuration - player.currentTimeInterval
        let ratio = Float(afterStart / player.maximumDuration)
            
        timeAfter.text = afterStart.playbackTime
        timeBefore.text = beforeEnd.playbackTime
        if !progressSlider.isTracking {
            progressSlider.setValue(ratio, animated: false)
        }
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        
    }
    
    func playerPlaybackDidLoop(_ player: Player) {
        
    }
}


private extension TimeInterval {
    private var seconds: Int {
        return (asInt ?? 0) % 60
    }
    
    private var minutes: Int {
        return (asInt ?? 0) / 60
    }
    
    var playbackTime: String {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
