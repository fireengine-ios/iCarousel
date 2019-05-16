import UIKit

final class ProfileTextViewEnterView: UIView {
    
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
        newValue.numberOfLines = 0
        return newValue
    }()
    
    let textView: IntrinsicTextView = {
        let newValue = IntrinsicTextView()
        newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
        newValue.textColor = UIColor.black
        newValue.backgroundColor = .white
        newValue.isOpaque = true
        
        /// to remove insets
        /// https://stackoverflow.com/a/42333832/5893286
        newValue.textContainer.lineFragmentPadding = 0
        newValue.textContainerInset = .zero
        
        return newValue
    }()
    
    let stackView: UIStackView = {
        let newValue = UIStackView()
        newValue.spacing = NumericConstants.profileStackViewHiddenSubtitleSpacing
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
        /// setup placeholder
        textView.delegate = self
        setupTextPlaceholder()
        
        setupStackView()
        setupUnderline()
    }
    
    private func setupStackView() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let edgeInset: CGFloat = 0
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: edgeInset).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edgeInset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edgeInset).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        /// why it is not working instead of constraints???
        //stackView.frame = bounds
        //stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //stackView.translatesAutoresizingMaskIntoConstraints = true
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(textView)
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
    
    // MARK: placeholder
    
    private let placeHolderText = TextConstants.explainYourProblemShortly
    private let placeHolderColor = UIColor.lightGray
    private let textColor = UIColor.black
    
    /// https://stackoverflow.com/a/27652289/5893286
    private func setupTextPlaceholder() {
        textView.text = placeHolderText
        textView.textColor = placeHolderColor
    }
    
    var isTextEmpty: Bool {
        return textView.textColor == placeHolderColor || textView.text.isEmpty
    }
}

// MARK: - UITextViewDelegate
extension ProfileTextViewEnterView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeHolderColor {
            textView.text = ""
            textView.textColor = textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = placeHolderColor
        }
        hideSubtitleAnimated()
    }
}
