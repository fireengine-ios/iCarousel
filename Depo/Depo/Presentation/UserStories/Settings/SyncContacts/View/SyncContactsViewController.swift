//
//  SyncContactsSyncContactsViewController.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SyncContactsViewController: BaseViewController, SyncContactsViewInput, ErrorPresenter {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewForLogo: UIView!
    @IBOutlet weak var viewForInformationAfterBackUp: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var newContactCountLabel: UILabel!
    @IBOutlet weak var newCantactSubTitleLabel: UILabel!
    
    @IBOutlet weak var duplicatedCountLabel: UILabel!
    @IBOutlet weak var duplicatedSubTitleLabel: UILabel!
    
    @IBOutlet weak var removedCountLabel: UILabel!
    @IBOutlet weak var removedSubTitleLabel: UILabel!
    
    @IBOutlet weak var cancelButton: ButtonWithGrayCorner!
    @IBOutlet weak var manageContactsButton: ButtonWithGrayCorner! {
        didSet {
            manageContactsButton.setTitle(TextConstants.manageContacts, for: .normal)
        }
    }
    
    @IBOutlet weak var operationButtonsStackView: UIStackView!
    
    @IBOutlet weak var backUpButton: AdjustsFontSizeInsetsRoundedDarkBlueButton!
    @IBOutlet weak var restoreButton: AdjustsFontSizeInsetsRoundedDarkBlueButton!
    @IBOutlet weak var deleteDuplicatedButton: AdjustsFontSizeInsetsRoundedDarkBlueButton!
    
    @IBOutlet weak var backupDateLabel: UILabel!
    
    @IBOutlet weak var backUpContactsImageView: UIImageView!
    
    @IBOutlet weak var gradientLoaderIndicator: GradientLoadingIndicator!
    
    private var titleLabelAttributedTextBeforeBackup: NSAttributedString?
    
    var output: SyncContactsViewOutput!
    
    var tabBarSetup = false
    private var isFirstLaunch = true
    
    var isFullCircle: Bool {
        return gradientLoaderIndicator.circlePathLayer.strokeEnd >= 1
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialState()
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        titleLabel.text = ""
        
        newContactCountLabel.textColor = ColorConstants.textLightGrayColor
        newContactCountLabel.font = UIFont.TurkcellSaturaBolFont(size: 25)
        newContactCountLabel.text = ""
        
        newCantactSubTitleLabel.textColor = ColorConstants.textGrayColor
        newCantactSubTitleLabel.text = TextConstants.settingsBackupContactsViewNewContactsText
        newCantactSubTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        
        duplicatedCountLabel.textColor = ColorConstants.textLightGrayColor
        duplicatedCountLabel.font = UIFont.TurkcellSaturaBolFont(size: 25)
        duplicatedCountLabel.text = ""
        
        duplicatedSubTitleLabel.textColor = ColorConstants.textGrayColor
        duplicatedSubTitleLabel.text = TextConstants.settingsBackupContactsViewDuplicatesText
        duplicatedSubTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        duplicatedSubTitleLabel.adjustsFontSizeToFitWidth()
        
        removedCountLabel.textColor = ColorConstants.textLightGrayColor
        removedCountLabel.font = UIFont.TurkcellSaturaBolFont(size: 25)
        removedCountLabel.text = ""
        
        removedSubTitleLabel.textColor = ColorConstants.textGrayColor
        removedSubTitleLabel.text = TextConstants.settingsBackupContactsViewRemovedText
        removedSubTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        
        backupDateLabel.textColor = ColorConstants.textGrayColor
        backupDateLabel.font = UIFont.TurkcellSaturaItaFont(size: 14)
        backupDateLabel.text = ""
        
        backUpButton.setTitle(TextConstants.settingsBackUpButtonTitle, for: .normal)
        //FIXME: find better solution (breaking mode doesnt help for now)
        if Device.locale == "fr" {
            backUpButton.titleLabel?.numberOfLines = 1
        }
        
        restoreButton.setTitle(TextConstants.settingsBackUpRestoreTitle, for: .normal)
        deleteDuplicatedButton.setTitle(TextConstants.settingsBackUpDeleteDuplicatedButton, for: .normal)
        cancelButton.setTitle(TextConstants.settingsBackUpCancelAnalyzingTitle, for: .normal)
      
        cancelButton.adjustsFontSizeToFitWidth()
        
        if tabBarSetup {
            needToShowTabBar = true
        }
        
        output.viewIsReady()
        MenloworksAppEvents.onContactSyncPageOpen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tabBarSetup {
            homePageNavigationBarStyle()
        } else {
            navigationBarWithGradientStyle()
            setTitle(withString: TextConstants.backUpMyContacts)
        }
        output.viewWillAppear()
    }
    
    // MARK: buttons action
    
    @IBAction func onBackUpButton() {
        titleLabelAttributedTextBeforeBackup = titleLabel.attributedText
        output.startOperation(operationType: .backup)
    }
    
    @IBAction func onRestoreButton() {
        output.startOperation(operationType: .restore)
    }
    
    @IBAction func onManageContactsTapped(_ sender: Any) {
        output.onManageContacts()
    }
    
    @IBAction func onCancelButton() {
        output.startOperation(operationType: .cancel)
    }
    
    @IBAction func onDeleteDuplicatedTapped(_ sender: Any) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .deleteDuplicate))
        output.startOperation(operationType: .analyze)
    }
    
    // MARK: SyncContactsViewInput
    
    func setInitialState() {
        debugLog("SyncContactsViewController setInitialState")
        cancelButton.isHidden = true
        operationButtonsStackView.isHidden = true
        manageContactsButton.isHidden = true
        
        //FE-2066 Contact Sync SDK Update - HIDE INFO VIEW
        viewForInformationAfterBackUp.isHidden = true
//        viewForInformationAfterBackUp.setSubviewsHidden(true)
    }
    
    func setStateWithoutBackUp() {
        debugLog("SyncContactsViewController setStateWithoutBackUp")
        titleLabel.text = TextConstants.settingsBackUpNeverDidIt
        backupDateLabel.text = TextConstants.settingsBackUpNewer
        
        //FE-2066 Contact Sync SDK Update - HIDE INFO VIEW
        //If need to show backup info - uncomment this line
//        viewForInformationAfterBackUp.setSubviewsHidden(true)
        cancelButton.isHidden = true
        restoreButton.isHidden = true
        backUpButton.isHidden = false
        deleteDuplicatedButton.isHidden = true
        operationButtonsStackView.isHidden = false
        backupDateLabel.isHidden = false
        manageContactsButton.isHidden = true
    }
    
    func setStateWithBackUp() {
        debugLog("SyncContactsViewController setStateWithBackUp")
        gradientLoaderIndicator.resetProgress()
        titleLabel.attributedText = titleLabelAttributedTextBeforeBackup
        
        //FE-2066 Contact Sync SDK Update - HIDE INFO VIEW
        //If need to show backup info - uncomment these lines
//        viewForInformationAfterBackUp.setSubviewsHidden(false)
        cancelButton.isHidden = true
        restoreButton.isHidden = false
        backUpButton.isHidden = false
        deleteDuplicatedButton.isHidden = false
        operationButtonsStackView.isHidden = false
        backupDateLabel.isHidden = false
        manageContactsButton.isHidden = false
//        viewForInformationAfterBackUp.isHidden = false
    }
    
    func setOperationState(operationType: SyncOperationType) {
        //FE-2066 Contact Sync SDK Update - HIDE INFO VIEW
        //If need to show backup info - uncomment this line
//        viewForInformationAfterBackUp.setSubviewsHidden(true)
        operationButtonsStackView.isHidden = true
        backupDateLabel.isHidden = true
        manageContactsButton.isHidden = true
        
        switch operationType {
        case .analyze:
            cancelButton.setTitle(TextConstants.settingsBackUpCancelAnalyzingTitle, for: .normal)
            cancelButton.isHidden = false
        case .deleteDuplicated:
            cancelButton.setTitle(TextConstants.settingsBackUpCancelDeletingTitle, for: .normal)
            cancelButton.isHidden = false
        default:
            cancelButton.isHidden = true
        }
    }
    
    func setButtonsAvailability(contactsPermitted: Bool, contactsCount: Int, containContactsInCloud: Bool) {
        
        if isFirstLaunch && !contactsPermitted  {
            backUpButton.isEnabled = true
            isFirstLaunch = false
        } else if contactsPermitted, contactsCount == 0 {
            backUpButton.isEnabled = false
        } else if contactsPermitted, contactsCount > 0{
            backUpButton.isEnabled = true
        }  else {
            backUpButton.isEnabled = false
        }
        
        restoreButton.isEnabled = containContactsInCloud
    }
    
    func showProggress(progress: Int, count: Int, forOperation operation: SyncOperationType) {
        gradientLoaderIndicator.progress = CGFloat(progress) / 100
        
        switch operation {
        case .backup:
            titleLabel.text = String(format: TextConstants.settingsBackUpingText, progress)
        case .restore:
            titleLabel.text = String(format: TextConstants.settingsRestoringText, progress)
        case .analyze:
            titleLabel.text = String(format: TextConstants.settingsAnalyzingText, progress)
        case .deleteDuplicated:
            titleLabel.text = String(format: TextConstants.settingsDeletingText, count)
        default:
            break
        }
    }
    
    func resetProgress() {
        gradientLoaderIndicator.resetProgress()
    }
    
    func success(response: ContactSync.SyncResponse, forOperation operation: SyncOperationType) {
        setLastBackUpDate(response.date)
        
        
        /// run it here before set new attributedText to titleLabel.attributedText
        setStateWithBackUp()
        
        let template: String
        switch operation {
        case .backup:
            template = TextConstants.settingsBackupedText
        case .restore:
            template = TextConstants.settingsRestoredText
        case .getBackUpStatus:
            template = TextConstants.settingsBackupStatusText
        default:
            template = TextConstants.settingsBackupedText
        }

        
        let t = String(format: template, response.totalNumberOfContacts)
        let text = t as NSString
        let attributedText = NSMutableAttributedString(string: t)
        
        let font = UIFont.TurkcellSaturaBolFont(size: 16)
        let str = String(response.totalNumberOfContacts)
        let r = text.range(of: str)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font, range: r)
        
        titleLabel.attributedText = attributedText
        
        newContactCountLabel.text = String(response.newContactsNumber)
        duplicatedCountLabel.text = String(response.duplicatesNumber)
        removedCountLabel.text = String(response.deletedNumber)
    }
    
    func setLastBackUpDate(_ lastBackUpDate: Date?) {
        guard let lastBackUpDate = lastBackUpDate else {
            return
        }
        
        let timeToLastBackUp = -lastBackUpDate.timeIntervalSinceNow
        if (timeToLastBackUp < NumericConstants.minute) {
            backupDateLabel.text = TextConstants.settingsBackUpLessAMinute
        } else {
            backupDateLabel.text = String(format: TextConstants.settingsBackUpLessADay,
                                          lastBackUpDate.getDateInFormat(format: "d MMMM yyyy"))
        }
    }
    
    
}
