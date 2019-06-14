import UIKit

final class PhoneCodeInputView: UIPickerView {
    
    private let gsmModels: [GSMCodeModel] = CounrtiesGSMCodeCompositor().getGSMCCModels()
    
    var didSelect: ((GSMCodeModel) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        delegate = self
    }
}

extension PhoneCodeInputView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gsmModels.count
    }
}

extension PhoneCodeInputView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let model = gsmModels[row]
        return "\(model.countryName)    \(model.gsmCode)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelect?(gsmModels[row])
    }
}
