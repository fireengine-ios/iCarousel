//
//  BaseView.swift
//  Depo_LifeTech
//
//  Created by Oleg on 19.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseView: UIView, NibInit {
    
    @IBOutlet weak var whiteView: UIView?
    
    var canSwipe: Bool = true
    static let baseViewCornerRadius: CGFloat = 5
    var calculatedH: CGFloat = 0
    var cardObject: HomeCardResponse?
    lazy var homeCardsService: HomeCardsService = factory.resolve()
    var shouldScrollToTop: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configurateView()
    }
    
    func configurateView() {
        whiteView?.layer.cornerRadius = BaseView.baseViewCornerRadius
        calculatedH = frame.size.height
    }
    
    func set(object: HomeCardResponse?) {
        cardObject = object
    }
    
    func viewDeletedBySwipe() {
        deleteCard()
    }
    
    //base function for all base view
    func viewWillShow() {
        
    }
    
    func viewDidEndShow() {
        
    }
    
    func deleteCard() {
        
        if let object = cardObject, let type = object.getOperationType() {
            CardsManager.default.manuallyDeleteCardsByType(type: type, homeCardResponse: cardObject)
        }
        
        guard let id = cardObject?.id else {
            return
        }
        
        homeCardsService.delete(with: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    return
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                }
            }
        }
    }
    
    func spotlightHeight() -> CGFloat {
        return bounds.height
    }
    
}
