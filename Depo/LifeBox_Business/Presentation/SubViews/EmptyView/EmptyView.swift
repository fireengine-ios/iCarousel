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
        case sharedArea
        case myDisk
        
        var title: String {
            switch self {
                case .hiddenBin:
                    return TextConstants.hiddenBinEmpty
                case .trashBin:
                    return TextConstants.trashBinEmpty
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
            }
        }
        
        var image: UIImage? {
            switch self {
                case .hiddenBin:
                    return UIImage(named: "hidden_big")
                case .trashBin:
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
            }
        }
    }
    
    @IBOutlet private weak var emptyLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = UIColor.lrBrownishGrey.withAlphaComponent(0.5)
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 18)
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
