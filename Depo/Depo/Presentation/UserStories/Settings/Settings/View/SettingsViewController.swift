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
    
    func goToTermsAndPolicy() 
    
    func goToUsageInfo()
    
    func goToActivityTimeline()
    
    func goToPermissions()
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool, needPopPasscodeEnterVC: Bool)
}

class SettingsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var tableDataArray = [[String]]()
    var output: SettingsViewOutput!

    private let userInfoSubView = UserInfoSubViewModuleInitializer.initializeViewController()
    
    weak var settingsDelegate: SettingsDelegate?
    
    private var isFromPhotoPicker = false
    
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    
    enum SettingsCellType: Int {
        case SectionOne
        case SectionTwo
        case SectionThree
        case SectionFour
        
        enum AllSectionTypes: Int {
            case contactSync
            case autoUpload
            case periodicContactSync
            case faceImage
            case connectAccounts
            case permissions
            case myActivities
            case usageInfo
            case passcode
            case security
            case helpAndSupport
            case termsAndPolicy
            case logout
            
            var text: String {
                switch self {
                case .contactSync: return TextConstants.settingsViewCellBeckup
                case .autoUpload: return TextConstants.settingsViewCellAutoUpload
                case .periodicContactSync: return TextConstants.settingsViewCellContactsSync
                case .faceImage: return TextConstants.settingsViewCellFaceAndImageGrouping
                case .connectAccounts: return TextConstants.settingsViewCellConnectedAccounts
                case .permissions: return TextConstants.settingsViewCellPermissions
                case .myActivities: return TextConstants.settingsViewCellActivityTimline
                case .usageInfo: return TextConstants.settingsViewCellUsageInfo
                case .passcode: return TextConstants.settingsViewCellPasscode
                case .security: return TextConstants.settingsViewCellLoginSettings
                case .helpAndSupport: return TextConstants.settingsViewCellHelp
                case .termsAndPolicy: return TextConstants.settingsViewCellPrivacyAndTerms
                case .logout: return TextConstants.settingsViewCellLogout
                }
            }
            
            static let allSectionOneTypes = [contactSync, autoUpload, periodicContactSync, faceImage]
            static let allSectionTwoTypes = [connectAccounts, permissions]
            static let allSectionThreeTypes = [myActivities, usageInfo, passcode, security]
            static let allSectionFourTypes = [helpAndSupport, termsAndPolicy, logout]
        }
        
        var cellTypes: [AllSectionTypes] {
            switch self {
            case .SectionOne:
                return AllSectionTypes.allSectionOneTypes
            case .SectionTwo:
                return AllSectionTypes.allSectionTwoTypes
            case .SectionThree:
                return AllSectionTypes.allSectionThreeTypes
            case .SectionFour:
                return AllSectionTypes.allSectionFourTypes
            }
        }
    }
    
    var cellTypes: [[SettingsCellType.AllSectionTypes]] = []
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        output.viewIsReady()
        
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
        super.viewDidAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView.tableHeaderView == nil {
            setupTableViewSubview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    private func setupTableView() {
        tableView.register(nibCell: SettingsTableViewCell.self)
        tableView.backgroundColor = .clear
    }
    
    private func setupTableViewSubview() {
        let header = userInfoSubView.view
        userInfoSubView.actionsDelegate = self
        tableView.tableHeaderView = header
        header?.heightAnchor.constraint(equalToConstant: 201).activate()
        
        let footer = SettingFooterView.initFromNib()
        footer.delegate = self
        tableView.tableFooterView = footer
        footer.heightAnchor.constraint(equalToConstant: 110).activate()
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 14
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SettingHeaderView.viewFromNib()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == cellTypes.count - 1 {
            return SettingHeaderView.viewFromNib()
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = configureSettingsTableViewCell(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.scrollRectToVisible(tableView.rectForRow(at: indexPath), animated: true)
        if !Device.isIpad {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            splitViewController?.navigationController?.viewControllers.last?.navigationItem.rightBarButtonItem = nil
        }
        
        let settingsSection = SettingsCellType(rawValue: indexPath.section)
        guard let section = settingsSection else {
            return
        }
        let cellType = section.cellTypes[indexPath.row]
        
        switch cellType {
        case .contactSync:
            if settingsDelegate != nil {
                settingsDelegate!.goToContactSync()
            } else {
                output.goToContactSync()
            }
        case .autoUpload:
            if settingsDelegate != nil {
                settingsDelegate!.goToAutoUpload()
            } else {
                output.goToAutoApload()
            }
        case .periodicContactSync:
            if settingsDelegate != nil {
                settingsDelegate?.goToPeriodicContactSync()
            } else {
                output.goToPeriodicContactSync()
            }
        case .faceImage:
            if settingsDelegate != nil {
                settingsDelegate?.goToFaceImage()
            } else {
                output.goToFaceImage()
            }
        case .connectAccounts:
            MenloworksTagsService.shared.onSocialMediaPageClicked()
            if let delegate = settingsDelegate {
                delegate.goToConnectedAccounts()
            } else {
                output.goToConnectedAccounts()
            }
        case .permissions:
            if let delegate = settingsDelegate {
                delegate.goToPermissions()
            } else {
                output.goToPermissions()
            }
        case .myActivities:
            if settingsDelegate != nil {
                settingsDelegate!.goToActivityTimeline()
            } else {
                output.goToActivityTimeline()
            }
        case .usageInfo:
            if let settingsDelegate = settingsDelegate {
                settingsDelegate.goToUsageInfo()
            } else {
                output.goToUsageInfo()
            }
        case .passcode:
            showPasscodeOrPasscodeSettings()
        case .security:
            output.goTurkcellSecurity()
        case .helpAndSupport:
            if let settingsDelegate = settingsDelegate {
                settingsDelegate.goToHelpAndSupport()
            } else {
                output.goToHelpAndSupport()
            }
        case .termsAndPolicy:
            if let settingsDelegate = settingsDelegate {
                settingsDelegate.goToTermsAndPolicy()
            } else {
                output.goToTermsAndPolicy()
            }
        case .logout:
            output.onLogout()
        }
        
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource Private Utility Methods
    
    private func configureSettingsTableViewCell(indexPath: IndexPath) -> SettingsTableViewCell {
        let cell = tableView.dequeue(reusable: SettingsTableViewCell.self, for: indexPath)
        cell.selectionStyle = .none
        let array = cellTypes[indexPath.section]
        let cellType = array[indexPath.row]
        let text = cellType == .passcode ? String(format: cellType.text, biometricsManager.biometricsTitle) : cellType.text
        cell.setTextForLabel(titleText: text, needShowSeparator: indexPath.row != array.count - 1)
        return cell
    }
    
    private func showPasscodeOrPasscodeSettings() {
        if output.isPasscodeEmpty {
            if let settingsDelegate = settingsDelegate {
                settingsDelegate.goToPasscodeSettings(isTurkcell: output.isTurkCellUser,
                                                      inNeedOfMail: output.isMailRequired,
                                                      needPopPasscodeEnterVC: false)
            } else {
                output.goToPasscodeSettings(needReplaceOfCurrentController: false)
            }
        } else {
            output.openPasscode(handler: { [weak self] in
                if let settingsDelegate = self?.settingsDelegate {
                    settingsDelegate.goToPasscodeSettings(isTurkcell: self?.output.isTurkCellUser ?? false,
                                                          inNeedOfMail: self?.output.isMailRequired ?? false,
                                                          needPopPasscodeEnterVC: true)
                } else {
                    self?.output.goToPasscodeSettings(needReplaceOfCurrentController: true)
                }
            })
        }
    }
    
}

// MARK: - SettingsViewInput
extension SettingsViewController: SettingsViewInput {
    
    func prepareCellsData(isPermissionShown: Bool) {
        cellTypes = []
        var accountCells = [SettingsCellType.AllSectionTypes.connectAccounts]
        if isPermissionShown {
            accountCells.append(SettingsCellType.AllSectionTypes.permissions)
        }
        cellTypes = [
            [SettingsCellType.AllSectionTypes.contactSync,
             SettingsCellType.AllSectionTypes.autoUpload,
             SettingsCellType.AllSectionTypes.periodicContactSync,
             SettingsCellType.AllSectionTypes.faceImage],
            
            accountCells,
            
            [SettingsCellType.AllSectionTypes.myActivities,
            SettingsCellType.AllSectionTypes.usageInfo,
            SettingsCellType.AllSectionTypes.passcode,
            SettingsCellType.AllSectionTypes.security],
            
            [SettingsCellType.AllSectionTypes.helpAndSupport,
             SettingsCellType.AllSectionTypes.termsAndPolicy,
             SettingsCellType.AllSectionTypes.logout]
        ]
        tableView.reloadData()
    }
    
    func showProfileAlertSheet(userInfo: AccountInfoResponse, isProfileAlert: Bool) {
        let actionSheetVC = getProfileAlertSheet(userInfo: userInfo, isProfileAlert: isProfileAlert)
        present(actionSheetVC, animated: true, completion: nil)
    }
    
    func updatePhoto(image: UIImage) {
        userInfoSubView.updatePhoto(image: image)
    }
    
    func profileInfoChanged() {
        userInfoSubView.reloadUserInfo()
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
    
    // MARK: - SettingsViewInput Private Utility Methods
    
    private func getProfileAlertSheet(userInfo: AccountInfoResponse, isProfileAlert: Bool) -> UIAlertController {
        let cancellAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel, handler: nil)
        var firstAlertAction: UIAlertAction?
        var secondAlertAction: UIAlertAction?
        
        switch isProfileAlert {
        case true:
            firstAlertAction = getProfileDetailAction(userInfo: userInfo)
            secondAlertAction = getEditPhotoAction(userInfo: userInfo)
        case false:
            firstAlertAction = getCameraAction()
            secondAlertAction = getLibraryAction()
            isFromPhotoPicker = true
        }
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheetVC.addActions(cancellAction, firstAlertAction ?? getCameraAction(), secondAlertAction ?? getLibraryAction())
        actionSheetVC.popoverPresentationController?.sourceView = view
        
        let originPoint = CGPoint(x: Device.winSize.width / 2 - actionSheetVC.preferredContentSize.width / 2,
                                  y: Device.winSize.height / 2 - actionSheetVC.preferredContentSize.height / 2)
        
        let sizePoint = actionSheetVC.preferredContentSize
        actionSheetVC.popoverPresentationController?.sourceRect = CGRect(origin: originPoint, size: sizePoint)
        actionSheetVC.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0) // means no arrow
        
        return actionSheetVC
    }
    
    private func getCameraAction() -> UIAlertAction {
        return UIAlertAction(title: TextConstants.actionSheetTakeAPhoto, style: .default, handler: { _ in
            self.output.onChooseFromPhotoCamera(onViewController: self)
        })
    }
    
    private func getLibraryAction() -> UIAlertAction {
        return UIAlertAction(title: TextConstants.actionSheetChooseFromLib, style: .default, handler: { _ in
            self.output.onChooseFromPhotoLibriary(onViewController: self)
        })
    }
    
    private func getProfileDetailAction(userInfo: AccountInfoResponse) -> UIAlertAction {
        return UIAlertAction(title: TextConstants.actionSheetProfileDetails, style: .default, handler: { _ in
            self.output.goToMyProfile(userInfo: userInfo)
        })
    }
    
    private func getEditPhotoAction(userInfo: AccountInfoResponse) -> UIAlertAction {
        return UIAlertAction(title: TextConstants.actionSheetEditProfilePhoto, style: .default, handler: { _ in
            self.showProfileAlertSheet(userInfo: userInfo, isProfileAlert: false)
        })
    }
}

// MARK: - UserInfoSubViewViewControllerActionsDelegate
extension SettingsViewController: UserInfoSubViewViewControllerActionsDelegate {
    func changePhotoPressed() {
        output.onChangeUserPhoto()
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

//MARK: - SettingFooterViewDelegate
extension SettingsViewController: SettingFooterViewDelegate {
    func didTappedLeaveFeedback() {
        RouterVC().showFeedbackSubView()
    }
}
