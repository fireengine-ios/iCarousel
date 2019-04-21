import UIKit

final class SupportFormController: UIViewController {

    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 11
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            
            let fullnameStackView = UIStackView(arrangedSubviews: [nameView, surnameView])
            fullnameStackView.spacing = 20
            fullnameStackView.axis = .horizontal
            fullnameStackView.alignment = .fill
            fullnameStackView.distribution = .fillEqually
            fullnameStackView.backgroundColor = .white
            fullnameStackView.isOpaque = true
            
            newValue.addArrangedSubview(fullnameStackView)
            newValue.addArrangedSubview(emailView)
            newValue.addArrangedSubview(phoneView)
            newValue.addArrangedSubview(subjectView)
            newValue.addArrangedSubview(problemView)
        }
    }
    
    @IBOutlet private weak var sendButton: RoundedInsetsButton! {
        willSet {
            /// Custom type in IB
            newValue.isExclusiveTouch = true
            newValue.setTitle(TextConstants.feedbackViewSendButton, for: .normal)
            newValue.insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
            
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setTitleColor(UIColor.white.darker(by: 30), for: .highlighted)
            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish.darker(by: 30), for: .highlighted)
            
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    let nameView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = "Name"
        newValue.subtitleLabel.text = "Please enter your name"
        newValue.textField.placeholder = "Enter your name"
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    let surnameView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = "Surname"
        newValue.subtitleLabel.text = "Please enter your surname"
        newValue.textField.placeholder = "Enter your surname"
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    let emailView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = "Email"
        newValue.subtitleLabel.text = "Please enter your e-mail"
        newValue.textField.placeholder = "Enter your e-mail adress"
        newValue.textField.keyboardType = .emailAddress
        return newValue
    }()
    
    let phoneView = ProfilePhoneEnterView()
    
    let subjectView: ProfileTextPickerView = {
        let newValue = ProfileTextPickerView()
        newValue.titleLabel.text = "Subject"
        newValue.subtitleLabel.text = "Please enter your subject"
        newValue.textField.placeholder = "Please choose a subject..."
        newValue.models = ["E-mail",
                           "Phone Number",
                           "Password",
                           "Security text",
                           "Turkcell Password",
                           "Automatic Log-in",
                           "Other"]
        return newValue
    }()
    
    let problemView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = "Your Problem"
        newValue.subtitleLabel.text = "Please enter your problem shortly"
        newValue.textField.placeholder = "Explain your problem shortly"
        return newValue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneView.responderOnNext = subjectView.textField
        subjectView.responderOnNext = nameView.textField
//        subjectView.textField.text
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.phoneView.showTextAnimated(text: "Please enter 10-digit mobile number 5xxxxxxxxx")
//        }
    }
    
    @IBAction private func onSendButton(_ sender: UIButton) {
        print("open email")
    }
}
