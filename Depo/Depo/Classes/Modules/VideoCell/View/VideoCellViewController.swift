//
//  VideoCellVideoCellViewController.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class VideoCellViewController: BaseCollectionViewController, VideoCellViewInput {

    var output: VideoCellViewOutput!
    
    @IBOutlet weak var videoPreviewImageView: UIImageView!
    @IBOutlet weak var videoLengthLabel: UILabel!
    @IBOutlet weak var cloudStatusImage: UIImageView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPreviewImageView.image = UIImage(named: "homeCreateStory")
        
        videoLengthLabel.textColor = ColorConstants.whiteColor
        videoLengthLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
        videoLengthLabel.text = "19:25"
        output.viewIsReady()
    }


    // MARK: VideoCellViewInput
    func setupInitialState() {
        
    }
}
