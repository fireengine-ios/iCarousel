//
//  HLSFilterView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class HLSFilterView: AdjustmentsView, NibInit {

    static func with(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) -> HLSFilterView {
        let view = HLSFilterView.initFromNib()
        view.setup(parameters: parameters, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var colorAssets: UICollectionView!
    
    private let colors: [UIColor] = [.black, .blue, .brown, .cyan, .green, .magenta, .orange, .purple, .red]
    private var selectedIndex: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        if let layout = colorAssets.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 44, height: 44)
        }
        colorAssets.dataSource = self
        colorAssets.delegate = self
        colorAssets.allowsMultipleSelection = false
        colorAssets.showsHorizontalScrollIndicator = false
        colorAssets.backgroundColor = ColorConstants.filterBackColor
        colorAssets.register(nibCell: ColorCell.self)
    }
    
    override func setup(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) {
        super.setup(parameters: parameters, delegate: delegate)
        
        backgroundColor = ColorConstants.filterBackColor
        
        parameters.enumerated().forEach {
            let view = FilterSliderView.with(parameter: $0.element, delegate: self)
            contentView.insertArrangedSubview(view, at: $0.offset)
        }
    }
}

extension HLSFilterView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: ColorCell.self, for: indexPath)
        cell.setup(color: colors[indexPath.row], isSelected: selectedIndex == indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != selectedIndex else {
            return
        }
        
        if let selectedIndex = selectedIndex {
            (collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ColorCell)?.setSelected(false)
        }

        selectedIndex = indexPath.row
        (collectionView.cellForItem(at: indexPath) as? ColorCell)?.setSelected(true)
    }
}
