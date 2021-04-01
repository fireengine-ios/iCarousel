//
//  TopBarCustomSegmentedView.swift
//  Depo
//
//  Created by Alex Developer on 15.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

struct TopBarCustomSegmentedViewButtonModel {
    let title: String
    let callback: VoidHandler
}

final class TopBarCustomSegmentedView: UIView, NibInit {
    
    @IBOutlet private weak var separartorView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.infoPageSeparator
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.allowsSelection = true
            newValue.showsHorizontalScrollIndicator = false
            newValue.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: 16)
        }
    }
    
    private var highlightView: UIView = {
       let view = UIView()
        view.backgroundColor = ColorConstants.multifileCellSubtitleText// this one by design ColorConstants.confirmationPopupTitle
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let cellWidth: CGFloat = 120
    
    private var models = [TopBarCustomSegmentedViewButtonModel]()
    private var selectedIndex: Int = 0
    private var highlightViewLeaningConstraint: NSLayoutConstraint?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorConstants.topBarColor
    }
    
    func setup(models: [TopBarCustomSegmentedViewButtonModel], selectedIndex: Int) {
        guard
            !models.isEmpty,
            selectedIndex < models.count
        else {
            assertionFailure()
            return
        }
        
        self.selectedIndex = selectedIndex
        self.models = models
        
        setupCollection()
        setupHighlightView()
    }
    
    private func setupCollection() {
        
        collectionView.register(nibCell: TopBarCustomSegmentedCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewFlowLayout.scrollDirection = .horizontal
            collectionViewFlowLayout.estimatedItemSize = CGSize(width: cellWidth, height: 40)
            collectionViewFlowLayout.minimumLineSpacing = 4
        }
        
        collectionView.reloadData()
        collectionView.selectItem(at: IndexPath(item: selectedIndex, section: 0), animated: false, scrollPosition: .left)
        
    }
    
    func changeSelection(to index: Int) {
        guard index < models.count
        else {
            assertionFailure("button or tag is invalid")
            return
        }
        
        selectedIndex = index
        
        updateSelection(animated: true)
        
        models[safe: index]?.callback()
    }
    
    private func setupHighlightView() {

        addSubview(highlightView)
        highlightView.isHidden =  false

        guard
            models.count > 0,
            collectionView.numberOfItems(inSection: 0) > 0,
            collectionView.numberOfItems(inSection: 0) <= models.count
        else {
            assertionFailure()
            return
        }

        highlightView.translatesAutoresizingMaskIntoConstraints = false

        highlightView.heightAnchor.constraint(equalToConstant: 4).activate()

        highlightView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).activate()

        highlightView.widthAnchor.constraint(equalToConstant: cellWidth).activate()
        
    }
    
    private func updateSelection(animated: Bool = false) {
        guard
            !models.isEmpty,
            selectedIndex < models.count,
            collectionView.numberOfItems(inSection: 0) <= models.count,
            let cell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0))
        else {
            assertionFailure()
            return
        }

        if let highlightViewLeaningConstraint = highlightViewLeaningConstraint {
            highlightViewLeaningConstraint.deactivate()
            self.highlightViewLeaningConstraint = nil
        }

        highlightViewLeaningConstraint = highlightView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 0)
        highlightViewLeaningConstraint?.activate()

        guard animated else {
            return
        }

        UIView.animate(withDuration: NumericConstants.fastAnimationDuration, animations: {
            self.layoutIfNeeded()
        })
    }
}

extension TopBarCustomSegmentedView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: TopBarCustomSegmentedCell.self, for: indexPath)
        guard indexPath.item < models.count else {
            return cell
        }
        cell.setup(title: models[safe: indexPath.item]?.title ?? "")
        return cell
    }
    
}

extension TopBarCustomSegmentedView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < models.count else {
            return
        }
        
        selectedIndex = indexPath.item
        updateSelection(animated: true)
        
        models[safe: indexPath.item]?.callback()
    }
    
}
