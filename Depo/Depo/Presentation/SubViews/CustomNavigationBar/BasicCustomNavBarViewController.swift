//
//  CustomNavBarViewController.swift
//  Depo
//
//  Created by Aleksandr on 6/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BasicCustomNavBarViewController: UIViewController {
    let customNavigationBar = CustomNavBarView.getFromNib()
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


////MARK: - MoreActions Actions Delegate
//
//extension BasicCustomNavBarViewController: MoreActionsViewDelegate {
//    func viewAppearanceChanged(asGrid: Bool) {
//        
//    }
//    
//    func sortedPushed(with rule: SortClousure?) {
//        guard let rule = rule else {
//            return
//        }
//    }
//    
//    func filters(cahngedTo filters: [MoreActionsConfig.FileType]) {
//        
//    }
//}


//MARK: - MoreActions(UIPopoverController) appearance delegate

extension BasicCustomNavBarViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        debugPrint("Pop over prapearing")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none//popover//formSheet
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        debugPrint("recr popover is ",rect)
        debugPrint("popover view ", view)
    }
}
