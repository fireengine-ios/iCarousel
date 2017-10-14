//
//  WiFiSyncWiFiSyncViewController.swift
//  Depo
//
//  Created by Oleg on 26/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class WiFiSyncViewController: BaseCollectionViewController, WiFiSyncViewInput {

    var output: WiFiSyncViewOutput!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var syncButton: SimpleButtonWithBlueText!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
    
    override func configurateView(){
        super.configurateView()
        
        titleLabel.text = TextConstants.homeWiFiTitleText
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = ColorConstants.textGrayColor
        
        syncButton.setTitle(TextConstants.homeWiFiSyncButtonTitle, for: .normal)
    }


    // MARK: WiFiSyncViewInput
    func setupInitialState() {
        
    }
    
    @IBAction func onSyncDataButton(){
        output.onSyncDataButton()
        custoPopUp.showCustomAlert(withText: "Sorry this functional \n is under constraction", okButtonText: "Fine...")
    }
}
