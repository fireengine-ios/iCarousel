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

    private static let fullScreenSelector: Selector = {
        let name: String
        if #available(iOS 11.3, *) {
            name = "_transitionToFullScreenAnimated:interactive:completionHandler:"
        } else {
            name = "_transitionToFullScreenAnimated:completionHandler:"
        }
        return NSSelectorFromString(name)
    }()

    private weak var delegate: PhotoVideoDetailCellDelegate?
    private let avpController = FixedAVPlayerViewController()
    private var player = AVPlayer()

    private let previewImageView = LoadingImageView()

    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player.replaceCurrentItem(with: nil)
        avpController.player = nil
        previewImageView.cancelLoadRequest()
        previewImageView.isHidden = false
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if object as AnyObject? === player, keyPath == "timeControlStatus", player.timeControlStatus != .paused, player.status == .readyToPlay {
            enterFullscreen(playerViewController: avpController)
            previewImageView.isHidden = true
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
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }
    
    private func prepareForPlayVideo(file: Item) {
        previewImageView.loadImageIncludingGif(with: file)
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
            guard let url = file.urlToFile else { return }
            debugLog("about to play remote video item")
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let playerItem = AVPlayerItem(url: url)
                self?.delegate?.imageLoadingFinished()
                DispatchQueue.main.async {
                    self?.play(item: playerItem)
                }
            }
        }
        
    }
    
    private func addPreviewToVideo(){
        print(avpController.view.frame, previewImageView.frame)
        avpController.contentOverlayView?.addSubview(previewImageView)
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.clipsToBounds = true
        NSLayoutConstraint.activate(
            [
                previewImageView.topAnchor.constraint(
                    equalTo: self.contentView.topAnchor,
                    constant: NumericConstants.navigationBarHeight
                ),
                previewImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                previewImageView.widthAnchor.constraint(equalToConstant: avpController.view.frame.width),
                previewImageView.heightAnchor.constraint(equalToConstant: avpController.view.frame.height)
            ]
        )
        print("After:", avpController.view.frame, previewImageView.frame)
    }
    
    private func play(item: AVPlayerItem) {
        player = AVPlayer(playerItem: item)
        addPreviewToVideo()
        avpController.player = player
        configurePlayerObserver()
    }
    
    func didEndDisplaying() {
        avpController.player = nil
    }
    
    @objc private func deinitPlayer(){
        avpController.player = nil
    }
    
    /// https://stackoverflow.com/a/51618451
    private func enterFullscreen(playerViewController: AVPlayerViewController) {
        if playerViewController.responds(to: VideoPlayerCell.fullScreenSelector) {
            playerViewController.perform(VideoPlayerCell.fullScreenSelector, with: true, with: nil)
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
        guard player.timeControlStatus != .paused else {
            return
        }
        player.pause()
    }
}
