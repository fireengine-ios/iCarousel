import UIKit

class ProfileTextEnterView: UIView {
    
    let titleLabel: UILabel = {
        let newValue = UILabel()
        newValue.textColor = AppColor.label.color
        newValue.backgroundColor = AppColor.primaryBackground.color
        newValue.font = .appFont(.light, size: 14.0)
        newValue.isOpaque = true
        newValue.numberOfLines = 0
        newValue.setContentCompressionResistancePriority(.required, for: .horizontal)
        newValue.sizeToFit()
        return newValue
    }()
    
    let infoButton: UIButton = {
        let newValue = UIButton(type: .custom)
        let infoIcon = UIImage(named: "action_info")?.withRenderingMode(.alwaysTemplate)
        newValue.setImage(infoIcon, for: .normal)
        newValue.tintColor = AppColor.profileInfoOrange.color
        newValue.isHidden = true
        return newValue
    }()
    
    let subtitleLabel: UILabel = {
        let newValue = UILabel()
        newValue.textColor = AppColor.profileInfoOrange.color
        newValue.font = .appFont(.regular, size: 14.0)
        newValue.isOpaque = true
        newValue.numberOfLines = 0
        return newValue
    }()
    
    lazy var textField: QuickDismissPlaceholderTextField = {
        let newValue = QuickDismissPlaceholderTextField()
        newValue.textColor = AppColor.borderColor.color
        newValue.font = .appFont(.regular, size: 14.0)
        newValue.backgroundColor = AppColor.primaryBackground.color
        newValue.borderStyle = .none
        newValue.layer.cornerRadius = 8
        newValue.layer.borderWidth = 1
        newValue.layer.borderColor = AppColor.borderColor.cgColor
        newValue.setLeftPaddingPoints(10)
        newValue.setRightPaddingPoints(10)
        newValue.isOpaque = true
        newValue.returnKeyType = .next
        return newValue
    }()
    
    let stackView: UIStackView = {
        let newValue = UIStackView()
        newValue.spacing = 0
        newValue.axis = .vertical
        newValue.alignment = .fill
        newValue.distribution = .fill
        newValue.isOpaque = true
        return newValue
    }()
    
    lazy var subtitleContent: UIView = {
        let newValue = UIView()
        newValue.isHidden = true
        newValue.backgroundColor = .clear
        newValue.layer.cornerRadius = 8
        newValue.layer.borderWidth = 1
        newValue.layer.borderColor = AppColor.profileInfoOrange.cgColor
        return newValue
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    var isEditState: Bool {
        get {
            return textField.isUserInteractionEnabled
        }
        set {
            textField.isUserInteractionEnabled = newValue
            textField.textColor = newValue ? AppColor.blackColor.color : ColorConstants.textDisabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    func initialSetup() {
        setupStackView()
    }
    
    func setupStackView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        setupTextField()
        setupSubtitleContent()
    }
    
    private func setupTextField() {
        stackView.addArrangedSubview(textField)
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        let titleView = createTitleView()
        stackView.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.centerYAnchor.constraint(equalTo: stackView.topAnchor, constant: 0).isActive = true
        titleView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 12).isActive = true
    }
    
    private func setupSubtitleContent() {
        stackView.addArrangedSubview(subtitleContent)
        subtitleContent.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: -10).isActive = true
        subtitleContent.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leadingAnchor.constraint(equalTo: subtitleContent.leadingAnchor, constant: 10).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: subtitleContent.trailingAnchor, constant: -10).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: subtitleContent.bottomAnchor, constant: -10).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: subtitleContent.topAnchor, constant: 20).isActive = true
        stackView.sendSubviewToBack(subtitleContent)
    }
    
    private func createTitleView() -> UIView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        view.alignment = .fill
        view.distribution = .fill
        
        view.backgroundColor = AppColor.background.color
        
        view.addArrangedSubview(UIView.getSpacing(width: 9, height: 24))
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(UIView.getSpacing(width: 4, height: 24))
        view.addArrangedSubview(infoButton)
        view.addArrangedSubview(UIView.getSpacing(width: 9, height: 24))
        
        infoButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        infoButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return view
    }
    
    func showSubtitleAnimated() {
        guard subtitleContent.isHidden else {
            return
        }
        stackView.spacing = NumericConstants.profileStackViewShowSubtitleSpacing
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.subtitleContent.isHidden = false
            self.subtitleContent.alpha = 1
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func hideSubtitleAnimated() {
        guard !subtitleContent.isHidden else {
            return
        }
        stackView.spacing = NumericConstants.profileStackViewHiddenSubtitleSpacing
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.subtitleContent.isHidden = true
            self.subtitleContent.alpha = 0.3
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func showSubtitleTextAnimated(text: String) {
        subtitleLabel.text = text
        showSubtitleAnimated()
    }
}
