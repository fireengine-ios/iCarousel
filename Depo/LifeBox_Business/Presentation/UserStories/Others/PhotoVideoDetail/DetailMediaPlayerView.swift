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
            newValue.setValue(0, animated: false)
            newValue.tintColor = .white
            newValue.thumbTintColor = .white
        }
    }
    
    private lazy var mediaPlayer: Player = {
        let player = Player()
        
        player.fillMode = .resizeAspect
        
        player.playerDelegate = self
        player.playbackDelegate = self

        return player
    }()
    
    
    //MARK: - Override
    
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
    
    
    func addPlayer(on controller: UIViewController) {
        controller.addChildViewController(mediaPlayer)
        playerContainerView.addSubview(mediaPlayer.view)
        controller.didMove(toParentViewController: controller)
    }
    
    func play(with url: URL) {
        mediaPlayer.url = url
        mediaPlayer.playFromBeginning()
    }

}

extension DetailMediaPlayerView: PlayerDelegate {
    
    func playerReady(_ player: Player) {
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        
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
