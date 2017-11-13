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
    
    @IBOutlet weak var viewWith2Buttons: UIView!
    @IBOutlet weak var viewWith1Button: UIView!
    
    @IBOutlet weak var cancelButton: ButtonWithGrayCorner!
    @IBOutlet weak var restoreButton: BlueButtonWithWhiteText!
    @IBOutlet weak var bacupButton1: BlueButtonWithWhiteText!
    @IBOutlet weak var bacupButton2: BlueButtonWithWhiteText!
    
    @IBOutlet weak var backupDateLabel: UILabel!

    @IBOutlet weak var backUpContactsImageView: UIImageView!
    var output: SyncContactsViewOutput!
    var isBacupAvailable: Bool = false
    
    @IBOutlet weak var gradientLoaderIndicator: GradientLoadingIndicator!
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        //backButtonForNavigationItem(title: TextConstants.backTitle)
        
        newContactCountLabel.textColor = ColorConstants.textGrayColor
        newContactCountLabel.font = UIFont.TurkcellSaturaBolFont(size: 25)
        newContactCountLabel.text = ""
        
        newCantactSubTitleLabel.textColor = ColorConstants.textGrayColor
        newCantactSubTitleLabel.text = TextConstants.settingsBackupContactsViewNewContactsText
        newCantactSubTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        
        duplicatedCountLabel.textColor = ColorConstants.textGrayColor
        duplicatedCountLabel.font = UIFont.TurkcellSaturaBolFont(size: 25)
        duplicatedCountLabel.text = ""
        
        duplicatedSubTitleLabel.textColor = ColorConstants.textGrayColor
        duplicatedSubTitleLabel.text = TextConstants.settingsBackupContactsViewDuplicatesText
        duplicatedSubTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        
        removedCountLabel.textColor = ColorConstants.textGrayColor
        removedCountLabel.font = UIFont.TurkcellSaturaBolFont(size: 25)
        removedCountLabel.text = ""
        
        removedSubTitleLabel.textColor = ColorConstants.textGrayColor
        removedSubTitleLabel.text = TextConstants.settingsBackupContactsViewRemovedText
        removedSubTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        
        backupDateLabel.textColor = ColorConstants.textGrayColor
        backupDateLabel.font = UIFont.TurkcellSaturaItaFont(size: 14)
        
        bacupButton1.setTitle(TextConstants.settingsBacupButtonTitle, for: .normal)
        bacupButton2.setTitle(TextConstants.settingsBacupButtonTitle, for: .normal)
        restoreButton.setTitle(TextConstants.settingsBacupRestoreTitle, for: .normal)
        cancelButton.setTitle(TextConstants.settingsBacupCancelBacupTitle, for: .normal)
        cancelButton.isHidden = true
        
        setupStateWithoutBacup()
        
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
        if (isBacupAvailable){
            output.startOperation(operationType: .canselAllOperations)
        }else{
            //
        }
    }

    
    // MARK: SyncContactsViewInput
    
    func setupInitialState() {

    }
    
    func setupStateWithoutBacup(){
        titleLabel.text = TextConstants.settingsBacupNeverDidIt
        backupDateLabel.text = TextConstants.settingsBacupNewer
        viewForInformationAfterBacup.isHidden = true
        viewWith2Buttons.isHidden = true
        //cancelButton.isHidden = true
    }
    
    func showProggress(progress :Int, forOperation operation: SyncOperationType){
        gradientLoaderIndicator.progress = CGFloat(progress)
        if (operation == .backup){
            let text = String.init(format: TextConstants.settingsBacupingText, progress)
            titleLabel.text = text
            viewForInformationAfterBacup.isHidden = true
            cancelButton.setTitle(TextConstants.settingsBacupCancelBacupTitle, for: .normal)
            //cancelButton.isHidden = false
            viewWith2Buttons.isHidden = !isBacupAvailable
        }
        if (operation == .restore){
            let text = String.init(format: TextConstants.settingsRestoringText, progress)
            titleLabel.text = text
            viewForInformationAfterBacup.isHidden = true
            cancelButton.setTitle(TextConstants.settingsBacupCancelBacupTitle, for: .normal)
            //cancelButton.isHidden = false
            viewWith2Buttons.isHidden = !isBacupAvailable
        }
    }
    
    func succes(object: ContactSyncResposeModel, forOperation operation: SyncOperationType){
        output.getDateLastUpdate()
        var template: String = ""
        if (operation == .backup){
            template = TextConstants.settingsBackupedText
            isBacupAvailable = true
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
        
        viewWith2Buttons.isHidden = !isBacupAvailable
        
        cancelButton.setTitle(TextConstants.settingsBacupClearBacupTitle, for: .normal)
        //cancelButton.isHidden = false
        
    }
    
    func setDateLastBacup(dateLastBacup: Date?){
        if (dateLastBacup != nil){
            isBacupAvailable = true
            let timeInterval = dateLastBacup!.timeIntervalSinceNow
            viewWith2Buttons.isHidden = !isBacupAvailable
            if (-timeInterval < 60){
                backupDateLabel.text = TextConstants.settingsBacupLessAMinute
            }else{
                backupDateLabel.text = String.init(format: TextConstants.settingsBacupLessADay, dateLastBacup!.getDateInFormat(format: "d MMMM yyyy"))
            }
        }else{
            isBacupAvailable = false
            setupStateWithoutBacup()
        }
        
    }
}
