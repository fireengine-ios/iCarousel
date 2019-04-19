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
            
            let fullnameStackView = UIStackView(arrangedSubviews: [nameTextField, surnameTextField])
            fullnameStackView.spacing = 20
            fullnameStackView.axis = .horizontal
            fullnameStackView.alignment = .fill
            fullnameStackView.distribution = .fillEqually
            fullnameStackView.backgroundColor = .white
            fullnameStackView.isOpaque = true
            
            newValue.addArrangedSubview(fullnameStackView)
            newValue.addArrangedSubview(emailTextField)
            newValue.addArrangedSubview(profilePhoneEnterView)
        }
    }
    
    let nameTextField: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = "Name"
        newValue.subtitleLabel.text = "Please enter your name"
        newValue.textField.placeholder = "Enter your name"
        return newValue
    }()
    
    let surnameTextField: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = "Surname"
        newValue.subtitleLabel.text = "Please enter your surname"
        newValue.textField.placeholder = "Enter your surname"
        return newValue
    }()
    
    let emailTextField: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = "Email"
        newValue.subtitleLabel.text = "Please enter your e-mail"
        newValue.textField.placeholder = "Enter your e-mail adress"
        return newValue
    }()
    
    let profilePhoneEnterView: ProfilePhoneEnterView = {
        let newValue = ProfilePhoneEnterView()
        return newValue
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
