//
//  FreeUpSpacePopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 02.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import SwiftUI

protocol FreeUpSpacePopupDelegate: AnyObject {
    func removeCard()
}


final class FreeUpSpacePopUp: BaseCardView {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bigTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var freeAppSpaceButton: UIButton! {
        willSet {
            newValue.contentHorizontalAlignment = .center
            newValue.sizeToFit()
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
        }
    }
    
    private var operation: OperationType?
    private lazy var freeUpSpace = FreeAppSpace.session
    private lazy var router = RouterVC()
    weak var popupDelegate: FreeUpSpacePopupDelegate?
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 25.0
        let h = freeAppSpaceButton.frame.origin.y + freeAppSpaceButton.frame.size.height + bottomSpace
        if calculatedH != h {
            calculatedH = h
            layoutIfNeeded()
        }
    }
    
    @IBAction func onTapFreeAppSpaceButton(_ sender: Any) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .freeUpSpace))
        
        switch freeUpSpace.state {
        case .initial, .processing:
            showPopup(message: TextConstants.freeUpSpaceInProgress)
        case .finished:
            if freeUpSpace.isEmptyDuplicates {
                showPopup(message: TextConstants.freeUpSpaceNoDuplicates)
            } else {
                router.showFreeAppSpace()
            }
        }
    }
    
    override func configurateView() {
        super.configurateView()
        
        freeAppSpaceButton.isEnabled = !CacheManager.shared.isProcessing
        
        titleLabel.font = .appFont(.regular, size: 12)
        titleLabel.textColor = UIColor.white
        
        bigTitleLabel.font = .appFont(.regular, size: 12)
        bigTitleLabel.textColor = UIColor.white
        bigTitleLabel.numberOfLines = 0
        
        freeAppSpaceButton.setTitle(TextConstants.freeAppSpacePopUpButtonTitle, for: .normal)
        cancelButton.setImage(Image.iconCancelUnborderV2.image, for: .normal)
        freeAppSpaceButton.setTitleColor(.black, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(freeAppSpaceButtonIsEnabled), name: .isProcecessPrepairing, object: nil)
    }
    
    @objc private func freeAppSpaceButtonIsEnabled() {
        freeAppSpaceButton.isEnabled = !CacheManager.shared.isProcessing
    }
    
    override func viewDeletedBySwipe() {
        onCancelButton()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.manuallyDeleteCardsByType(type: operation ?? .freeAppSpace)
    }

    func configurateWithType(viewType: OperationType) {
        operation = viewType
        
        switch viewType {
        case .freeAppSpace:
            bigTitleLabel.text = TextConstants.freeUpSpaceBigTitle
            titleLabel.text = TextConstants.freeAppSpacePopUpTextNormal
            bigTitleLabel.isHidden = false
            titleLabel.isHidden = false
            imageView.isHidden = false
        default:
            return
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onCancelButton() {
        popupDelegate?.removeCard()
        deleteCard()
        
    }
    
    
    
    private func showPopup(message: String) {
        let vc = PopUpController.with(title: TextConstants.freeUpSpaceAlertTitle,
                                      message: message,
                                      image: .custom(UIImage(named: "popupMemories")),
                                      buttonTitle: TextConstants.ok)
        DispatchQueue.main.async {
            vc.open()
        }
    }
}
