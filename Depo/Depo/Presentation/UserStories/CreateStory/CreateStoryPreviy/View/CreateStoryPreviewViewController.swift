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
    
    @IBOutlet private weak var viewForPlayer: CustomAVPlayerLayer!
    
    var previewURLString: String? {
        didSet {
            guard let previewURLString = previewURLString,
            let sourceURL = URL(string: previewURLString)else {
                return
            }
            
            viewForPlayer.setAVPlayerURL(url: previewURLString)
            
            
//            playerController?.player = nil
//            playerController?.removeFromParent()
//            playerController = nil
//            player?.pause()
//            player = nil
//
//            let plauerItem = AVPlayerItem(url: sourceURL)
//
//            player = AVPlayer(playerItem: plauerItem)
        }
    }
    
    var player: AVPlayer?
    var playerController: FixedAVPlayerViewController?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        output.viewIsReady()
        
        //playVideoByURLString(urlSting: previewURLString)
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
        
        title = output.getStoryName()
    }
    
    func playVideoByURLString(urlSting: String?) {
        playerController = FixedAVPlayerViewController()
        playerController?.player = player
        
        addChild(playerController!)
        playerController?.view.frame = viewForPlayer.bounds
        viewForPlayer.addSubview((playerController?.view)!)
        playerController?.didMove(toParent: self)
    }
    
    @objc private func onSaveButton() {
        output.onSaveStory()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc private func didEnterBackground() {
        player?.pause()
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
