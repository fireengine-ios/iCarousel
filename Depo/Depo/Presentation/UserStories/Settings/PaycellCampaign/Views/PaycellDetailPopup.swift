//
//  PaycellDetailPopup.swift
//  Depo
//
//  Created by Burak Donat on 8.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import WebKit

enum PaycellDetailType {
    case detail
    case approval
}

class PaycellDetailPopup: BasePopUpController, NibInit {
    
    //MARK: -Properties
    var model: PaycellDetailModel?
    var detailType: PaycellDetailType = .detail
    private let service = PaycellCampaignService()
    
    //MARK: -IBOutlet
    @IBOutlet private weak var textView: UITextView! {
        willSet {
            newValue.backgroundColor = .clear
            newValue.isEditable = false
            newValue.textColor = .lrBrownishGrey
            newValue.font = .TurkcellSaturaMedFont(size: 13)
        }
    }
    
    @IBOutlet private weak var mainView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 2
            newValue.clipsToBounds = true
        }
    }
    
    @IBOutlet private weak var topView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.billoGray
        }
    }
    
    @IBOutlet private weak var thumbnailImage: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet private weak var webView: WKWebView!
    
    @IBOutlet private weak var approveButton: RoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.signupRedesignEulaAcceptButton, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .highlighted)
            newValue.backgroundColor = AppColor.marineTwoAndTealish.color
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 20)
        }
    }
    
    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "closeIcon"), for: .normal)
            newValue.tintColor = .black
            newValue.setTitle("", for: .normal)
        }
    }

    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: -Helpers
    @IBAction func onApproveButton(_ sender: RoundedButton) {
        switch detailType {
        case .detail:
            dismiss(animated: true)
        case .approval:
            callPaycellConsent()
        }
    }
    
    @IBAction func onCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func configureUI() {
        view.backgroundColor = AppColor.popUpBackground.color

        switch detailType {
        case .detail:
            approveButton.setTitle(TextConstants.accessibilityClose, for: .normal)
        case .approval:
            approveButton.setTitle(TextConstants.signupRedesignEulaAcceptButton, for: .normal)
        }
        
        guard let model = model else {  return }
        let hexColor = AppColor.blackColor.color?.toHexString() ?? "#000000"
        let htmlString = String().prepareHtmlString(with: model.content, hexColor: hexColor)
        webView.loadHTMLString(htmlString, baseURL: nil)
        
        if let url = URL(string: model.image) {
            thumbnailImage.sd_setImage(with: url)
        }
    }
    
    private func callPaycellConsent() {
        service.paycellConsent { result in
            switch result {
            case .success(_):
                self.dismiss(animated: true)
            case .failed(let error):
                debugLog("Paycell consent response error = \(error.description)")
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureUI()
    }
}
