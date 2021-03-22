//
//  TextFieldWithPickerView.swift
//  Depo
//
//  Created by Vyacheslav Bakinskiy on 19.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class TextFieldWithPickerView: UIView {
    
    //MARK: - Public properties
    
    private let pickerView = UIPickerView()
    private var didSelect: ((_ index: Int, _ model: String) -> Void)?
    
    //MARK: - Public properties
    
    var responderOnNext: UIResponder?
    
    var models = [String]() {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    var textField: QuickDismissPlaceholderTextField = {
        let textField = QuickDismissPlaceholderTextField()
        textField.borderStyle = .none
        textField.font = UIFont.GTAmericaStandardRegularFont(size: 12)
        textField.textColor = ColorConstants.Text.textFieldText
        textField.attributedPlaceholder = NSAttributedString(
            string: TextConstants.contactUsSubjectBoxName,
            attributes: [NSAttributedString.Key.foregroundColor: ColorConstants.Text.textFieldPlaceholder]
        )
        return textField
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTextField()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTextField()
        setup()
    }
    
    //MARK: - Private funcs
    
    private func addTextField() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.pinToSuperviewEdges()
    }
    
    private func setup() {
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        
        let image = UIImage(named: "downArrow")
        let imageView = UIImageView(image: image)
        textField.rightView = imageView
        textField.rightViewMode = .always
        
        textField.tintColor = ColorConstants.Text.labelTitle
        
        textField.inputView = pickerView
        textField.addToolBarWithButton(title: TextConstants.userProfileDoneButton,
                                       target: self,
                                       selector: #selector(doneButtonPressed),
                                       font: UIFont.GTAmericaStandardMediumFont(size: 15),
                                       tintColor: ColorConstants.buttonTintBlue)
        
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
    }
    
    //MARK: - Actions
    
    @objc private func doneButtonPressed() {
        responderOnNext?.becomeFirstResponder()
    }
    
    @objc private func textFieldDidBeginEditing() {
        if textField.text == "" {
            textField.text = models.first
        }
    }
}

//MARK: - UIPickerViewDataSource

extension TextFieldWithPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return models.count
    }
}

//MARK: - UIPickerViewDelegate

extension TextFieldWithPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return models[row]
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
        
        pickerLabel.text = " \(models[row]) "
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = models[row]
        didSelect?(row, models[row])
    }
}
