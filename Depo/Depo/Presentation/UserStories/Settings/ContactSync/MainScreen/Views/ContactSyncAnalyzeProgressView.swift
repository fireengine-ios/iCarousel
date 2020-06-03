//
//  ContactSyncAnalyzeProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 03.06.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactSyncAnalyzeProgressViewDelegate: class {
    func cancelAnalyze()
}


final class ContactSyncAnalyzeProgressView: UIView, NibInit {
    
    weak var delegate: ContactSyncAnalyzeProgressViewDelegate?
    
    
    @IBOutlet private weak var percentage: UILabel! {
        willSet {
            newValue.attributedText = attributedPercentageString(value: 0)
        }
    }
    
    @IBOutlet private weak var message: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncAnalyzeProgressMessage
            newValue.font = .TurkcellSaturaFont(size: 16.0)
            newValue.textColor = ColorConstants.navy
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var progressLine: LineProgressView! {
        willSet {
            newValue.resetProgress()
            newValue.set(lineBackgroundColor: ColorConstants.lighterGray)
            newValue.set(lineColor: ColorConstants.navy)
        }
    }
    
    
    @IBOutlet private weak var cancelAnalyzeButton: RoundedInsetsButton! {
        willSet {
            newValue.insets = UIEdgeInsets(topBottom: 2.0, rightLeft: 48.0)
            newValue.backgroundColor = ColorConstants.whiteColor
            newValue.setTitleColor(ColorConstants.navy, for: .normal)
            newValue.layer.borderColor = ColorConstants.navy.cgColor
            newValue.layer.borderWidth = 1.0
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.setTitle(TextConstants.contactSyncCancelAnalyzeButton, for: .normal)
        }
    }
    
    private let attributedPercentageValue: NSMutableAttributedString = {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.TurkcellSaturaMedFont(size: 48.0),
            .foregroundColor: ColorConstants.navy]
        
        let attributed = NSMutableAttributedString(string: "0", attributes: attributes)
        
        return attributed
    }()
    
    private let attributedPercentageSign: NSAttributedString = {
        let bigFont = UIFont.TurkcellSaturaMedFont(size: 48.0)
        let smallFont = UIFont.TurkcellSaturaMedFont(size: 20.0)
        
        /// percent sign is aligned to top
        let offset = bigFont.capHeight - smallFont.capHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: smallFont,
            .foregroundColor: ColorConstants.navy,
            .baselineOffset : offset]
        
        let attributed = NSMutableAttributedString(string: "%", attributes: attributes)
        
        return attributed
    }()
    
    
    //MARK: - Public
    
    func reset() {
        progressLine.resetProgress()
        set(percentageValue: 0)
    }
    
    func update(progress: Int) {
        progressLine.set(progress: progress)
        set(percentageValue: progress)
    }
    
    
    //MARK: - Private
    
    @IBAction private func didTouchCancelAnalyze(_ sender: Any) {
        delegate?.cancelAnalyze()
    }
    
    private func set(percentageValue: Int) {
        percentage.attributedText = attributedPercentageString(value: percentageValue)
    }
    
    private func attributedPercentageString(value: Int) -> NSMutableAttributedString {
        attributedPercentageValue.mutableString.setString("\(value)")
        let result = attributedPercentageValue
        result.append(attributedPercentageSign)
        return result
    }
}
