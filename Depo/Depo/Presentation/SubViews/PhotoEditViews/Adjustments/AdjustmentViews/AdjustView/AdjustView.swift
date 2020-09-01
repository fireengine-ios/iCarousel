//
//  AdjustView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import Mantis

protocol AdjustViewDelegate: class {
    func didShowRatioMenu(_ view: AdjustView, selectedRatio: AdjustRatio)
    func didChangeAngle(_ value: Float)
}

struct AdjustRatio {
    let name: String
    let value: Double?
    
    static func allValues(originalRatio: Double) -> [AdjustRatio] {
        return [AdjustRatio(name: TextConstants.photoEditRatioFree, value: nil),
                AdjustRatio(name: TextConstants.photoEditRatioOriginal, value: originalRatio),
                AdjustRatio(name: "1 x 1", value: 1),
                AdjustRatio(name: "16 x 9", value: 16/9),
                AdjustRatio(name: "4 x 3", value: 4/3),
                AdjustRatio(name: "7 x 5", value: 7/5),
                AdjustRatio(name: "3 x 2", value: 3/2)]
    }
}

final class AdjustView: UIView, NibInit, CropToolbarProtocol {
    
    static func with(ratios: [AdjustRatio], delegate: AdjustViewDelegate?) -> AdjustView {
        let view = AdjustView.initFromNib()
        view.delegate = delegate
        view.ratios = ratios
        if let ratio = view.ratios.first(where: { $0.name == TextConstants.photoEditRatioOriginal }) {
            view.selectedRatio = ratio
        }
        return view
    }
    
    private let minValue: Float = -45
    private let maxValue: Float = 45
    private var currentValue: Float = 0
    private let defaultValue: Float = 0
    
    @IBOutlet private weak var sliderContentView: UIView!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    @IBOutlet private weak var minValueLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaMedFont(size: 12)
        }
    }
    
    @IBOutlet private weak var maxValueLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaMedFont(size: 12)
        }
    }
    
    @IBOutlet private weak var currentValueLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaMedFont(size: 12)
        }
    }
    
    private let slider = SliderView()
    
    private weak var delegate: AdjustViewDelegate?
    
    private var ratios = [AdjustRatio]()
    private var selectedRatio = AdjustRatio(name: "", value: nil)
    
    //MARK: - Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorConstants.photoEditBackgroundColor
        sliderContentView.backgroundColor = ColorConstants.photoEditBackgroundColor
        
        setup()
    }
    
    //MARK: - Setup
    
    private func setup() {
        minValueLabel.text = "\(Int(minValue))"
        maxValueLabel.text = "\(Int(maxValue))"
        currentValueLabel.text = "\(Int(currentValue))"

        slider.add(to: sliderContentView)
        
        slider.setup(minValue: minValue,
                     maxValue: maxValue,
                     anchorValue: defaultValue,
                     currentValue: currentValue)
        
        slider.changeValueHandler = { [weak self] value in
            self?.currentValue = value
            self?.currentValueLabel.text = "\(Int(value))"
            self?.delegate?.didChangeAngle(value)
        }
    }
    
    func updateRatio(_ value: AdjustRatio) {
        selectedRatio = value
    }
    
    //MARK: - Actions
    
    @IBAction private func onLeftButtonTapped(_ sender: UIButton) {
        delegate?.didShowRatioMenu(self, selectedRatio: selectedRatio)
    }
    
    @IBAction private func onRightButtonTapped(_ sender: UIButton) {
        cropToolbarDelegate?.didSelectCounterClockwiseRotate()
    }
    
    //MARK: - CropToolbarProtocol
    
    var heightForVerticalOrientationConstraint: NSLayoutConstraint?
    var widthForHorizonOrientationConstraint: NSLayoutConstraint?
    var cropToolbarDelegate: CropToolbarDelegate?
    func createToolbarUI(config: CropToolbarConfig) {}
    func handleFixedRatioSetted() {}
    func handleFixedRatioUnSetted() { }
    func initConstraints(heightForVerticalOrientation: CGFloat, widthForHorizonOrientation: CGFloat) { }
}
