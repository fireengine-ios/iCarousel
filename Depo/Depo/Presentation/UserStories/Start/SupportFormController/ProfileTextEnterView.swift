import UIKit

final class ProfileTextEnterView: UIView {
    
    let titleLabel: UILabel = {
        let newValue = UILabel()
        newValue.textColor = UIColor.lrTealish
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        newValue.backgroundColor = .white
        newValue.isOpaque = true
        return newValue
    }()
    
    let subtitleLabel: UILabel = {
        let newValue = UILabel()
        newValue.textColor = ColorConstants.textOrange
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
        newValue.backgroundColor = .white
        newValue.isOpaque = true
        newValue.isHidden = true
        return newValue
    }()
    
    let textField: UITextField = {
        let newValue = UITextField()
        newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
        newValue.textColor = UIColor.black
        newValue.borderStyle = .none
        newValue.backgroundColor = .white
        newValue.isOpaque = true
        return newValue
    }()
    
    let stackView: UIStackView = {
        let newValue = UIStackView()
        newValue.spacing = 8
        newValue.axis = .vertical
        newValue.alignment = .fill
        newValue.distribution = .fill
        newValue.backgroundColor = .white
        newValue.isOpaque = true
        return newValue
    }()
    
    var underlineColor = ColorConstants.lightGrayColor {
        didSet {
            underlineLayer.backgroundColor = underlineColor.cgColor
        }
    }
    
    private let underlineWidth: CGFloat = 0.5
    private let underlineLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        setupStackView()
        setupUnderline()
        
        //        textField.translatesAutoresizingMaskIntoConstraints = false
        //        textField.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
    
    private func setupStackView() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let edgeInset: CGFloat = 0
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: edgeInset).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edgeInset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edgeInset).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(textField)
    }
    
    private func setupUnderline() {
        layer.addSublayer(underlineLayer)
        underlineLayer.backgroundColor = underlineColor.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        underlineLayer.frame = CGRect(x: 0,
                                      y: frame.size.height - underlineWidth,
                                      width: frame.width,
                                      height: underlineWidth);
    }
    
    func showUnderlineAnimated() {
        guard subtitleLabel.isHidden else {
            return
        }
        stackView.spacing = 2
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.subtitleLabel.isHidden = false
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func hideUnderlineAnimated() {
        guard !subtitleLabel.isHidden else {
            return
        }
        stackView.spacing = 8
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.subtitleLabel.isHidden = true
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
}
