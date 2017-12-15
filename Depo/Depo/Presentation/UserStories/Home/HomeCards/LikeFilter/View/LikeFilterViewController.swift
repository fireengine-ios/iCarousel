//
//  LikeFilterLikeFilterViewController.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LikeFilterViewController: BaseCollectionViewController, LikeFilterViewInput {

    var output: LikeFilterViewOutput!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var savePhotoButton: SimpleButtonWithBlueText!
    @IBOutlet weak var changeFilterButton: SimpleButtonWithBlueText!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }

    override func configurateView(){
        super.configurateView()
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.text = TextConstants.homeLikeFilterTitle
        
        subTitle.textColor = ColorConstants.textGrayColor
        subTitle.font = UIFont.TurkcellSaturaRegFont(size: 12)
        subTitle.text = TextConstants.homeLikeFilterSubTitle
        
        savePhotoButton.setTitle(TextConstants.homeLikeFilterSavePhotoButton, for: .normal)
        changeFilterButton.setTitle(TextConstants.homeLikeFilterChangeFilterButton, for: .normal)

    }

    // MARK: LikeFilterViewInput
    func setupInitialState() {
    }
    
    
    // MARK: UIButtons actions
    @IBAction func onSavePhotoButton(){
        UIApplication.showErrorAlert(message: "Sorry this functional \n is under constraction")
    }
    
    @IBAction func onChangeFilterButton(){
        UIApplication.showErrorAlert(message: "Sorry this functional \n is under constraction")
    }
}
