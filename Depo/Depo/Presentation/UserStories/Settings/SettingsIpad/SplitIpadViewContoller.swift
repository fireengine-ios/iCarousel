//
//  SplitIpadViewContoller.swift
//  Depo
//
//  Created by Oleg on 08.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SplitIpadViewContoller: NSObject, UISplitViewControllerDelegate, SettingsDelegate {
    
    private var splitViewController = UISplitViewController()
    private var leftController: SettingsViewController?
    
    func configurateWithControllers(leftViewController: SettingsViewController, controllers: [UIViewController]) {
        leftViewController.settingsDelegate = self
        leftController = leftViewController
        var controllersArray = [UIViewController]()
        controllersArray.append(leftViewController)
        controllersArray.append(contentsOf: controllers)
        
        splitViewController.viewControllers = controllersArray
        splitViewController.preferredDisplayMode = .allVisible
        //splitViewController.delegate = self
    }
    
    func getSplitVC() -> UISplitViewController {
        
        return splitViewController
    }
    
    
    // MARK: UISplitViewControllerDelegate
    
    // MARK: SettingsDelegate
    func goToContactSync() {
        if let left = leftController {
        configurateWithControllers(leftViewController: left, controllers: [RouterVC().syncContacts])
        }
    }
    
    func goToConnectedAccounts() {
        if let left = leftController, let controller = RouterVC().connectedAccounts {
            configurateWithControllers(leftViewController: left, controllers: [controller])
        }
    }
    
    func goToAutoUpload() {
        if let left = leftController {
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().autoUpload])
        }
    }
    
    func goToPeriodicContactSync() {
        if let left = leftController {
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().periodicContactsSync])
        }
    }
    
    func goToFaceImage() {
        if let left = leftController {
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().faceImage])
        }
    }
    
    func goToHelpAndSupport() {
        if let left = leftController, let controller = RouterVC().helpAndSupport {
            configurateWithControllers(leftViewController: left, controllers: [controller])
        }
    }
    
    func goToTermsAndPolicy() {
        if let left = leftController, let controller = RouterVC().termsAndPolicy {
            configurateWithControllers(leftViewController: left, controllers: [controller])
        }
    }
    
    func goToUsageInfo() {
        if let left = leftController, let controller = RouterVC().usageInfo {
            
            configurateWithControllers(leftViewController: left, controllers: [controller])
        }
    }
    
    func onUpdatUserInfo(userInfo: AccountInfoResponse) {
        if let left = leftController {
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().userProfile(userInfo: userInfo)])
        }
    }
    
    func goToActivityTimeline() {
        guard let left = leftController else { return }
        configurateWithControllers(leftViewController: left, controllers: [RouterVC().vcActivityTimeline])
    }
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool, needPopPasscodeEnterVC: Bool) {
        if needPopPasscodeEnterVC {
            RouterVC().popViewController()
        }
        if let left = leftController {
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().passcodeSettings(isTurkcell: isTurkcell, inNeedOfMail: inNeedOfMail)])
        }
    }
}
