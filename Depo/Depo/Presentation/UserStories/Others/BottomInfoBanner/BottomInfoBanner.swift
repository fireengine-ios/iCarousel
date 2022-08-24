//
//  BottomInfoBanner.swift
//  Depo
//
//  Created by Burak Donat on 23.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class BottomInfoBanner: BasePopUpController, NibInit {
    
    private var infoText: String? = ""
    
    convenience init(infoText: String) {
        self.init()
        self.infoText = infoText
    }
    
    @IBOutlet private weak var infoView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 16
            newValue.backgroundColor = AppColor.settingsBottomInfo.color
        }
    }
    
    @IBOutlet private weak var infoLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .appFont(.regular, size: 14)
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var actionButton: RoundedButton! {
        willSet {
            newValue.backgroundColor = .white
            newValue.setTitle(TextConstants.ok, for: .normal)
            newValue.setTitleColor(ColorConstants.navy, for: .normal)
        }
    }

    @IBAction func onActionButton(_ sender: RoundedButton) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoLabel.text = infoText
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == view {
            dismiss(animated: true)
        }
    }
}
