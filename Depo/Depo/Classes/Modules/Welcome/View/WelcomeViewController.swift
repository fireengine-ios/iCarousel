//
//  WelcomeWelcomeViewController.swift
//  Depo
//
//  Created by Oleg on 26/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseCollectionViewController, WelcomeViewInput {

    var output: WelcomeViewOutput!
    
    @IBOutlet weak var textLabel: UILabel!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }

    override func configurateView(){
        super.configurateView()
        
        let text = TextConstants.homeWelcomTextBig + "\n\n" + TextConstants.homeWelcomTextSmall
        let string = text as NSString
        let range = string.range(of: TextConstants.homeWelcomTextSmall)
        let attributedText = NSMutableAttributedString(string: text)
        
        let font1Size:CGFloat = 18
        let font2Size:CGFloat = 12
        
        let font1 = UIFont.TurkcellSaturaRegFont(size: font1Size)
        let font2 = UIFont.TurkcellSaturaRegFont(size: font2Size)
        let r1 = NSRange(location: 0, length: range.location)
        let r2 = NSRange(location: range.location, length: range.length)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font1, range: r1)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font2, range: r2)
        
        textLabel.attributedText = attributedText
        textLabel.textColor = ColorConstants.textGrayColor
        
    }
    
    // MARK: WelcomeViewInput
    func setupInitialState() {
        
    }
    
    override func calculateHeight(forWidth width:CGFloat){
        //self.view.frame.size = CGSize(width: width - 28, height: 10)
        let neededSize = textLabel.sizeThatFits(CGSize(width: width - 28, height: CGFloat.greatestFiniteMagnitude))
        calculatedH = neededSize.height + 20
    }
}
