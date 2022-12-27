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
        view.emptyLabel.text = type.title
        view.imageView.image = type.image
        return view
    }
    
    enum ViewType {
        case hiddenBin
        case trashBin
        case sharedBy
        case sharedWith
        case sharedInnerFolder
        
        var title: String {
            switch self {
                case .hiddenBin:
                    return TextConstants.hiddenBinEmpty
                case .trashBin:
                    return TextConstants.trashBinEmpty
                case .sharedBy:
                    return TextConstants.privateSharedByMeEmptyText
                case .sharedWith:
                    return TextConstants.privateSharedWithMeEmptyText
                case .sharedInnerFolder:
                    return TextConstants.privateSharedInnerFolderEmptyText
            }
        }
        
        var image: UIImage? {
            switch self {
                case .hiddenBin:
                    return Image.popupHide.image
                case .trashBin:
                    return Image.popupIconDelete.image
                case .sharedBy:
                    return Image.popupShared.image
                case .sharedWith:
                    return Image.popupShared.image
                case .sharedInnerFolder:
                    return nil
            }
        }
    }
    
    @IBOutlet private weak var emptyLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 16)
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var topOffsetConstraint: NSLayoutConstraint!
    
    var topOffset: CGFloat {
        get {
            return topOffsetConstraint.constant
        }
        set {
            topOffsetConstraint.constant = newValue
            layoutIfNeeded()
        }
    }
}
