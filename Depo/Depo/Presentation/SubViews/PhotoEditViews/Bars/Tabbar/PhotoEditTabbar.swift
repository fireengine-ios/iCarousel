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
    case gif
    case sticker
    
    var title: String {
        switch self {
        case .filters:
            return TextConstants.photoEditTabBarFilters
        case .adjustments:
            return TextConstants.photoEditTabBarAdjustments
        case .gif:
            return TextConstants.funGif
        case .sticker:
            return TextConstants.funSticker
        }
    }
    
    private var templateImage: UIImage? {
        let imageName: UIImage
        switch self {
        case .filters:
            imageName = Image.iconFilter.image
        case .adjustments:
            imageName = Image.iconEdit.image
        case .gif:
            imageName = Image.iconGif.image
        case .sticker:
            imageName = Image.iconSticker.image
        }
        return imageName.withRenderingMode(.alwaysTemplate)
    }
    
    var normalImage: UIImage? {
        templateImage?.mask(with: AppColor.tabBarUnselectOnly.color)
    }
    
    var selectedImage: UIImage? {
        templateImage?.mask(with: AppColor.tabBarSelect.color)
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
        button.setTitleColor(AppColor.tabBarUnselectOnly.color, for: .normal)
        button.setTitleColor(AppColor.tabBarSelect.color, for: .highlighted)
        button.setTitleColor(AppColor.tabBarSelect.color, for: .selected)
        button.titleLabel?.font = .appFont(.medium, size: 14)
        
        if Device.isIpad {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: -30)
        } else {
            button.centerVertically(topPadding: 12)
        }
        
        return button
    }
    
    private var oldFrame = CGRect.zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if oldFrame != frame {
            oldFrame = frame
            centerVertically(topPadding: 12)
        }
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
        heightAnchor.constraint(equalToConstant: Device.isIpad ? 60 : 64).activate()
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
