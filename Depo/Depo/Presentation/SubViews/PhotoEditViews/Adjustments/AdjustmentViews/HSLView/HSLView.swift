//
//  HSLView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class HSLView: AdjustmentsView, NibInit {

    static func with(parameters: [AdjustmentParameterProtocol], colorParameter: HSLColorAdjustmentParameterProtocol, delegate: AdjustmentsViewDelegate?) -> HSLView {
        let view = HSLView.initFromNib()
        view.setup(parameters: parameters, colorParameter: colorParameter, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var colorAssets: UICollectionView!
    
    private var colors = [HSVMultibandColor]()
    private var colorParameter: HSLColorAdjustmentParameterProtocol?
    
    //MAKR: - Setup
    
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
        colorAssets.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: 8)
    }
    
    func setup(parameters: [AdjustmentParameterProtocol], colorParameter: HSLColorAdjustmentParameterProtocol, delegate: AdjustmentsViewDelegate?) {
        setup(parameters: parameters, delegate: delegate)
        
        backgroundColor = ColorConstants.filterBackColor
        
        parameters.enumerated().forEach {
            let view = AdjustmentParameterSliderView.with(parameter: $0.element, delegate: self)
            contentView.insertArrangedSubview(view, at: $0.offset)
        }
    
        self.colorParameter = colorParameter
        colors = colorParameter.possibleValues
        colorAssets.reloadData()
        
        guard let index = colors.firstIndex(where: { $0 == colorParameter.currentValue }) else {
            return
        }
        colorAssets.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .left)
    }
}

extension HSLView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: ColorCell.self, for: indexPath)
        let color = colors[indexPath.row]
        cell.setup(hsvColor: color)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorParameter?.set(value: colors[indexPath.row])
    }
}
