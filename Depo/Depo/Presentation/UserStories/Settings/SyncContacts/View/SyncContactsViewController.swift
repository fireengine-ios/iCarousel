//
//  SyncContactsSyncContactsViewController.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SyncContactsViewController:BaseViewController, SyncContactsViewInput {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewForLogo: UIView!
    @IBOutlet weak var viewForInformationAfterBacup: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var newContactCountLabel: UILabel!
    @IBOutlet weak var newCantactSubTitleLabel: UILabel!
    
    @IBOutlet weak var duplicatedCountLabel: UILabel!
    @IBOutlet weak var duplicatedSubTitleLabel: UILabel!
    
    @IBOutlet weak var removedCountLabel: UILabel!
    @IBOutlet weak var removedSubTitleLabel: UILabel!
    
    @IBOutlet weak var cancelButton: ButtonWithGrayCorner!
    
    @IBOutlet weak var deleteDuplicatedButton: BlueButtonWithWhiteText!
    @IBOutlet weak var restoreButton: BlueButtonWithWhiteText!
    @IBOutlet weak var backUpButton: BlueButtonWithWhiteText!
    
    @IBOutlet weak var backupDateLabel: UILabel!

    @IBOutlet weak var backUpContactsImageView: UIImageView!
    
    var output: SyncContactsViewOutput!
    var isBackUpAvailable: Bool = false {
        didSet {
            isBackUpAvailable ? setStateWithBackUp() : setStateWithoutBackUp()
        }
    }
    
    @IBOutlet weak var gradientLoaderIndicator: GradientLoadingIndicator!
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        //backButtonForNavigationItem(title: TextConstants.backTitle)
        
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
        
        removedCountLabel.textColor = ColorConstants.textLightGrayColor
        removedCountLabel.font = UIFont.TurkcellSaturaBolFont(size: 25)
        removedCountLabel.text = ""
        
        removedSubTitleLabel.textColor = ColorConstants.textGrayColor
        removedSubTitleLabel.text = TextConstants.settingsBackupContactsViewRemovedText
        removedSubTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        
        backupDateLabel.textColor = ColorConstants.textGrayColor
        backupDateLabel.font = UIFont.TurkcellSaturaItaFont(size: 14)
        
        backUpButton.setTitle(TextConstants.settingsBackUpButtonTitle, for: .normal)
        backUpButton.setTitle(TextConstants.settingsBackUpButtonTitle, for: .normal)
        restoreButton.setTitle(TextConstants.settingsBackUpRestoreTitle, for: .normal)
        cancelButton.setTitle(TextConstants.settingsBackUpCancelBackUpTitle, for: .normal)
        
        setStateWithoutBackUp()
        
        output.getDateLastUpdate()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (Device.isIpad){
//           hidenNavigationBarStyle()
        } else {
            navigationBarWithGradientStyle()
        }
        setTitle(withString: TextConstants.backUpMyContacts)
        output.viewIsReady()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        visibleNavigationBarStyle()
    }
    
    
    // MARK: buttons action
    
    @IBAction func onBacupButton(){
        output.startOperation(operationType: .backup)
    }
    
    @IBAction func onRestoreButton(){
        output.startOperation(operationType: .restore)
    }
    
    @IBAction func onCancelButton(){
        if (isBackUpAvailable) {
            output.startOperation(operationType: .cancelAllOperations)
        } else {
            output.startOperation(operationType: .clear)
        }
    }
    
    // MARK: SyncContactsViewInput
    
    func setInitialState() {

    }
    
    func setStateWithoutBackUp(){
        titleLabel.text = TextConstants.settingsBackUpNeverDidIt
        backupDateLabel.text = TextConstants.settingsBackUpNewer
        viewForInformationAfterBacup.isHidden = true
        cancelButton.isHidden = true
    }
    
    func setStateWithBackUp() {
        cancelButton.setTitle(TextConstants.settingsBackUpClearBackUpTitle, for: .normal)
        cancelButton.isHidden = false
    }
    
    func showProggress(progress :Int, forOperation operation: SyncOperationType){
        gradientLoaderIndicator.progress = CGFloat(progress)
        if (operation == .backup){
            let text = String.init(format: TextConstants.settingsBackUpingText, progress)
            titleLabel.text = text
            viewForInformationAfterBacup.isHidden = true
            cancelButton.setTitle(TextConstants.settingsBackUpCancelBackUpTitle, for: .normal)
        }
        if (operation == .restore){
            let text = String.init(format: TextConstants.settingsRestoringText, progress)
            titleLabel.text = text
            viewForInformationAfterBacup.isHidden = true
            cancelButton.setTitle(TextConstants.settingsBackUpCancelBackUpTitle, for: .normal)
        }
        cancelButton.isHidden = false
    }
    
    func success(object: ContactSyncResposeModel, forOperation operation: SyncOperationType){
        output.getDateLastUpdate()
        var template: String = ""
        if (operation == .backup){
            template = TextConstants.settingsBackupedText
            isBackUpAvailable = true
        }else{
            template = TextConstants.settingsRestoredText
        }
        
        let t = String.init(format: template, object.totalNumberOfContacts)
        let text = t as NSString
        let attributedText = NSMutableAttributedString(string: t)
        
        let font = UIFont.TurkcellSaturaBolFont(size: 16)
        let str = String(object.totalNumberOfContacts)
        let r = text.range(of: str)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font, range: r)
        
        titleLabel.attributedText = attributedText
        viewForInformationAfterBacup.isHidden = false
        
        newContactCountLabel.text = String(object.newContactsNumber)
        duplicatedCountLabel.text = String(object.duplicatesNumber)
        removedCountLabel.text = String(object.deletedNumber)
    }
    
    func setDateLastBacup(dateLastBacup: Date?){
        if (dateLastBacup != nil){
            isBackUpAvailable = true
            let timeInterval = dateLastBacup!.timeIntervalSinceNow
            if (-timeInterval < 60){
                backupDateLabel.text = TextConstants.settingsBackUpLessAMinute
            } else {
                backupDateLabel.text = String.init(format: TextConstants.settingsBackUpLessADay, dateLastBacup!.getDateInFormat(format: "d MMMM yyyy"))
            }
        }else{
            isBackUpAvailable = false
            setStateWithoutBackUp()
        }
        
    }
}
