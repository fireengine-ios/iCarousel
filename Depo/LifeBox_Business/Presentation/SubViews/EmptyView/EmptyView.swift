//
//  EmptyView.swift
//  Depo
//
//  Created by Andrei Novikau on 12/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class EmptyView: UIView, NibInit {

    static func view(with type: ViewType) -> EmptyView {
        let view = EmptyView.initFromNib()
        view.emptyLabel.text = type.description
        view.imageView.image = type.image
        if let titleText = type.title {
            view.emptyTitleLabel.text = titleText
            view.empyTitleLabelHeight.constant = 19
        }
        if let headerText = type.header {
            view.searchHeaderLabel.text = headerText
            view.searchHeaderLabel.isHidden = false
        }
        
        return view
    }
    
    enum ViewType {
        case hiddenBin
        case trashBin
        case sharedBy
        case sharedWith
        case sharedInnerFolder
        case trashBinInnerFolder
        case sharedArea
        case myDisk
        case search(text: String)
        
        var description: String {
            switch self {
                case .hiddenBin:
                    return TextConstants.hiddenBinEmpty
                case .trashBin, .trashBinInnerFolder:
                    return TextConstants.trashBinEmptyPage
                case .sharedBy:
                    return TextConstants.sharedByMeEmptyPage
                case .sharedWith:
                    return TextConstants.sharedWithMeEmptyPage
                case .sharedInnerFolder:
                    return TextConstants.folderEmptyPage
                case .sharedArea:
                    return TextConstants.sharedAreaEmptyPage
                case .myDisk:
                    return TextConstants.myDiskEmptyPage
                case .search(let text):
                    return String(format: TextConstants.emptySearchDescription, text)
            }
        }
        
        var title: String? {
            switch self {
                case .hiddenBin, .trashBin, .trashBinInnerFolder, .sharedBy, .sharedWith, .sharedInnerFolder, .sharedArea, .myDisk:
                    return nil
                case .search:
                    return TextConstants.emptySearchTitle
            }
        }
        
        var header: String? {
            switch self {
                case .hiddenBin, .trashBin, .trashBinInnerFolder, .sharedBy, .sharedWith, .sharedInnerFolder, .sharedArea, .myDisk:
                    return nil
                case .search(let text):
                    return String(format: TextConstants.emptySearchHeader, text)
            }
        }
        
        var image: UIImage? {
            switch self {
                case .hiddenBin:
                    return UIImage(named: "hidden_big")
                case .trashBin, .trashBinInnerFolder:
                    return UIImage(named: "trash_bin_empty")
                case .sharedBy:
                    return nil
                case .sharedWith:
                    return nil
                case .sharedInnerFolder:
                    return nil
                case .sharedArea:
                    return nil
                case .myDisk:
                    return nil
                case .search:
                    return UIImage(named: "emptySearch")
            }
        }
    }
    
    @IBOutlet private weak var emptyLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = UIColor.lrBrownishGrey.withAlphaComponent(0.5)
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14)
        }
    }
    
    
    @IBOutlet private weak var emptyTitleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = ColorConstants.confirmationPopupTitle
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 16)
        }
    }
    
    @IBOutlet private weak var searchHeaderLabel: UILabel! {
        willSet {
            newValue.isHidden = true
            newValue.text = ""
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = ColorConstants.confirmationPopupTitle
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 16)
        }
    }
    
    @IBOutlet private weak var empyTitleLabelHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var topOffsetConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomOffsetConstraint: NSLayoutConstraint!

    
    func set(queryText: String) {
        searchHeaderLabel.text = queryText
    }
    
    var topOffset: CGFloat {
        get {
            return topOffsetConstraint.constant
        }
        set {
            topOffsetConstraint.constant = newValue
            layoutIfNeeded()
        }
    }
    
    var bottomOffset: CGFloat {
        get {
            return bottomOffsetConstraint.constant
        }
        set {
            bottomOffsetConstraint.constant = newValue
            layoutIfNeeded()
        }
    }
}
