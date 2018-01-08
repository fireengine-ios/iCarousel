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
        
        scrolliblePopUpView.addNotPermittedPopUpViewTypes(types: [.upload, .sync, .download, .freeAppSpace, .freeAppSpaceWarning])
        
        duplicatesTextLabel.textColor = ColorConstants.darkText
        duplicatesTextLabel.font = UIFont.TurkcellSaturaDemFont(size: 14)
        duplicatesTextLabel.text = String(format: TextConstants.freeAppSpaceTitle, FreeAppSpace.default.getDuplicatesObjects().count)
        mainTitle = ""
        
        super.viewDidLoad()
    }
    
    override func configurateNavigationBar(){
        navigationBarWithGradientStyle()
        configurateDeleteNavBarActions {[weak self] in
            guard let self_ = self else{
                return
            }
            self_.output.onNextButton()
        }
        CardsManager.default.addViewForNotification(view: scrolliblePopUpView)
    }
    
}

