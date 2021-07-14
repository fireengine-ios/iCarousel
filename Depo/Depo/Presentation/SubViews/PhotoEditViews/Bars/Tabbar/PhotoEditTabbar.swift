//
//  PhotoEditTabbar.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoEditTabbarDelegate: AnyObject {
    func didSelectItem(_ item: PhotoEditTabbarItemType)
}

enum PhotoEditTabbarItemType {
    case filters
    case adjustments
    
    var title: String {
        guard Device.isIpad else {
            return ""
        }
        
        switch self {
        case .filters:
            return TextConstants.photoEditTabBarFilters
        case .adjustments:
            return TextConstants.photoEditTabBarAdjustments
        }
    }
    
    private var templateImage: UIImage? {
        let imageName: String
        switch self {
        case .filters:
            imageName = "photo_edit_tabbar_filters"
        case .adjustments:
            imageName = "photo_edit_tabbar_adjustments"
        }
        return UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
    }
    
    var normalImage: UIImage? {
        templateImage?.mask(with: .white)
    }
    
    var selectedImage: UIImage? {
        templateImage?.mask(with: .lrTealish)
    }
}

private final class PhotoEditButtonItem: UIButton {
    
    static func with(type: PhotoEditTabbarItemType) -> PhotoEditButtonItem {
        let button = PhotoEditButtonItem(type: .custom)
        button.type = type
        button.setImage(type.normalImage, for: .normal)
        button.setImage(type.selectedImage, for: .highlighted)
        button.setImage(type.selectedImage, for: .selected)
        button.setTitle(type.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lrTealish, for: .highlighted)
        button.setTitleColor(.lrTealish, for: .selected)
        button.titleLabel?.font = .TurkcellSaturaRegFont(size: 16)
        
        if Device.isIpad {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: -30)
        }
        return button
    }
    
    private(set) var type: PhotoEditTabbarItemType = .filters
}

final class PhotoEditTabbar: UIView, NibInit {
    
    @IBOutlet private weak var contentView: UIStackView!
    
    private var selectedItem: PhotoEditButtonItem?
    var selectedType: PhotoEditTabbarItemType {
        selectedItem?.type ?? .filters
    }
    
    weak var delegate: PhotoEditTabbarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorConstants.photoEditBackgroundColor
        heightAnchor.constraint(equalToConstant: Device.isIpad ? 60 : 44).activate()
    }
    
    func setup(with types: [PhotoEditTabbarItemType]) {
        types.forEach { addItem(type: $0) }
        selectedItem = contentView.arrangedSubviews.first as? PhotoEditButtonItem
        selectedItem?.isSelected = true
    }
    
    private func addItem(type: PhotoEditTabbarItemType) {
        let button = PhotoEditButtonItem.with(type: type)
        button.addTarget(self, action: #selector(onSelectItem(_:)), for: .touchUpInside)
        
        contentView.addArrangedSubview(button)
    }
    
    @objc private func onSelectItem(_ sender: PhotoEditButtonItem) {
        guard selectedItem != sender else {
            return
        }
        
        selectedItem?.isSelected = false
        selectedItem = sender
        sender.isSelected = true
        
        delegate?.didSelectItem(sender.type)
    }
}
