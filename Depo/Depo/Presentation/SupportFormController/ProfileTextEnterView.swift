import UIKit

class ProfileTextEnterView: UIView {
    
    let titleLabel: UILabel = {
        let newValue = UILabel()
        newValue.textColor = AppColor.label.color
        newValue.backgroundColor = AppColor.primaryBackground.color
        newValue.font = .appFont(.light, size: 14.0)
        newValue.isOpaque = true
        newValue.numberOfLines = 0
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
        let titleView = UIView()
        titleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 0),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        titleView.addSubview(infoButton)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setBackgroundColor(AppColor.primaryBackground.color, for: .normal)
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: titleView.topAnchor , constant: 5),
            infoButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor , constant: -5),
            infoButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0),
            infoButton.trailingAnchor.constraint(lessThanOrEqualTo: titleView.trailingAnchor)
        ])
        
        return titleView
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



class BorderedTextEnterView: UIView {
    
    let holderView : UIView = {
        let newValue = UIView()
        return newValue
    }()
    
    let backView : UIView = {
        let newValue = UIView()
        newValue.layer.borderColor = AppColor.borderColor.cgColor
        newValue.layer.borderWidth = 1.0
        newValue.layer.cornerRadius = 8
        return newValue
    }()
    
    let titleLabel: UILabel = {
        let newValue = UILabel()
        newValue.textColor = AppColor.label.color
        newValue.backgroundColor = AppColor.primaryBackground.color
        newValue.font = .appFont(.light, size: 14.0)
        newValue.isOpaque = true
        newValue.numberOfLines = 0
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
        newValue.textColor = AppColor.borderColor.color
        newValue.font = .appFont(.regular, size: 14.0)
        newValue.isOpaque = true
        newValue.isHidden = true
        newValue.numberOfLines = 0
        return newValue
    }()
    
    let textField: QuickDismissPlaceholderTextField = {
        let newValue = QuickDismissPlaceholderTextField()
        newValue.textColor = AppColor.borderColor.color
        newValue.font = .appFont(.regular, size: 14.0)
        newValue.borderStyle = .none
        newValue.isOpaque = true
        newValue.returnKeyType = .next
        newValue.underlineColor = .clear
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
    
    let titleView : UIView = {
        let newValue = UIView()
        newValue.backgroundColor = .clear
        return newValue
    }()
    
    var underlineColor = AppColor.borderColor.color {
        didSet {
            underlineLayer.backgroundColor = underlineColor.cgColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        underlineLayer.backgroundColor = underlineColor.cgColor
    }
    
    private let underlineWidth: CGFloat = 1.0
    private let underlineLayer = CALayer()
    
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
        setupViews()
        setupUnderline()
    }
    
    func setupViews() {
        addSubview(backView)
        
        backView.addSubview(stackView)
        backView.addSubview(createTitleView())

        stackView.translatesAutoresizingMaskIntoConstraints = false
        let edgeInset: CGFloat = 9
        stackView.topAnchor.constraint(equalTo: titleView.topAnchor, constant: -edgeInset).isActive = true
        stackView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: edgeInset).isActive = true

        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(subtitleLabel)

    }

    private func createTitleView() -> UIView {

        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: backView.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 25)
        ])

        titleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleView.centerYAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 0),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])

        titleView.addSubview(infoButton)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setBackgroundColor(AppColor.primaryBackground.color, for: .normal)
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: titleView.topAnchor , constant: 5),
            infoButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor , constant: -5),
            infoButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0),
            infoButton.trailingAnchor.constraint(lessThanOrEqualTo: titleView.trailingAnchor)
        ])

        return titleView
    }
    
    private func setupUnderline() {
        layer.insertSublayer(underlineLayer, at: 0)
        underlineLayer.backgroundColor = underlineColor.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        underlineLayer.frame = CGRect(x: 0,
                                      y: frame.size.height - 37,
                                      width: frame.width,
                                      height: 56);
        
        underlineLayer.cornerRadius = 8
        underlineLayer.borderWidth = 1.0
        underlineLayer.backgroundColor = AppColor.primaryBackground.cgColor
        underlineLayer.borderColor = AppColor.borderColor.cgColor
        
        self.bringSubviewToFront(titleLabel)
        
        
    }
    
    func showSubtitleAnimated() {
        guard subtitleLabel.isHidden else {
            return
        }
        stackView.spacing = NumericConstants.profileStackViewShowSubtitleSpacing
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.subtitleLabel.isHidden = false
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func hideSubtitleAnimated() {
        guard !subtitleLabel.isHidden else {
            return
        }
        stackView.spacing = NumericConstants.profileStackViewHiddenSubtitleSpacing
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.subtitleLabel.isHidden = true
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func showSubtitleTextAnimated(text: String) {
        subtitleLabel.text = text
        showSubtitleAnimated()
    }
}
