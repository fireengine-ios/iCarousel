//
//  SettingsSettingsViewController.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol SettingsDelegate: class {
    func goToContactSync()
    
    func goToConnectedAccounts()
    
    func goToAutoUpload()
    
    func goToPeriodicContactSync()
    
    func goToFaceImage()
    
    func goToHelpAndSupport()
    
    func goToUsageInfo()
    
    func goToActivityTimeline()
    
    func goToPermissions()
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool, needPopPasscodeEnterVC: Bool)
}

class SettingsViewController: BaseViewController, SettingsViewInput, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leaveFeedbackButton: ButtonWithGrayCorner!
    @IBOutlet weak var versionLabel: UILabel!
    
    var tableDataArray: [[String]] = []
    var output: SettingsViewOutput!
    
    var userInfoSubView = UserInfoSubViewModuleInitializer.initializeViewController(with: "UserInfoSubViewViewController") as! UserInfoSubViewViewController
    
    weak var settingsDelegate: SettingsDelegate?
    
    private var isFromPhotoPicker = false
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaveFeedbackButton.setTitle(TextConstants.settingsViewLeaveFeedback,
                              for: .normal)
        
        let nib = UINib.init(nibName: CellsIdConstants.settingTableViewCellID,
                             bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.settingTableViewCellID)
        
        tableView.backgroundColor = UIColor.clear
        
        userInfoSubView.actionsDelegate = self
        output.viewIsReady()
        setupVersionLabel()
        
        MenloworksAppEvents.onPreferencesOpen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFromPhotoPicker {
            isFromPhotoPicker = false
            return
        }
        
        navigationBarWithGradientStyle()
        if Device.isIpad {
            splitViewController?.navigationController?.viewControllers.last?.title = TextConstants.settings
        } else {
            self.setTitle(withString: TextConstants.settings)
        }
        output.viewWillBecomeActive()
        userInfoSubView.reloadUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationBarWithGradientStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    // MARK: SettingsViewInput
    
    func setupVersionLabel() {
        versionLabel.textColor = ColorConstants.lightText
        versionLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        
        if let version = UserDefaults.standard.string(forKey: AppConfigurator.SettingsBundleKeys.AppVersionKey),
            let build = UserDefaults.standard.string(forKey: AppConfigurator.SettingsBundleKeys.BuildVersionKey) {
            versionLabel.text = "\(version)_\(build)"
        }
    }
    
    func showCellsData(array: [[String]]) {
        tableDataArray.removeAll()
        tableDataArray.append(contentsOf: array)
        tableView.reloadData()
    }
    
    
    // MARK: buttons action
    
    @IBAction func onLeaveFeedback() {
        RouterVC().showFeedbackSubView()
    }
    
    // MARK: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 201 : 14
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            return userInfoSubView.view
        }
        return SettingHeaderView.viewFromNib()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (section == tableDataArray.count - 1) {
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

        let array = tableDataArray[indexPath.section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.settingTableViewCellID, for: indexPath) as! SettingsTableViewCell
        cell.selectionStyle = .none
        cell.setTextForLabel(titleText: array[indexPath.row], needShowSeparator: indexPath.row != array.count - 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.scrollRectToVisible(tableView.rectForRow(at: indexPath), animated: true)
        if (!Device.isIpad) {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            splitViewController?.navigationController?.viewControllers.last?.navigationItem.rightBarButtonItem = nil
        }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: // back-ip contacts
                if (settingsDelegate != nil) {
                    settingsDelegate!.goToContactSync()
                } else {
                    output.goToContactSync()
                }
            case 1: // auto upload
                if (settingsDelegate != nil) {
                    settingsDelegate!.goToAutoUpload()
                } else {
                    output.goToAutoApload()
                }
            case 2: // periodic contact sync
                if (settingsDelegate != nil) {
                    settingsDelegate?.goToPeriodicContactSync()
                } else {
                    output.goToPeriodicContactSync()
                }
            case 3: // face image
                if (settingsDelegate != nil) {
                    settingsDelegate?.goToFaceImage()
                } else {
                    output.goToFaceImage()
                }
            default:
                break
            }
            break
        case 1:
            switch indexPath.row {
            case 0:
                // import photos
                MenloworksTagsService.shared.onSocialMediaPageClicked()
                if let delegate = settingsDelegate {
                    delegate.goToConnectedAccounts()
                } else {
                    output.goToConnectedAccounts()
                }
            case 1:
                // permissions
                if let delegate = settingsDelegate {
                    delegate.goToPermissions()
                } else {
                    output.goToPermissions()
                }
            default:
                break
            }
            break
        case 2:
            switch indexPath.row {
            case 0: // my activity timeline
                if (settingsDelegate != nil) {
                    settingsDelegate!.goToActivityTimeline()
                } else {
                    output.goToActivityTimeline()
                }
            case 1: // usage info
                if (settingsDelegate != nil) {
                    settingsDelegate!.goToUsageInfo()
                } else {
                    output.goToUsageInfo()
                }
            case 2: /// passcode
                showPasscodeOrPasscodeSettings()
            case 3:// Turkcell security
                output.goTurkcellSecurity()
            default:
                break
            }
            break
        case 3:
            switch indexPath.row {
            case 0:
                if (settingsDelegate != nil) {
                    settingsDelegate!.goToHelpAndSupport()
                } else {
                    output.goToHelpAndSupport()
                }
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
        if output.isPasscodeEmpty {
            if let settingsDelegate = settingsDelegate {
                settingsDelegate.goToPasscodeSettings(isTurkcell: output.isTurkCellUser,
                                                      inNeedOfMail: output.inNeedOfMail,
                                                      needPopPasscodeEnterVC: false)
            } else {
                output.goToPasscodeSettings(needReplaceOfCurrentController: false)
            }
        } else {
            output.openPasscode(handler: { [weak self] in
                if let settingsDelegate = self?.settingsDelegate {
                    settingsDelegate.goToPasscodeSettings(isTurkcell: self?.output.isTurkCellUser ?? false,
                                                          inNeedOfMail: self?.output.inNeedOfMail ?? false,
                                                          needPopPasscodeEnterVC: true)
                } else {
                    self?.output.goToPasscodeSettings(needReplaceOfCurrentController: true)
                }
            })
        }
    }
    
    func showPhotoAlertSheet() {
        let cancellAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel, handler: nil)
        
        let actionCamera = UIAlertAction(title: TextConstants.actionSheetTakeAPhoto, style: .default, handler: { _ in
            self.output.onChooseFromPhotoCamera(onViewController: self)
        })
        
        let actionLibriary = UIAlertAction(title: TextConstants.actionSheetChooseFromLib, style: .default, handler: { _ in
            self.output.onChooseFromPhotoLibriary(onViewController: self)
        })
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheetVC.addActions(cancellAction, actionCamera, actionLibriary)
        actionSheetVC.popoverPresentationController?.sourceView = view
        
        let originPoint = CGPoint(x: Device.winSize.width / 2 - actionSheetVC.preferredContentSize.width / 2,
                                  y: Device.winSize.height / 2 - actionSheetVC.preferredContentSize.height / 2)
        
        let sizePoint = actionSheetVC.preferredContentSize
        actionSheetVC.popoverPresentationController?.sourceRect = CGRect(origin: originPoint, size: sizePoint)
        actionSheetVC.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0) // means no arrow
        
        present(actionSheetVC, animated: true, completion: nil)
        isFromPhotoPicker = true
    }
    
    func profileInfoChanged() {
        userInfoSubView.reloadUserInfo()
    }
    
    func updatePhoto(image: UIImage) {
        userInfoSubView.updatePhoto(image: image)
    }
    
    func profileWontChangeWith(error: Error) {
        let vc = PopUpController.with(title: TextConstants.errorAlert,
                                      message: error.description,
                                      image: .error,
                                      buttonTitle: TextConstants.ok)
        present(vc, animated: true, completion: nil)
        userInfoSubView.dismissLoadingSpinner()
    }
    
    func updateStatusUser() {
        tableView.reloadData()
    }
    
}

// MARK: - UserInfoSubViewViewControllerActionsDelegate
extension SettingsViewController: UserInfoSubViewViewControllerActionsDelegate {
    func changePhotoPressed() {
        output.onChangeUserPhoto()
    }
    
    func updateUserProfile(userInfo: AccountInfoResponse) {
        output.onUpdatUserInfo(userInfo: userInfo)
    }
    
    func upgradeButtonPressed(quotaInfo: QuotaInfoResponse?) {
        output.goToPackagesWith(quotaInfo: quotaInfo)
    }
    
    func premiumButtonPressed() {
        output.goToPremium()
    }
}

// MARK: - photo picker delegatess
extension SettingsViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        var photoData: Data?
        if let imageURL = info[UIImagePickerControllerMediaURL] as? URL,
            let imageData = try? Data(contentsOf: imageURL) {
            
            photoData = imageData
            
        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            photoData = UIImageJPEGRepresentation(image, 0.9)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoData = UIImageJPEGRepresentation(image, 0.9)
        }
        if let unwrapedPhotoData = photoData {
            output.photoCaptured(data: unwrapedPhotoData)
        }
        userInfoSubView.showLoadingSpinner()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
