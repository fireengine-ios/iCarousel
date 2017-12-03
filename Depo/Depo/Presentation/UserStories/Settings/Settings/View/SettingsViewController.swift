//
//  SettingsSettingsViewController.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol SettingsDelegate: class{
    func goToContactSync()
    
    func goToIportPhotos()
    
    func goToAutoUpload()
    
    func goToHelpAndSupport()
    
    func goToUsageInfo()
    
    func goToActivityTimeline()
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool)
}

class SettingsViewController: UIViewController, SettingsViewInput, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leaveFeedbackButton: ButtonWithGrayCorner!
    
    let custoPopUp = CustomPopUp()
    
    var tableDataArray: [[String]] = []
    var turkCellSeuritySettingsPass: Bool?
    var turkCellSeuritySettingsAutoLogin: Bool?
    
    
    var output: SettingsViewOutput!
    var userInfoSubView = UserInfoSubViewModuleInitializer.initializeViewController(with: "UserInfoSubViewViewController") as! UserInfoSubViewViewController
    
    weak var settingsDelegate: SettingsDelegate?
    
    let turkCellSecurityPasscodeCellIndex = IndexPath(row: 4, section: 1)
    let turkCellSecurityAutologinCellIndex = IndexPath(row: 5, section: 1)
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaveFeedbackButton.setTitle(TextConstants.settingsViewLeaveFeedback,
                              for: .normal)
        
        let nib = UINib.init(nibName: CellsIdConstants.settingTableViewCellID,
                             bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.settingTableViewCellID)
        tableView.register(UINib.init(nibName: CellsIdConstants.settingsTableViewSwitchCellID,
                                      bundle: nil),
                           forCellReuseIdentifier: CellsIdConstants.settingsTableViewSwitchCellID)
        
        tableView.backgroundColor = UIColor.clear
        
        userInfoSubView.actionsDelegate = self
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        if (Device.isIpad){
            splitViewController?.navigationController?.viewControllers.last?.title = "Settings"
        } else {
            self.setTitle(withString: "Settings")
        }
        output.viewWillBecomeActive()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationBarWithGradientStyle()
    }
    
    // MARK: SettingsViewInput
    
    func showCellsData(array: [[String]]){
        tableDataArray.removeAll()
        tableDataArray.append(contentsOf: array)
        tableView.reloadData()
    }
    
    
    // MARK: buttons action
    
    @IBAction func onLeaveFeedback(){
        RouterVC().showFeedbackSubView()
    }
    
    //MARK: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0){
            return 156
        }
        return 14
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0){
            return userInfoSubView.view
        }
        return SettingHeaderView.viewFromNib()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (section == tableDataArray.count - 1){
            return SettingHeaderView.viewFromNib()
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = tableDataArray[section]
        return array.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let isSecurityCell = (indexPath == turkCellSecurityPasscodeCellIndex) || (indexPath == turkCellSecurityAutologinCellIndex)

        let reusableID = isSecurityCell ? CellsIdConstants.settingsTableViewSwitchCellID : CellsIdConstants.settingTableViewCellID
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableID, for: indexPath)
        let array = tableDataArray[indexPath.section]
        if let settingCell = cell as? SettingsTableViewCell  {
            cell.selectionStyle = .none
            settingCell.setTextForLabel(titleText: array[indexPath.row], needShowSeparator: indexPath.row != array.count - 1)
            return settingCell
        } else if let settingSwitchCell = cell as? SettingsTableViewSwitchCell {
            settingSwitchCell.actionDelegate = self
            settingSwitchCell.setTextForLabel(titleText: array[indexPath.row], needShowSeparator: indexPath.row != array.count - 1)
            if indexPath.row == 4, let unwrapedturkCellSeuritySettingsPass = turkCellSeuritySettingsPass {
                settingSwitchCell.cellSwitch.setOn(unwrapedturkCellSeuritySettingsPass, animated: true)
            } else if indexPath.row == 5, let unwrapedturkCellSeuritySettingsAutoLogin = turkCellSeuritySettingsAutoLogin {
                settingSwitchCell.cellSwitch.setOn(unwrapedturkCellSeuritySettingsAutoLogin, animated: true)
            }
            return settingSwitchCell
        } else {
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.scrollRectToVisible(tableView.rectForRow(at: indexPath), animated: true)
        if (!Device.isIpad){
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            splitViewController?.navigationController?.viewControllers.last?.navigationItem.rightBarButtonItem = nil
        }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: // back-ip contacts
                if (settingsDelegate != nil){
                    settingsDelegate!.goToContactSync()
                }else{
                    output.goToContactSync()
                }
            case 1: // import photos
                if (settingsDelegate != nil){
                    settingsDelegate?.goToIportPhotos()
                }else{
                    output.goToImportPhotos()
                }
                break
            case 2: // auto upload
                if (settingsDelegate != nil){
                    settingsDelegate!.goToAutoUpload()
                }else{
                    output.goToAutoApload()
                }
                break
            default:
                break
            }
            break
        case 1:
            switch indexPath.row {
            case 0: // my activity timeline
                if (settingsDelegate != nil){
                    settingsDelegate!.goToActivityTimeline()
                }else{
                    output.goToActivityTimeline()
                }
            case 1: // recently deleted files
                break
            case 2: // usage info
                if (settingsDelegate != nil){
                    settingsDelegate!.goToUsageInfo()
                }else{
                    output.goToUsageInfo()
                }
                break
            case 3: /// passcode
                showPasscodeOrPasscodeSettings()
            case 4, 5:
                guard let securityCell = tableView.cellForRow(at: indexPath) as? SettingsTableViewSwitchCell else {
                    break
                }
                securityCell.cellSwitch.setOn(!securityCell.cellSwitch.isOn, animated: true)
            default:
                break
            }
            break
        case 2:
            switch indexPath.row {
            case 0:
                if (settingsDelegate != nil){
                    settingsDelegate!.goToHelpAndSupport()
                }else{
                    output.goToHelpAndSupport()
                }
                break
            case 1:
                output.onLogout()
            default:
                break
            }
            
        default:
            break
        }
    }
    
    private func showPasscodeOrPasscodeSettings() {
        let routerBlock = { [weak self] in
            if let settingsDelegate = self?.settingsDelegate {
                settingsDelegate.goToPasscodeSettings(isTurkcell: self?.output.isTurkCellUser ?? false,
                                                      inNeedOfMail: self?.output.inNeedOfMail ?? false)
            } else {
                self?.output.goToPasscodeSettings()
            }
        }
        
        if output.isPasscodeEmpty {
            routerBlock()
            return
        }
        
        output.openPasscode(handler: routerBlock)
    }
    
    func showPhotoAlertSheet() {
        let cancellAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel, handler: { _ in
            
        })
        
        let actionPhoto = UIAlertAction(title: TextConstants.actionSheetTakeAPhoto, style: .default, handler: { _ in
            self.output.onChooseFromPhotoCamera(onViewController: self)
        })
        
        let actionLibriary = UIAlertAction(title: TextConstants.actionSheetChooseFromLib, style: .default, handler: { _ in
            self.output.onChooseFromPhotoLibriary(onViewController: self)
        })
        
        let actionsWithCancell: [UIAlertAction] = [cancellAction, actionPhoto, actionLibriary]
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionsWithCancell.forEach({actionSheetVC.addAction($0)})
        actionSheetVC.popoverPresentationController?.sourceView = view
        
        let originPoint = CGPoint(x: Device.winSize.width/2 - actionSheetVC.preferredContentSize.width/2,
                                  y: Device.winSize.height/2 - actionSheetVC.preferredContentSize.height/2)
        
        let sizePoint = actionSheetVC.preferredContentSize
        actionSheetVC.popoverPresentationController?.sourceRect = CGRect(origin: originPoint, size: sizePoint)
        actionSheetVC.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0) // means no arrow
        
        present(actionSheetVC, animated: true, completion: nil)
    }
    
    func profileInfoChanged() {
        userInfoSubView.reloadUserInfo()
    }
    
    func profileWontChange() {
        userInfoSubView.dismissLoadingSpinner()
    }
}

