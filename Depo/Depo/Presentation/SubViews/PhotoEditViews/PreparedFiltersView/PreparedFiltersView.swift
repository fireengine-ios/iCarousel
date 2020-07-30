//
//  PreparedFiltersView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum PreparedFilterCategory {
    case recent
    case influncer
    
    var title: String {
        switch self {
        case .recent:
            return "Recent"
        case .influncer:
            return "Influncer filters"
        }
    }
    
    static var tempArray = [PreparedFilter(name: "Filter1", image: UIImage(named: "addAlbum"), category: .recent),
                            PreparedFilter(name: "Filter2", image: UIImage(named: "addAlbum"), category: .recent),
                            PreparedFilter(name: "Filter3", image: UIImage(named: "addAlbum"), category: .recent),
                            PreparedFilter(name: "Filter4", image: UIImage(named: "addAlbum"), category: .recent),
                            PreparedFilter(name: "Filter5", image: UIImage(named: "addAlbum"), category: .recent),
                            PreparedFilter(name: "Filter6", image: UIImage(named: "addAlbum"), category: .influncer),
                            PreparedFilter(name: "Filter7", image: UIImage(named: "addAlbum"), category: .influncer),
                            PreparedFilter(name: "Filter8", image: UIImage(named: "addAlbum"), category: .influncer),
                            PreparedFilter(name: "Filter9", image: UIImage(named: "addAlbum"), category: .influncer),
                            PreparedFilter(name: "Filter10", image: UIImage(named: "addAlbum"), category: .influncer)]
}

struct PreparedFilter {
    let name: String
    let image: UIImage?
    let category: PreparedFilterCategory
}

protocol PreparedFiltersViewDelegate: class {
    func didSelectPreparedFilter(_ filter: PreparedFilter)
}

final class FilterCategoryButton: UIButton {
    static func with(category: PreparedFilterCategory?) -> FilterCategoryButton {
        let button = FilterCategoryButton(type: .custom)
        button.category = category

        let title = category?.title ?? "All Filters"
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = .TurkcellSaturaDemFont(size: 14)
        
        return button
    }
    
    private(set) var category: PreparedFilterCategory?
    
//    override var isHighlighted: Bool {
//        didSet {
//            tintColor = isHighlighted ? .white : .lightGray
//        }
//    }
//
//    override var isSelected: Bool {
//        didSet {
//            tintColor = isSelected ? .white : .lightGray
//        }
//    }
}

final class PreparedFiltersView: UIView, NibInit {
    
    static func with(filters: [PreparedFilter], delegate: PreparedFiltersViewDelegate?) -> PreparedFiltersView {
        let view = PreparedFiltersView.initFromNib()
        view.delegate = delegate
        view.allFilters = filters
        
        let categories: [PreparedFilterCategory?] = [nil, .recent, .influncer]
        view.categoryButtons = categories.map { FilterCategoryButton.with(category: $0) }
        
        view.selectedCategory = nil
        return view
    }
    
    @IBOutlet private weak var filterCategoriesScrollView: UIScrollView! {
        willSet {
            newValue.backgroundColor = ColorConstants.filterBackColor
        }
    }
    
    @IBOutlet private weak var filterCategoriesView: UIStackView! {
        willSet {
            newValue.spacing = 16
        }
    }
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var categoryButtons = [FilterCategoryButton]() {
        didSet {
            categoryButtons.forEach {
                $0.addTarget(self, action: #selector(onSwitchFilterCategory(_:)), for: .touchUpInside)
                filterCategoriesView.addArrangedSubview($0)
            }
        }
    }

    private weak var delegate: PreparedFiltersViewDelegate?
    private var allFilters = [PreparedFilter]()
    
    private var filters = [PreparedFilter]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var selectedCategory: PreparedFilterCategory? {
        didSet {
            categoryButtons.forEach { $0.isSelected = ($0.category == selectedCategory) }
            
            if let category = selectedCategory {
                filters = allFilters.filter { $0.category == category }
            } else {
                filters = allFilters
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.filterBackColor
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 50, height: 80)
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = ColorConstants.filterBackColor
        collectionView.register(nibCell: PreparedFilterCell.self)
    }
    
    @objc private func onSwitchFilterCategory(_ sender: FilterCategoryButton) {
        selectedCategory = sender.category
    }
}

//MARK: - UICollectionViewDataSource

extension PreparedFiltersView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: PreparedFilterCell.self, for: indexPath)
        let filter = filters[indexPath.item]
        cell.setup(title: filter.name, image: filter.image)
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension PreparedFiltersView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectPreparedFilter(filters[indexPath.item])
    }
}
