//
//  SplitIpadViewContoller.swift
//  Depo
//
//  Created by Oleg on 08.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SplitIpadViewContoller: NSObject, UISplitViewControllerDelegate, SettingsDelegate {
    
    private var splitViewController  = UISplitViewController()
    private var leftController: SettingsViewController?
    
    func configurateWithControllers(leftViewController: SettingsViewController, controllers : [UIViewController]){
        leftViewController.settingsDelegate = self
        leftController = leftViewController
        var controllersArray = [UIViewController]()
        controllersArray.append(leftViewController)
        controllersArray.append(contentsOf: controllers)
        
        splitViewController.viewControllers = controllersArray
        splitViewController.preferredDisplayMode = .allVisible
        //splitViewController.delegate = self
    }
    
    func getSplitVC()->UISplitViewController{
        
        return splitViewController
    }
    
    
    // MARK: UISplitViewControllerDelegate
    
    // MARK: SettingsDelegate
    func goToContactSync(){
        if let left = leftController{
        configurateWithControllers(leftViewController: left, controllers: [RouterVC().syncContacts!])
        }
    }
    
    func goToIportPhotos(){
        if let left = leftController{
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().importPhotos!])
        }
    }
    
    func goToAutoUpload(){
        if let left = leftController{
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().autoUpload])
        }
    }
    
    func goToHelpAndSupport(){
        if let left = leftController{
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().helpAndSupport!])
        }
    }
    
    func goToUsageInfo() {
        if let left = leftController{
            let navVC = UINavigationController(rootViewController: RouterVC().usageInfo!)
            configurateWithControllers(leftViewController: left, controllers: [navVC])
        }
    }
    
    func onUpdatUserInfo(userInfo:AccountInfoResponse) {
        if let left = leftController{
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().userProfile(userInfo: userInfo)])
        }
    }
    
    func goToActivityTimeline() {
        guard let left = leftController else { return }
        configurateWithControllers(leftViewController: left, controllers: [RouterVC().vcActivityTimeline])
    }
    
    func goToPasscodeSettings() {
        if let left = leftController{
            configurateWithControllers(leftViewController: left, controllers: [RouterVC().passcodeSettings()])
        }
    }
}
