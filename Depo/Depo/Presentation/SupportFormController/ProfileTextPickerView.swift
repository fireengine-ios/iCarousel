import UIKit

final class ProfileTextPickerView: ProfileTextEnterView {
    
    private let pickerView = UIPickerView()
    
    var didSelect: ((_ index: Int, _ model: String) -> Void)?
    
    var models = [String]() {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    var responderOnNext: UIResponder?
    
    /// returns selected row. -1 if nothing selected
    var selectedIndex: Int {
        return pickerView.selectedRow(inComponent: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        pickerView.delegate = self
        
        let image = UIImage(named: "ic_arrow_down")
        let imageView = UIImageView(image: image)
        textField.rightView = imageView
        textField.rightViewMode = .always
        
        /// to remove cursor bcz we have picker
        textField.tintColor = .clear
        
        textField.inputView = pickerView
        textField.addToolBarWithButton(title: TextConstants.nextTitle,
                                       target: self,
                                       selector: #selector(onNextToolBarButton))
        
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
    }
    
    @objc private func onNextToolBarButton() {
        responderOnNext?.becomeFirstResponder()
    }
    
    @objc private func textFieldDidBeginEditing() {
        /// select first model on begin editing
        if textField.text == "" {
            textField.text = models.first
        }
    }
}

extension ProfileTextPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return models.count
    }
}

extension ProfileTextPickerView: UIPickerViewDelegate {
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
        
        /// extra spaces for small screens, like 5s
        pickerLabel.text = " \(models[row]) "
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = models[row]
        didSelect?(row, models[row])
    }
}
