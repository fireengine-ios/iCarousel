//
//  FreeAppSpaceFreeAppSpaceViewController.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FreeAppSpaceViewController: BaseFilesGreedViewController {

    @IBOutlet weak var duplicatesTextLabel: UILabel!
    
    override func viewDidLoad() {
        
        
        cardsContainerView.isEnable = false
        
        duplicatesTextLabel.textColor = ColorConstants.darkText
        duplicatesTextLabel.font = UIFont.TurkcellSaturaDemFont(size: 14)
        duplicatesTextLabel.text = ""
        
        mainTitle = ""
        
        super.viewDidLoad()
    }
    
    func setTitleLabelText(duplicatesCount: Int) {
        duplicatesTextLabel?.text = String(format: TextConstants.freeAppSpaceTitle, duplicatesCount)
    }
    
    override func configurateNavigationBar() {
        navigationBarWithGradientStyle()
        configurateFreeAppSpaceActions {[weak self] in
            guard let self_ = self else {
                return
            }
            self_.output.onNextButton()
        }
        CardsManager.default.addViewForNotification(view: cardsContainerView)
    }
    
    override func startSelection(with numberOfItems: Int) {
        selectedItemsCountChange(with: numberOfItems)
    }

}
