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
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var viewForPlayer: UIView!
    
    var previewURLString: String? {
        didSet {
            guard let previewURLString = previewURLString,
            let sourceURL = URL(string: previewURLString)else {
                return
            }
            playerController?.player = nil
            playerController?.removeFromParentViewController()
            playerController = nil
            player?.pause()
            player = nil
            
            let plauerItem = AVPlayerItem(url: sourceURL)
            
            player = AVPlayer(playerItem: plauerItem)
            
            let imageGenerator = AVAssetImageGenerator(asset: plauerItem.asset)
            let time = CMTimeMake(1, 1)
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
        blackNavigationBarStyle()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.createStorySave,
                                                            target: self,
                                                            selector: #selector(onSaveButton))
        
        output.viewIsReady()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .black
    }
    
    @IBAction func onPlayButton() {
        playVideoByURLString(urlSting: previewURLString)
    }
    
    func playVideoByURLString(urlSting: String?) {
        playerController = FixedAVPlayerViewController()
        playerController?.player = player
        self.present(playerController!, animated: true) { [weak self] in
            self?.playerController?.player!.play()
        }
    }
    
    @objc func onSaveButton() {
        output.onSaveStory()
    }
    
    override func getBackgroundColor() -> UIColor {
        return viewForPlayer.backgroundColor ?? UIColor.black
    }
    
}

// MARK: CreateStoryPreviewViewInput
extension CreateStoryPreviewViewController: CreateStoryPreviewViewInput {
    func startShowVideoFromResponce(responce: CreateStoryResponce) {
        guard let urlString = responce.storyURLString else {
            return
        }
        previewURLString = urlString
//        playVideoByURLString(urlSting: urlString) //Left this in case if requrements would change again(start automaticaly)
    }
}
