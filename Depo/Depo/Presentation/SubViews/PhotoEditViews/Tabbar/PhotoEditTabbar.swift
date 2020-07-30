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
    var image: UIImage? {
        switch self {
        case .filters:
            return UIImage(named: "WiFiIcon")
        case .adjustments:
            return UIImage(named: "yellowInfoIcon")
        }
    }
}

private final class PhotoEditButtonItem: UIButton {
    
    static func with(type: PhotoEditTabbarItemType) -> PhotoEditButtonItem {
        let button = PhotoEditButtonItem(type: .system)
        button.type = type
        button.isSelected = false
        return button
    }
    
    private(set) var type: PhotoEditTabbarItemType = .filters
    
    override var isHighlighted: Bool {
        didSet {
            tintColor = isHighlighted ? .white : .lightGray
        }
    }
    
    override var isSelected: Bool {
        didSet {
            tintColor = isSelected ? .white : .lightGray
        }
    }
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
        button.setImage(type.image, for: .normal)
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
