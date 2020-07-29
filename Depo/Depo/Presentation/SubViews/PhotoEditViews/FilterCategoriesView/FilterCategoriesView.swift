//
//  FilterCategoriesView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum FilterCategory: CaseIterable {
    case adjust
    case light
    case color
    case effect
    
    var title: String {
        switch self {
        case .adjust:
            return "Adjust"
        case .light:
            return "Light"
        case .color:
            return "Color"
        case .effect:
            return "Effect"
        }
    }
    
    var image: UIImage? {
        return UIImage(named: "addAlbum")
        
        switch self {
        case .adjust:
            return UIImage(named: "")
        case .light:
            return UIImage(named: "")
        case .color:
            return UIImage(named: "")
        case .effect:
            return UIImage(named: "")
        }
    }
}

protocol FilterCategoriesViewDelegate: class {
    func didSelectCategory(_ category: FilterCategory)
}

final class FilterCategoriesView: UIView, NibInit {
    
    static func with(delegate: FilterCategoriesViewDelegate) -> FilterCategoriesView {
        let view = FilterCategoriesView.initFromNib()
        view.delegate = delegate
        return view
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private weak var delegate: FilterCategoriesViewDelegate?
    
    private var categories = FilterCategory.allCases
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = Device.winSize.width / 4
            layout.itemSize = CGSize(width: width, height: 90)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = filterBackColor
        collectionView.register(nibCell: FilterCategoryCell.self)
    }
}

extension FilterCategoriesView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: FilterCategoryCell.self, for: indexPath)
        let category = categories[indexPath.item]
        cell.setup(with: category.title, image: category.image)
        return cell
    }
}

extension FilterCategoriesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCategory(categories[indexPath.item])
    }
}