// MARK: - UserInfoSubViewViewControllerActionsDelegate
extension SettingsViewController: UserInfoSubViewViewControllerActionsDelegate {
    func changePhotoPressed() {
        output.onChangeUserPhoto()
    }
    
    func updateUserProfile(userInfo: AccountInfoResponse){
        output.onUpdatUserInfo(userInfo: userInfo)
    }
    
    func upgradeButtonPressed() {
        output.goToPackages()
    }
}

//MARK: - photo picker delegatess
extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var photoData: Data?
        if let imageURL = info[UIImagePickerControllerMediaURL] as? URL,
            let imageData = try? Data(contentsOf: imageURL) {
            
            photoData = imageData
            
        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            photoData = UIImagePNGRepresentation(image)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage  {
            photoData = UIImagePNGRepresentation(image)
        }
        if let unwrapedPhotoData = photoData {
            output.photoCaptured(data: unwrapedPhotoData)
        }
        userInfoSubView.showLoadingSpinner()
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    func changeTurkCellSecurity(passcode: Bool, autologin: Bool) {
        turkCellSeuritySettingsPass = passcode
        turkCellSeuritySettingsAutoLogin = autologin
        guard let securityPasscodeCell = tableView.cellForRow(at: turkCellSecurityPasscodeCellIndex) as? SettingsTableViewSwitchCell,
            let securityAutoLoginCell = tableView.cellForRow(at: turkCellSecurityAutologinCellIndex) as? SettingsTableViewSwitchCell else {
                return
        }
        securityPasscodeCell.changeSwithcState(turnOn: passcode)
        securityAutoLoginCell.changeSwithcState(turnOn: autologin)
    }
}

extension SettingsViewController: SettingsTableViewSwitchCellDelegate {
    func switchToggled(positionOn: Bool, cell: SettingsTableViewSwitchCell) {
        guard let securityPasscodeCell = tableView.cellForRow(at: turkCellSecurityPasscodeCellIndex) as? SettingsTableViewSwitchCell,
            let securityAutoLoginCell = tableView.cellForRow(at: turkCellSecurityAutologinCellIndex) as? SettingsTableViewSwitchCell else {
                return
        }
        output.turkcellSecurityChanged(passcode: securityPasscodeCell.cellSwitch.isOn, autoLogin: securityAutoLoginCell.cellSwitch.isOn)
    }
}
