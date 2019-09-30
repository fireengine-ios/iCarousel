//
//  FAQBannerView.swift
//  Depo
//
//  Created by Darya Kuliashova on 9/20/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum SupportBannerViewType {
    case support
    case faq
    
    var text: String {
        switch self {
        case .support:
            return TextConstants.signupSupportInfo
        case .faq:
            return TextConstants.signupFAQInfo
        }
    }
    
    var gradientColors: [CGColor] {
        switch self {
        case .support:
            return [ColorConstants.alertBlueGradientStart.cgColor,
                    ColorConstants.alertBlueGradientEnd.cgColor]
        case .faq:
            return [ColorConstants.alertOrangeAndBlueGradientStart.cgColor,
                    ColorConstants.alertOrangeAndBlueGradientEnd.cgColor]
        }
    }
}

protocol SupportFormBannerViewDelegate: class {
    func supportFormBannerViewDidClick(_ bannerView: SupportFormBannerView)
    func supportFormBannerView(_ bannerView: SupportFormBannerView, didSelect type: SupportFormSubjectTypeProtocol)
    func supportFormBannerViewDidCancel(_ bannerView: SupportFormBannerView)
}

final class SupportFormBannerView: UIView, NibInit {
    @IBOutlet private weak var messageLabel: UILabel!

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    weak var delegate: SupportFormBannerViewDelegate?
    
    var screenType: SupportFormScreenType!
    
    var type: SupportBannerViewType? {
        didSet {
            setupGradient()
            messageLabel.text = type?.text
        }
    }
    
    var shouldShowPicker = false
    
    private lazy var subjectPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.backgroundColor = ColorConstants.subjectPickerBackgroundColor
        return picker
    }()
    
    private lazy var toolBarPicker: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.tintColor = ColorConstants.toolBarTintColor
        toolBar.sizeToFit()
        toolBar.layer.zPosition = 1.0

        let doneButton = UIBarButtonItem(title: TextConstants.apply,
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleApplyButtonClick))
        doneButton.tintColor = ColorConstants.buttonTintColor
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: nil)
        
        let cancelButton = UIBarButtonItem(title: TextConstants.cancel,
                                           style: .plain,
                                           target: self,
                                           action: #selector(handleCancelButtonClick))
        cancelButton.tintColor = ColorConstants.buttonTintColor

        toolBar.items = [cancelButton, spaceButton, doneButton]
        
        return toolBar
    }()
    
    override var canBecomeFirstResponder: Bool {
        return shouldShowPicker
    }
    
    override var inputView: UIView? {
        return subjectPicker
    }
    
    override var inputAccessoryView: UIView? {
        return toolBarPicker
    }
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
        
        layer.cornerRadius = 4
    }

    private func setupGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            assertionFailure()
            return
        }

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = type?.gradientColors
    }
    
    // MARK: - Actions
    
    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        delegate?.supportFormBannerViewDidClick(self)
    }
    
    @objc private func handleApplyButtonClick() {
        let index = subjectPicker.selectedRow(inComponent: 0)
        let subject = screenType.subjects[index]
        delegate?.supportFormBannerView(self, didSelect: subject)
    }
    
    @objc private func handleCancelButtonClick() {
        delegate?.supportFormBannerViewDidCancel(self)
    }
}

extension SupportFormBannerView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return screenType.subjects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel: UILabel
        
        if let label = view as? UILabel {
            pickerLabel = label
        } else {
            pickerLabel = UILabel()
            pickerLabel.adjustsFontSizeToFitWidth = true
            pickerLabel.textAlignment = .center
        }
        
        let localizedText = screenType.subjects[row].localizedSubject
        pickerLabel.text = " \(localizedText) "

        return pickerLabel
    }
}
