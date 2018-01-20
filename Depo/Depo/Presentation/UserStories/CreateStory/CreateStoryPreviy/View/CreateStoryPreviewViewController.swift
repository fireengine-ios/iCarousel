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

class CreateStoryPreviewViewController: UIViewController, AVPlayerViewControllerDelegate {

    var output: CreateStoryPreviewViewOutput!
    var previewURLString: String? = nil
    
    var player: AVPlayer?
    var playerController: AVPlayerViewController?
    
    @IBOutlet weak var viewForPlayer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        defaultNavBarStyle()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        button.setTitle(TextConstants.createStorySave, for: .normal)
        button.setTitleColor(ColorConstants.whiteColor, for: .normal)
        button.addTarget(self, action: #selector(onSaveButton), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        
        navigationItem.rightBarButtonItem = barButton
        
        output.viewIsReady()
    }
    
    @IBAction func onPlayButton(){
        playVideoByURLString(urlSting: previewURLString)
    }
    
    func playVideoByURLString(urlSting: String?){
        guard let string = urlSting else{
            return
        }
        
        guard let url = URL(string: string) else{
            return
        }
        
        playerController?.player = nil
        playerController?.removeFromParentViewController()
        playerController = nil
        player?.pause()
        player = nil
        player = AVPlayer()
        
        let plauerItem = AVPlayerItem(url:url)
        player!.replaceCurrentItem(with: plauerItem)
        playerController = AVPlayerViewController()
        playerController!.player = player!
        self.present(playerController!, animated: true) {[weak playerController] in
            playerController?.player!.play()
        }
    }
    
    @objc func onSaveButton(){
        output.onSaveStory()
    }
    
}

// MARK: CreateStoryPreviewViewInput
extension CreateStoryPreviewViewController: CreateStoryPreviewViewInput {
    func startShowVideoFromResponce(responce: CreateStoryResponce){
        guard let urlString = responce.storyURLString else{
            return
        }
        previewURLString = urlString
//        playVideoByURLString(urlSting: urlString) //Left this in case if requrements would change again(start automaticaly)
    }
}
