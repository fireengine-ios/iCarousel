//
//  OnlyOfficePopup.swift
//  Lifebox
//
//  Created by Ozan Salman on 30.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

enum OnlyOfficeFilterType {
    case all
    case pdf
    case word
    case cell
    case slide
    
    var filterType: String {
        switch self {
        case .all:
            return "ALL"
        case .pdf:
            return "PDF"
        case .word:
            return "WORD"
        case .cell:
            return "CELL"
        case .slide:
            return "SLIDE"
        }
    }
    
    var description: String {
        switch self {
        case .all:
            return "Tümü"
        case .pdf:
            return "Pdf"
        case .word:
            return "Döküman"
        case .cell:
            return "Çalışma Tablosu"
        case .slide:
            return "Sunum"
        }
    }
}

enum OnlyOfficeType {
    case createWord
    case createExcel
    case createPowerPoint
    
    var popupExtTitle: String {
        switch self {
        case .createWord:
            return ".docx"
        case .createExcel:
            return ".xlsx"
        case .createPowerPoint:
            return ".pptx"
        }
    }
    
    var popupImage: UIImage? {
        switch self {
        case .createWord:
            return Image.popupDoc.image
        case .createExcel:
            return Image.popupExcel.image
        case .createPowerPoint:
            return Image.popupPowerPoint.image
        }
    }
    
    var documentType: String {
        switch self {
        case .createWord:
            return "WORD"
        case .createExcel:
            return "CELL"
        case .createPowerPoint:
            return "SLIDE"
        }
    }
    
    var title: String {
        switch self {
        case .createWord:
            return localized(.createWord)
        case .createExcel:
            return localized(.createExcel)
        case .createPowerPoint:
            return localized(.createPowerPoint)
        }
    }
}

typealias OnlyOfficePopupButtonHandler = (_: OnlyOfficePopup) -> Void

final class OnlyOfficePopup: BasePopUpController {
    
    @IBOutlet private weak var titleLabel: UILabel!{
        didSet {
            titleLabel.font = .appFont(.medium, size: 20)
            titleLabel.textColor = AppColor.label.color
            titleLabel.text = localized(.createDocumentPopup)
        }
    }
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.image = Image.iconEffect.image
        }
    }
    
    @IBOutlet weak var textField: UITextField!{
        didSet {
            textField.text = ""
            textField.font = .appFont(.medium, size: 16)
            textField.textColor = AppColor.label.color
            textField.layer.cornerRadius = textField.frame.size.height / 2
            textField.clipsToBounds = true
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = AppColor.settingsButtonColor.cgColor
            textField.setLeftPaddingPoints(5)
            textField.setRightPaddingPoints(5)
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged);
        }
    }
    
    @IBOutlet private weak var extLabel: UILabel!{
        didSet {
            extLabel.font = .appFont(.regular, size: 16)
        }
    }

    @IBOutlet private weak var cancelButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.cancel, for: .normal)
            newValue.titleLabel?.font = .appFont(.bold, size: 16)
            newValue.setTitleColor(AppColor.darkBlue.color, for: .normal)
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkBlue.cgColor
        }
    }
    @IBOutlet private weak var okButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.selectNameNextButtonFolder, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.borderLightGray.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.borderLightGray.cgColor
        }
    }
    
    private var titleLabelText: String = ""
    private var extLabelText: String = ""
    private var imageViewImage: UIImage = Image.iconFileDocNew.image
    private var selectedDocumentType: String = "WORD"
    private var parentFolderUuid: String = ""
    private var selectedEvent: TabBarViewController.Action = .createWord
    private let onlyOfficeService = OnlyOfficeService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    lazy var cancelAction: OnlyOfficePopupButtonHandler = { vc in
        vc.dismiss(animated: true)
    }
    lazy var okAction: OnlyOfficePopupButtonHandler = { vc in
        vc.dismiss(animated: true)
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleLabelText
        extLabel.text = extLabelText
        imageView.image = imageViewImage
    }
    
    private func selectedFileType(fileType: OnlyOfficeType, parentFolderUuid: String) {
        titleLabelText = fileType.title
        imageViewImage = fileType.popupImage!
        extLabelText = fileType.popupExtTitle
        selectedDocumentType = fileType.documentType
        self.parentFolderUuid = parentFolderUuid
    }
    
    private func selectedEventFileType(fileType: OnlyOfficeType) -> TabBarViewController.Action {
        if fileType == .createWord {
            return .createWord
        }
        if fileType == .createExcel {
            return .createExcel
        }
        if fileType == .createPowerPoint {
            return .createPowerPoint
        }
        return .createWord
    }
    
    //MARK: IBAction
    @IBAction func actionCancelButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
   
    @IBAction func actionOkButton(_ sender: UIButton)  {
        if textField.text != "" {
            let router = RouterVC()
            let segmentedController = (router.tabBarController?.customNavigationControllers[TabScreenIndex.documents.rawValue].viewControllers.first as? HeaderContainingViewController)?.childViewController as? AllFilesSegmentedController
            let vc = segmentedController?.viewControllers[0] as? BaseFilesGreedViewController
            vc?.createFile(fileName: textField.text ?? "", documentType: selectedDocumentType, parentFolderUuid: parentFolderUuid)
            self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .plus, eventLabel: .plusAction(selectedEvent))
            dismiss(animated: true)
        }        
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            okButton.backgroundColor = AppColor.borderLightGray.color
            okButton.backgroundColor = AppColor.borderLightGray.color
        } else {
            textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
            okButton.backgroundColor = AppColor.darkBlueColor.color
            okButton.backgroundColor = AppColor.darkBlueColor.color
        }
    }
}

// MARK: - Init
extension OnlyOfficePopup {
    static func with(fileType: OnlyOfficeType, parentFolderUuid: String) -> OnlyOfficePopup {
        let vc = controllerWith(fileType: fileType, parentFolderUuid: parentFolderUuid)
        return vc
    }
    
    private static func controllerWith(fileType: OnlyOfficeType, parentFolderUuid: String) -> OnlyOfficePopup {
        let vc = OnlyOfficePopup(nibName: "OnlyOfficePopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.selectedFileType(fileType: fileType, parentFolderUuid: parentFolderUuid)
        vc.selectedEvent = vc.selectedEventFileType(fileType: fileType)
        
        return vc
    }
}

extension OnlyOfficePopup: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 20
        let currentString = (self.textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
}

