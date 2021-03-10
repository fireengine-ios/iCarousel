//
//  AgreementsViewController.swift
//  Depo_LifeTech
//
//  Created by Vyacheslav Bakinskiy on 10.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class AgreementsViewController: BaseViewController, NibInit {
    
    private let buttonTiteles = [TextConstants.termsOfUseAgreement, TextConstants.privacyPolicyAgreement]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: TextConstants.agreements)
        setSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Device.isIpad {
            defaultNavBarStyle()
        }
    }
    
    private func setSegmentedControl() {
        let segmentedControl = AgreementsSegmentedControl(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 43),
                                                          buttonTitles: buttonTiteles)
        segmentedControl.backgroundColor = .clear
        segmentedControl.delegate = self
        view.addSubview(segmentedControl)
    }
}

extension AgreementsViewController: AgreementsSegmentedControlDelegate {
    func segmentedControlButton(didChangeIndexTo index: Int) {
        switch index {
        case 0:
            print("===============> 1")
        case 1:
            print("===============> 2")
        default:
            print("===============> 3")
        }
    }
}
