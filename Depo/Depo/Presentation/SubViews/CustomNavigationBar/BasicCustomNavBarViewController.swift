//
//  CustomNavBarViewController.swift
//  Depo
//
//  Created by Aleksandr on 6/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BasicCustomNavBarViewController: ViewController {
}

extension BasicCustomNavBarViewController: CustomNavBarViewActionDelegate {
    
    func navBarButtonGotPressed(button: CustomNavBarButton) {
        UIApplication.showErrorAlert(message: "Sorry \(button.btnName!) \n is under constraction")
    }
    
    func navBarBackButtonPressed() {
        guard let navVC = self.navigationController else {
            return
        }
        navVC.popViewController(animated: true)
    }
}

// MARK: - MoreActions(UIPopoverController) appearance delegate

extension BasicCustomNavBarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
