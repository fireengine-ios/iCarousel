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
            newValue.backgroundColor = ColorConstants.separator.color
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.allowsSelection = true
            newValue.showsHorizontalScrollIndicator = false
        }
    }
    
    private var highlightView: UIView = {
       let view = UIView()
        view.backgroundColor = ColorConstants.multifileCellSubtitleText.color// this one by design ColorConstants.Text.labelTitle.color
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let cellWidth: CGFloat = 120
    
    private var models = [TopBarCustomSegmentedViewButtonModel]()
    private var selectedIndex: Int = -1
    private var highlightViewLeaningConstraint: NSLayoutConstraint?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorConstants.topBarColor.color
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
        
        setupCollection(selectedIndex: selectedIndex)
        setupHighlightView()
    }
    
    private func setupCollection(selectedIndex: Int) {
        
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
            assertionFailure("idex out of bounds")
            return
        }
        
        guard !collectionView.visibleCells.isEmpty else {
            if collectionView.numberOfItems(inSection: 0) > 0 {
                DispatchQueue.main.async {
                    self.changeSelection(to: index)
                }
            }
            return
        }
        
        selectedIndex = index
        updateSelection(animated: true)
        collectionView.selectItem(at: IndexPath(item: self.selectedIndex, section: 0), animated: false, scrollPosition: .left)
        
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
            return
        }

        if let highlightViewLeaningConstraint = highlightViewLeaningConstraint {
            highlightViewLeaningConstraint.deactivate()
            self.highlightViewLeaningConstraint = nil
        }

        highlightViewLeaningConstraint = highlightView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 0)
        highlightViewLeaningConstraint?.activate()

        guard animated else {
            layoutIfNeeded()
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
        guard indexPath.item < models.count,
              selectedIndex != indexPath.item
        else {
            return
        }
        
        selectedIndex = indexPath.item
        updateSelection(animated: true)
        
        models[safe: indexPath.item]?.callback()
    }
    
}
