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
            guard let previewURLString = previewURLString else {
                return
            }
            
            viewForPlayer.setAVPlayerURL(url: previewURLString)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        output.viewIsReady()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .black
    }
    
    private func setupNavigation() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.createStorySave,
                                                            target: self,
                                                            selector: #selector(onSaveButton))
        
        title = output.getStoryName()
    }

    @objc private func onSaveButton() {
        output.onSaveStory()
        navigationItem.rightBarButtonItem?.isEnabled = false
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
