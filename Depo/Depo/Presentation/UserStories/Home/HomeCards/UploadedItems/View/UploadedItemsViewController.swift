//
//  UploadedItemsUploadedItemsViewController.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadedItemsViewController: BaseCollectionViewController, UploadedItemsViewInput {

    var output: UploadedItemsViewOutput!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var viewAllStrimButton: SimpleButtonWithBlueText!
    @IBOutlet weak var viewAllPicturesButton: SimpleButtonWithBlueText!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
    
    override func configurateView(){
        super.configurateView()
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        
        let subString = String(format: TextConstants.homeUploadedPhotosTitle, 25)
        
        let text = String(format: TextConstants.homeUploadedImagesTitle, subString)
        let string = text as NSString
        let range = string.range(of: subString)
        let attributedText = NSMutableAttributedString(string: text)
        
        let font1Size:CGFloat = 18
        let font1 = UIFont.TurkcellSaturaBolFont(size: font1Size)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font1, range: range)
        
        titleLabel.attributedText = attributedText
        
        
        viewAllStrimButton.setTitle(TextConstants.homeUploadedImagesViewAllStreams, for: .normal)
        viewAllPicturesButton.setTitle(TextConstants.homeUploadedImagesViewAllPictures, for: .normal)
    }

    // MARK: UploadedItemsViewInput
    func setupInitialState() {
    }
    
    // MARK: UIButtons actions
    @IBAction func onViewAllStreamsButton(){
        custoPopUp.showCustomAlert(withText: "Sorry this functional \n is under constraction", okButtonText: "Fine...")
    }
    
    @IBAction func onViewAllPicturesButton(){
        custoPopUp.showCustomAlert(withText: "Sorry this functional \n is under constraction", okButtonText: "Fine...")
    }
}
