//
//  UploadSelectionListViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 04.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class UploadSelectionListViewController: BaseViewController, NibInit {

    @IBOutlet private weak var headerContainer: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .GTAmericaStandardMediumFont(size: 16)
            newValue.textColor = ColorConstants.Text.labelTitle
            newValue.text = TextConstants.uploadSelectPageTitle
        }
    }
    
    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setImage(UIImage(named: "close"), for: .normal)
        }
    }
    
    @IBOutlet private weak var footerContainer: UIView!
    
    @IBOutlet private weak var shareButton: InsetsButton! {
        willSet {
            let titleColor = UIColor.white
            let titleColorHigh = titleColor.lighter(by: 30)
            
            newValue.setTitle(TextConstants.uploadSelectButtonTitle, for: .normal)
            newValue.backgroundColor = ColorConstants.confirmationPopupButton
            newValue.setTitleColor(.white, for: .normal)
            newValue.setTitleColor(titleColorHigh, for: .highlighted)
            
            newValue.titleLabel?.font = .GTAmericaStandardMediumFont(size: 14)
            
            newValue.layer.borderColor = ColorConstants.confirmationPopupButton.cgColor
            newValue.layer.borderWidth = 2
            newValue.layer.cornerRadius = 5
            newValue.adjustsFontSizeToFitWidth()
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 2)
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.backgroundColor = .white
            newValue.allowsSelection = false
            newValue.isScrollEnabled = true
            newValue.alwaysBounceVertical = true
            newValue.alwaysBounceHorizontal = false
        }
    }
    
    private lazy var collectionManager = UploadSelectionListCollectionManager.with(collectionView: collectionView)
    
    private var items = [WrapData]()
    private var completionHandler: ValueHandler<[WrapData]>?
    
    //MARK: - Override
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionManager.reload(with: items)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Private
    
    @IBAction private func onShareTap(_ sender: Any) {
        dismiss(animated: true) {
            self.completionHandler?(self.collectionManager.items)
        }
        
    }
    
    @IBAction func onCloseButtonTap(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension UploadSelectionListViewController {
    
    static func with(items: [WrapData], completion: @escaping ValueHandler<[WrapData]>) -> UploadSelectionListViewController {
        let controller = UploadSelectionListViewController.initFromNib()
        controller.items = items
        controller.completionHandler = completion
        return controller
    }
}
