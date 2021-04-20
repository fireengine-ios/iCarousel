//
//  DetailMediaPlayerView.swift
//  Depo
//
//  Created by Konstantin Studilin on 09.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
import Player


protocol DetailMediaPlayerViewDelegate: class {
    func playerHasData()
    func playerIsFailed()
    func artworkIsLoaded()
}


final class DetailMediaPlayerView: UIView, FromNib {

    @IBOutlet weak var playerContainerView: UIView! {
        willSet {
            newValue.backgroundColor = .clear
            newValue.addSubview(mediaPlayer.view)
        }
    }
    @IBOutlet private weak var playbackControlsView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.isExclusiveTouch = true
            newValue.backgroundColor = UIColor.black.withAlphaComponent(0.4)
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
    
    @IBOutlet private weak var totalDuration: UILabel! {
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
            newValue.setThumbImage(UIImage(named: "playerThumb"), for: .normal)
            newValue.addTarget(self, action: #selector(seekWithSliderRatio), for: .valueChanged)
        }
    }
    
    private lazy var mediaPlayer: Player = {
        let player = Player()
        
        player.fillMode = .resizeAspect
        player.playbackLoops = false
        
        player.playerDelegate = self
        player.playbackDelegate = self

        return player
    }()
    
    private lazy var artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    weak var delegate: DetailMediaPlayerViewDelegate?
    
    var artworkImageViewIsEmpty: Bool {
        return artworkImageView.image == nil
    }
    
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
        addArtworkImageView()
    }
    
    
    //MARK: Public
    
  
    func addPlayer(on controller: UIViewController) {
        controller.addChildViewController(mediaPlayer)
        controller.didMove(toParentViewController: controller)
    }
    
    func set(url: URL) {
        mediaPlayer.url = url
        resetControls()
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
    
    func setControls(isHidden: Bool) {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.playbackControlsView.isHidden = isHidden
            self.layoutIfNeeded()
        }
    }
    
    func toggleControlsVisibility() {
        setControls(isHidden: !playbackControlsView.isHidden)
    }
    
    func clearArtwork() {
        artworkImageView.image = nil
        artworkImageView.isHidden = true
    }
    
    //MARK: Private
    
    @IBAction private func onPlayPause(_ sender: Any) {
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
    
    private func addArtworkImageView() {
        artworkImageView.frame = CGRect(x: 0, y: 0, width: 335, height: 335)
        artworkImageView.center = self.center
        
        addSubview(artworkImageView)
    }
    
    private func resetControls() {
        timeAfter.text = "00:00"
        totalDuration.text = "00:00"
        playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        
        progressSlider.value = 0
    }
    
    private func getArtwork(_ player: Player) {
        guard let metadataList = player.asset?.metadata else {
            return
        }
        
        for item in metadataList {
            guard let key = item.commonKey?.rawValue, let value = item.value else {
                continue
            }
            
            switch key {
            case "artwork" where value is Data:
                guard let data = value as? Data else {
                    continue
                }
                artworkImageView.isHidden = false
                artworkImageView.image = UIImage(data: data)
                delegate?.artworkIsLoaded()
            default:
                continue
            }
        }
    }
}

extension DetailMediaPlayerView: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        progressSlider.isUserInteractionEnabled = true
        
        timeAfter.text = player.currentTimeInterval.playbackTime
        totalDuration.text = player.maximumDuration.playbackTime
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        switch mediaPlayer.playbackState {
            case .playing:
                playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                
            case .paused, .stopped:
                playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                
            case .failed:
                resetControls()
        }
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        switch player.bufferingState {
        case .ready:
            progressSlider.isUserInteractionEnabled = true
            
            timeAfter.text = player.currentTimeInterval.playbackTime
            totalDuration.text = player.maximumDuration.playbackTime
            
            if artworkImageViewIsEmpty {
                getArtwork(player)
            }
            
            delegate?.playerHasData()
        default:
            break
        }
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        delegate?.playerIsFailed()
        progressSlider.isUserInteractionEnabled = false
    }
}


extension DetailMediaPlayerView: PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
        let afterStart = player.currentTimeInterval
        let ratio = Float(afterStart / player.maximumDuration)
            
        timeAfter.text = afterStart.playbackTime
        totalDuration.text = player.maximumDuration.playbackTime
        
        if !progressSlider.isTracking {
            progressSlider.setValue(ratio, animated: false)
        }
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        delegate?.playerHasData()
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        resetControls()
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
