//
//  VideoPlayerCell.swift
//  Depo_LifeTech
//
//  Created by Roman Harhun on 05/08/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol VideoInterruptable {
    func stop()
}

final class VideoPlayerCell: UICollectionViewCell {
    
    private weak var delegate: PhotoVideoDetailCellDelegate?
    private let avpController = FixedAVPlayerViewController()
    private var player:AVPlayer? {
        willSet {
            if newValue == nil {
                avpController.player = nil
            }
        }
    }

    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === player {
            if #available(iOS 10.0, *), keyPath == "timeControlStatus", player?.timeControlStatus == .playing {
                enterFullscreen(playerViewController: avpController)
            } else if player?.timeControlStatus == .playing, player?.rate != .zero  {
                enterFullscreen(playerViewController: avpController)
            }
        }
    }
    
    //MARK: - Utility methods(Private)
    private func setup() {
        if let view = avpController.view {
            self.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(
                [
                    view.topAnchor.constraint(
                        equalTo: self.contentView.topAnchor,
                        constant: NumericConstants.navigationBarHeight),
                    view.leadingAnchor.constraint(
                        equalTo: self.contentView.leadingAnchor),
                    view.trailingAnchor.constraint(
                        equalTo: self.contentView.trailingAnchor),
                    view.bottomAnchor.constraint(
                        equalTo: self.contentView.bottomAnchor,
                        constant: -NumericConstants.tabBarHight)
                ]
            )
        }
        configureObserver()
    }
    
    private func configureObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stop),
            name: .UIApplicationWillResignActive,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deinitPlayer),
            name: .deinitPlayer,
            object: nil
        )
    }

    private func configurePlayerObserver() {
        if #available(iOS 10.0, *) {
            player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        } else {
            player?.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        }
    }
    
    private func prepareForPlayVideo( file: Item) {
        guard let url = file.metaData?.videoPreviewURL ?? file.urlToFile else {
            return
        }
        
        switch file.patchToPreview {
        case let .localMediaContent(local):
            guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
                return
            }
            let option = PHVideoRequestOptions()
            delegate?.imageLoadingFinished()
            debugLog("about to play local video item")
            DispatchQueue.global(qos: .default).async { [weak self] in
                PHImageManager.default().requestAVAsset(forVideo: local.asset,
                                                        options: option) { [weak self] asset, _, _ in
                    debugPrint("!!!! after local request")
                    DispatchQueue.main.async {
                        guard let asset = asset else {
                            return
                        }
                        let playerItem = AVPlayerItem(asset: asset)
                        debugLog("playerItem created \(playerItem.asset.isPlayable)")
                        self?.play(item: playerItem)
                    }
                }
            }
        case .remoteUrl(_):
            debugLog("about to play remote video item")
            DispatchQueue.global(qos: .default).async { [weak self] in
                let playerItem = AVPlayerItem(url: url)
                debugLog("playerItem created \(playerItem.asset.isPlayable)")
                DispatchQueue.main.async {
                    self?.play(item: playerItem)
                }
            }
        }
    }
    
    private func play(item: AVPlayerItem) {
        player = AVPlayer(playerItem: item)
        avpController.player = player
        configurePlayerObserver()
    }
    
    @objc private func deinitPlayer(){
        self.player?.replaceCurrentItem(with: nil)
        self.player = nil
    }
    
    /// https://stackoverflow.com/a/51618451
    private func enterFullscreen(playerViewController: AVPlayerViewController) {
        let selectorName: String = {
            if #available(iOS 11.3, *) {
                return "_transitionToFullScreenAnimated:interactive:completionHandler:"
            } else if #available(iOS 11, *) {
                return "_transitionToFullScreenAnimated:completionHandler:"
            } else {
                return "_transitionToFullScreenViewControllerAnimated:completionHandler:"
            }
        }()
        let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)

        if playerViewController.responds(to: selectorToForceFullScreenMode) {
            playerViewController.perform(selectorToForceFullScreenMode, with: true, with: nil)
        }
    }
}

//MARK: - CellConfigurable

extension VideoPlayerCell: CellConfigurable {
    var responder: PhotoVideoDetailCellDelegate? {
        get { delegate }
        set { delegate = newValue }
    }
    
    func setObject(object: Item) {
        prepareForPlayVideo(file: object)
    }
}

//MARK: - VideoInterruptable

extension VideoPlayerCell: VideoInterruptable {
    @objc func stop() {
        guard player?.timeControlStatus != .paused else {
            return
        }
        player?.pause()
    }
}
