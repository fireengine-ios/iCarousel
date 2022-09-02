//
//  CreateStoryPreviewCreateStoryPreviewViewController.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class CreateStoryPreviewViewController: BaseViewController, AVPlayerViewControllerDelegate {

    var output: CreateStoryPreviewViewOutput!
    
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var viewForPlayer: UIView!
    
    var previewURLString: String? {
        didSet {
            guard let previewURLString = previewURLString,
            let sourceURL = URL(string: previewURLString)else {
                return
            }
            playerController?.player = nil
            playerController?.removeFromParent()
            playerController = nil
            player?.pause()
            player = nil
            
            let plauerItem = AVPlayerItem(url: sourceURL)
            
            player = AVPlayer(playerItem: plauerItem)
            
            let imageGenerator = AVAssetImageGenerator(asset: plauerItem.asset)
            let time = CMTimeMake(value: 1, timescale: 1)
            if let imageRef = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
                let thumbnail = UIImage(cgImage: imageRef)
                previewImageView.image = thumbnail
            }
        }
    }
    
    var player: AVPlayer?
    var playerController: FixedAVPlayerViewController?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        output.viewIsReady()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .black
    }
    
    private func setupNavigation() {        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.createStorySave,
                                                            target: self,
                                                            selector: #selector(onSaveButton))
    }
    
    func playVideoByURLString(urlSting: String?) {
        playerController = FixedAVPlayerViewController()
        playerController?.player = player
        self.present(playerController!, animated: true) { [weak self] in
            self?.playerController?.player!.play()
        }
    }
    
    @objc private func onSaveButton() {
        output.onSaveStory()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc private func didEnterBackground() {
        player?.pause()
    }
    
    @IBAction private func onPlayButton() {
        playVideoByURLString(urlSting: previewURLString)
    }
}

// MARK: CreateStoryPreviewViewInput
extension CreateStoryPreviewViewController: CreateStoryPreviewViewInput {
    func startShowVideoFromResponse(response: CreateStoryResponse) {
        guard let urlString = response.storyURLString else {
            return
        }
        previewURLString = urlString
//        playVideoByURLString(urlSting: urlString) //Left this in case if requrements would change again(start automaticaly)
    }
    
    func prepareToDismiss() {
    }
}
