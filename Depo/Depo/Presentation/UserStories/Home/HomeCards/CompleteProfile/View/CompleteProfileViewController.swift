//
//  CompleteProfileCompleteProfileViewController.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CompleteProfileViewController: BaseCollectionViewController, CompleteProfileViewInput {

    var output: CompleteProfileViewOutput!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var uploadPhotoButton: SimpleButtonWithBlueText!
    @IBOutlet weak var takeAPhotoButton: SimpleButtonWithBlueText!
    @IBOutlet weak var buttonsView: UIView!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }

    override func configurateView(){
        super.configurateView()
        
        uploadPhotoButton.setTitle(TextConstants.homeCompleteProfileUploadButton, for: .normal)
        takeAPhotoButton.setTitle(TextConstants.homeCompleteProfileTakeAPhoto, for: .normal)
        
        let text = "    " + TextConstants.homeCompleteProfileSubTitleBig + "\n" + TextConstants.homeCompleteProfileSubTitleSmall
        let string = text as NSString
        let range = string.range(of: TextConstants.homeCompleteProfileSubTitleSmall)
        let attributedText = NSMutableAttributedString(string: text)
        
        let font1Size:CGFloat = 18
        let font2Size:CGFloat = 12
//        if (Device.isIpad){
//            font1Size = 37
//            font2Size = 25
//        }
        
        let font1 = UIFont.TurkcellSaturaRegFont(size: font1Size)
        let font2 = UIFont.TurkcellSaturaRegFont(size: font2Size)
        let r1 = NSRange(location: 0, length: range.location)
        let r2 = NSRange(location: range.location, length: range.length)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font1, range: r1)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font2, range: r2)
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "profileSmallUserIcon")
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedText.replaceCharacters(in: NSMakeRange(0, 1), with: attrStringWithImage)
        titleLabel.attributedText = attributedText
        titleLabel.textColor = ColorConstants.textGrayColor
        
    }
    
    override func calculateHeight(forWidth width:CGFloat){
        let neededSize = titleLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        calculatedH = neededSize.height + buttonsView.frame.size.height + titleLabel.frame.origin.y + 10
    }

    // MARK: CompleteProfileViewInput
    func setupInitialState() {
    }
    
    // MARK: UIButtons actions
    
    @IBAction func onUploadPhotoButton(){
        UIApplication.showErrorAlert(message: "Sorry this functional \n is under constraction")
    }
    
    @IBAction func onTakeAPhotoButton(){
        UIApplication.showErrorAlert(message: "Sorry this functional \n is under constraction")
    }
}
