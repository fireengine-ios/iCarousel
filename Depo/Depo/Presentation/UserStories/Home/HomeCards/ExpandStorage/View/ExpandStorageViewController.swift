//
//  ExpandStorageExpandStorageViewController.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ExpandStorageViewController: BaseCollectionViewController, ExpandStorageViewInput {

    var output: ExpandStorageViewOutput!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewForTitleLabel: UIView!
    @IBOutlet weak var viewForButtons: UIView!
    @IBOutlet weak var expandStorageButton: SimpleButtonWithBlueText!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
    
    override func configurateView(){
        super.configurateView()
        
        //titleLabel.textColor = ColorConstants.whiteColor
        viewForTitleLabel.backgroundColor = ColorConstants.orrageBacgroundColor
        
//        let gradient = CAGradientLayer()
//        gradient.frame = view.bounds
//        gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
//        gradient.startPoint = CGPoint.zero;
//        gradient.endPoint = CGPoint.init(x: 1, y: 1)
//        viewForTitleLabel.layer.insertSublayer(gradient, at: 0)
        
        
        let text = TextConstants.homeExpandeStorageBigTitle + "\n\n" + TextConstants.homeExpandeStorageSmallTitle
        let string = text as NSString
        let range = string.range(of: TextConstants.homeExpandeStorageSmallTitle)
        let attributedText = NSMutableAttributedString(string: text)
        
        let font1Size:CGFloat = 18
        let font2Size:CGFloat = 12
        
        let font1 = UIFont.TurkcellSaturaRegFont(size: font1Size)
        let font2 = UIFont.TurkcellSaturaRegFont(size: font2Size)
        let r1 = NSRange(location: 0, length: range.location)
        let r2 = NSRange(location: range.location, length: range.length)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font1, range: r1)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font2, range: r2)
        
        titleLabel.attributedText = attributedText
        titleLabel.textColor = ColorConstants.whiteColor
        
        self.expandStorageButton.setTitle(TextConstants.homeExpandeStorageButton, for: .normal)
        self.expandStorageButton.setTitleColor(ColorConstants.orrageTextColor, for: .normal)
    }
    
    @IBAction func onExpandStoragebutton(){
        UIApplication.showErrorAlert(message: "Sorry this functional \n is under constraction")
    }


    // MARK: ExpandStorageViewInput
    func setupInitialState() {
        
    }
}
