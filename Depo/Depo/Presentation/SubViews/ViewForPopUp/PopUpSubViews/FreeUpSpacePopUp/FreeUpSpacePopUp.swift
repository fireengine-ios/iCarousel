//
//  FreeUpSpacePopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 02.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class FreeUpSpacePopUp: BaseCardView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bigTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var freeAppSpaceButton: UIButton! {
        willSet {
            newValue.contentHorizontalAlignment = .left
            newValue.sizeToFit()
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
        }
    }
    
    private var operation: OperationType?
    private lazy var freeUpSpace = FreeAppSpace.session
    private lazy var router = RouterVC()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 7.0
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

        titleLabel.font = .appFont(.medium, size: 16)
        titleLabel.textColor = AppColor.label.color
        
        bigTitleLabel.font = .appFont(.medium, size: 16)
        bigTitleLabel.textColor = AppColor.label.color
        bigTitleLabel.numberOfLines = 2
        
        freeAppSpaceButton.setTitle(TextConstants.freeAppSpacePopUpButtonTitle, for: .normal)
        freeAppSpaceButton.titleLabel?.font = .appFont(.bold, size: 14)
        freeAppSpaceButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
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
        deleteCard()
    }
    
    
    
    private func showPopup(message: String) {
        let vc = PopUpController.with(title: TextConstants.freeUpSpaceAlertTitle,
                                      message: message,
                                      image: .custom(UIImage(named: "popup_info")),
                                      buttonTitle: TextConstants.ok)
        DispatchQueue.main.async {
            vc.open()
        }
    }
}
