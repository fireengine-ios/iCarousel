//
//  HSLView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class HSLView: AdjustmentsView, NibInit {

    static func with(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) -> HSLView {
        let view = HSLView.initFromNib()
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
        colorAssets.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: 8)
    }
    
    override func setup(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) {
        super.setup(parameters: parameters, delegate: delegate)
        
        backgroundColor = ColorConstants.filterBackColor
        
        parameters.enumerated().forEach {
            let view = AdjustmentParameterSliderView.with(parameter: $0.element, delegate: self)
            contentView.insertArrangedSubview(view, at: $0.offset)
        }
    }
    
    override func sliderValueChanged(newValue: Float, type: AdjustmentParameterType) {
        guard let index = adjustments.firstIndex(where: { $0.type == type}) else {
            return
        }

        adjustments[index] = AdjustmentParameterValue(type: type, value: newValue)
        delegate?.didChangeAdjustments(adjustments)
    }
}

extension HSLView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: ColorCell.self, for: indexPath)
        cell.setup(color: colors[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
