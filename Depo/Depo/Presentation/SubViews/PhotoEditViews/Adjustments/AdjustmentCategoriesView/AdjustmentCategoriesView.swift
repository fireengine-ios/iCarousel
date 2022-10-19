//
//  AdjustmentCategoriesView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum AdjustmentCategory: CaseIterable {
    case adjust
    case light
    case color
    case effect
    
    var title: String {
        switch self {
        case .adjust:
            return TextConstants.photoEditAdjust
        case .light:
            return TextConstants.photoEditLight
        case .color:
            return TextConstants.photoEditColor
        case .effect:
            return TextConstants.photoEditEffect
        }
    }
      
    var image: UIImage? {
        let image: UIImage
        switch self {
        case .adjust:
            image = Image.iconAdjust.image
        case .light:
            image = Image.iconLight.image
        case .color:
            image = Image.iconColor.image
        case .effect:
            image = Image.iconEffect.image
        }
        return image.withRenderingMode(.alwaysTemplate)
    }
}

protocol AdjustmentCategoriesViewDelegate: AnyObject {
    func didSelectCategory(_ category:AdjustmentCategory)
}

final class AdjustmentCategoriesView: UIView, NibInit {
    
    static func with(delegate: AdjustmentCategoriesViewDelegate?) -> AdjustmentCategoriesView {
        let view = AdjustmentCategoriesView.initFromNib()
        view.delegate = delegate
        return view
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private weak var delegate: AdjustmentCategoriesViewDelegate?
    
    private var categories = AdjustmentCategory.allCases
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.photoEditBackgroundColor
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            if Device.isIpad {
                layout.itemSize = CGSize(width: 76, height: 110)
                layout.minimumLineSpacing = 20
                let width = layout.itemSize.width * CGFloat(categories.count) + layout.minimumLineSpacing * CGFloat(categories.count - 1)
                collectionView.widthAnchor.constraint(equalToConstant: width).activate()
            } else {
                let width = Device.winSize.width / 4
                layout.itemSize = CGSize(width: width, height: 77)
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
            }
        }
        collectionView.heightAnchor.constraint(equalToConstant: Device.isIpad ? 110 : 77).activate()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
        collectionView.backgroundColor = ColorConstants.photoEditBackgroundColor
        collectionView.register(nibCell: AdjustmentCategoryCell.self)
    }
}

extension AdjustmentCategoriesView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: AdjustmentCategoryCell.self, for: indexPath)
        let category = categories[indexPath.item]
        cell.setup(with: category.title, image: category.image)
        return cell
    }
}

extension AdjustmentCategoriesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCategory(categories[indexPath.item])
    }
}
