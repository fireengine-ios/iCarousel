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
    @IBOutlet weak var freeAppSpaceButton: CircleYellowButton!
    
    private var operation: OperationType?
    private lazy var freeUpSpace = FreeAppSpace.session
    private lazy var router = RouterVC()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRecognizer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupRecognizer()
    }
    
    private func setupRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onFreeAppSpaceButton))
        addGestureRecognizer(recognizer)
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
    
    override func configurateView() {
        super.configurateView()
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = ColorConstants.textGrayColor
        
        bigTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        bigTitleLabel.textColor = ColorConstants.textGrayColor
        
        freeAppSpaceButton.setTitle(TextConstants.freeAppSpacePopUpButtonTitle, for: .normal)
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
            titleLabel.text = TextConstants.freeAppSpacePopUpTextNormal
            bigTitleLabel.isHidden = true
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
    
    @IBAction func onFreeAppSpaceButton() {
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
