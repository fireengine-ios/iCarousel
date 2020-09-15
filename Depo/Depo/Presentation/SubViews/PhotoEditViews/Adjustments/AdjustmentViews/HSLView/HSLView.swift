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
    
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingConstaint: NSLayoutConstraint!
    @IBOutlet private weak var trailingConstaint: NSLayoutConstraint!
    
    private var colors = [HSVMultibandColor]()
    private var colorParameter: HSLColorAdjustmentParameterProtocol?
    
    //MAKR: - Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        topConstraint.constant = Device.isIpad ? 30 : 16
        bottomConstraint.constant = Device.isIpad ? 40 : 16
        leadingConstaint.constant = Device.isIpad ? 72 : 16
        trailingConstaint.constant = Device.isIpad ? 72 : 16
        contentView.spacing = Device.isIpad ? 22 : 6
        
        setupCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        //width alignment
        if !colors.isEmpty, let layout = colorAssets.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = frame.width - leadingConstaint.constant - trailingConstaint.constant
            let spacing = (width - layout.itemSize.width * CGFloat(colors.count))/CGFloat(colors.count - 1)
            layout.minimumLineSpacing = spacing
        }
    }
    
    private func setupCollectionView() {
        if let layout = colorAssets.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: Device.isIpad ? 44 : 32, height: 44)
            layout.minimumLineSpacing = Device.isIpad ? 36 : 20
        }
        colorAssets.dataSource = self
        colorAssets.delegate = self
        colorAssets.allowsMultipleSelection = false
        colorAssets.showsHorizontalScrollIndicator = false
        colorAssets.backgroundColor = ColorConstants.photoEditBackgroundColor
        colorAssets.register(nibCell: ColorCell.self)
    }
    
    func setup(parameters: [AdjustmentParameterProtocol], colorParameter: HSLColorAdjustmentParameterProtocol, delegate: AdjustmentsViewDelegate?) {
        setup(parameters: parameters, delegate: delegate)
        
        backgroundColor = ColorConstants.photoEditBackgroundColor
        
        parameters.enumerated().forEach {
            let view = AdjustmentParameterSliderView.with(parameter: $0.element, delegate: self)
            if let colors = colorParameter.currentValue.sliderGradientColors(for: $0.element.type) {
                view.setupGradient(startColor: colors.startColor, endColor: colors.endColor)
            }
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
        let color = colors[indexPath.row]
        delegate?.didChangeHSLColor(color)
        
        contentView.arrangedSubviews.forEach { view in
            if let sliderView = view as? AdjustmentParameterSliderView,
                let type = sliderView.type,
                let colors = color.sliderGradientColors(for: type) {
                sliderView.resetToDefaultValue()
                sliderView.updateGradient(startColor: colors.startColor, endColor: colors.endColor)
            }
        }
    }
}
