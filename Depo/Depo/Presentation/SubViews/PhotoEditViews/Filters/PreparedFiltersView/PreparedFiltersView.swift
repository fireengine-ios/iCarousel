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
}

struct PreparedFilter {
    let name: String
    let image: UIImage?
    let category: PreparedFilterCategory
}

protocol PreparedFiltersViewDelegate: class {
    func didSelectOriginal()
    func didSelectFilter(_ type: FilterType)
    func needOpenFilterSlider(for type: FilterType)
}

private final class FilterCategoryButton: UIButton {
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
}

final class PreparedFiltersView: UIView, NibInit {
    
    static func with(previewImage: UIImage, manager: FilterManager, delegate: PreparedFiltersViewDelegate?) -> PreparedFiltersView {
        let view = PreparedFiltersView.initFromNib()
        view.delegate = delegate
        view.filtermanager = manager
        view.previewImage = previewImage
        view.setupImages()
        
//        let categories: [PreparedFilterCategory?] = [nil, .recent, .influncer]
//        view.categoryButtons = categories.map { FilterCategoryButton.with(category: $0) }
//        view.selectedCategory = nil
        return view
    }
    
    @IBOutlet private weak var filterCategoriesScrollView: UIScrollView! {
        willSet {
            newValue.backgroundColor = ColorConstants.photoEditBackgroundColor
            newValue.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: 8)
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
    
    private var filtermanager: FilterManager?
    private var previewImage = UIImage()
    private var filters = FilterType.allCases
    private var filtersData = [FilterType: UIImage]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
//    private var selectedCategory: PreparedFilterCategory? {
//        didSet {
//            categoryButtons.forEach { $0.isSelected = ($0.category == selectedCategory) }
//
//            if let category = selectedCategory {
//                filters = allFilters.filter { $0.category == category }
//            } else {
//                filters = allFilters
//            }
//        }
//    }
    
    //MARK: - Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.photoEditBackgroundColor
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 64, height: 88)
            layout.minimumLineSpacing = Device.isIpad ? 20 : 16
        }
        collectionView.heightAnchor.constraint(equalToConstant: Device.isIpad ? 128 : 110).activate()
        collectionView.contentInset = Device.isIpad ? UIEdgeInsets(topBottom: 20, rightLeft: 20) : UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = ColorConstants.photoEditBackgroundColor
        collectionView.register(nibCell: PreparedFilterCell.self)
    }
    
    private func setupImages() {
        guard let manager = filtermanager else {
            assertionFailure("Need setup filter manager")
            return
        }
        filtersData = manager.filteredPreviews(image: previewImage)
        selectOriginal(animated: false)
    }
    
    @objc private func onSwitchFilterCategory(_ sender: FilterCategoryButton) {
//        selectedCategory = sender.category
    }
    
    func resetToOriginal() {
        selectOriginal(animated: true)
    }
    
    private func selectOriginal(animated: Bool) {
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: animated, scrollPosition: .left)
    }
}

//MARK: - UICollectionViewDataSource

extension PreparedFiltersView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filtersData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: PreparedFilterCell.self, for: indexPath)
        
        if indexPath.row == 0 {
            cell.setup(title: TextConstants.photoEditFilterOriginal, image: previewImage, isOriginal: true)
        } else if let filter = filters[safe: indexPath.row - 1] {
            let image = filtersData[filter]
            cell.setup(title: filter.title, image: image, isOriginal: false)
        }
        cell.isSelected = collectionView.indexPathsForSelectedItems?.first?.row == indexPath.row
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension PreparedFiltersView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.cellForItem(at: indexPath)?.isSelected == true, let type = filters[safe: indexPath.item - 1] {
            delegate?.needOpenFilterSlider(for: type)
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.didSelectOriginal()
        } else if let type = filters[safe: indexPath.item - 1] {
            delegate?.didSelectFilter(type)
        }
    }
}
