//
//  PhotoEditTabbar.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoEditTabbarDelegate: class {
    func didSelectItem(_ item: PhotoEditTabbarItemType)
}

enum PhotoEditTabbarItemType {
    case filters
    case adjustments
    
    //TODO: - Change Images
    private var templateImage: UIImage? {
        let imageName: String
        switch self {
        case .filters:
            imageName = "EditButtonIcon"
        case .adjustments:
            imageName = "cog"
        }
        return UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
    }
    
    var normalImage: UIImage? {
        templateImage?.mask(with: .lightGray)
    }
    
    var selectedImage: UIImage? {
        templateImage?.mask(with: .white)
    }
}

private final class PhotoEditButtonItem: UIButton {
    
    static func with(type: PhotoEditTabbarItemType) -> PhotoEditButtonItem {
        let button = PhotoEditButtonItem(type: .custom)
        button.type = type
        button.isSelected = false
        button.setImage(type.normalImage, for: .normal)
        button.setImage(type.selectedImage, for: .highlighted)
        button.setImage(type.selectedImage, for: .selected)
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
        backgroundColor = ColorConstants.filterBackColor
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
