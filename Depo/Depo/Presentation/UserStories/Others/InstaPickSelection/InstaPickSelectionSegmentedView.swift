import UIKit

// TODO: accessibility
/// https://habr.com/ru/post/432718/
final class InstaPickSelectionSegmentedView: UIView {
    
    private let topView = UIView()
    let containerView = UIView()
    private let transparentGradientView = TransparentGradientView(style: .vertical, mainColor: .white)
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.tintColor = ColorConstants.darkBlueColor
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 14)], for: .normal)
        return segmentedControl
    }()
    
    let analyzeButton: RoundedInsetsButton = {
        let button = RoundedInsetsButton()
        button.isExclusiveTouch = true
        button.setTitle(TextConstants.analyzeWithInstapick, for: .normal)
        button.insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white.darker(by: 30), for: .highlighted)
        button.setBackgroundColor(ColorConstants.darkBlueColor, for: .normal)
        button.setBackgroundColor(ColorConstants.darkBlueColor.darker(by: 30), for: .highlighted)
        
        button.titleLabel?.font = ApplicationPalette.bigRoundButtonFont
        button.adjustsFontSizeToFitWidth()
        button.isHidden = true
        return button
    }()
    
    let analyzesLeftLabel: InsetsLabel = {
        let label = InsetsLabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = ColorConstants.darkBlueColor
        label.font = UIFont.TurkcellSaturaBolFont(size: 16)
        label.backgroundColor = ColorConstants.fileGreedCellColor.withAlphaComponent(0.9)
        let edgeInset: CGFloat = Device.isIpad ? 90 : 15
        label.insets = UIEdgeInsets(top: 5, left: edgeInset, bottom: 5, right: edgeInset)
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    private let buttonText: String
    private let maxReachedText: String
    private let needShowSegmentedControll: Bool

    init(buttonText: String, maxReachedText: String, needShowSegmentedControll: Bool) {
        self.buttonText = buttonText
        self.maxReachedText = maxReachedText
        self.needShowSegmentedControll = needShowSegmentedControll
        
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        assertionFailure()

        self.buttonText = ""
        self.maxReachedText = ""
        self.needShowSegmentedControll = false
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        topView.backgroundColor = .white
        containerView.backgroundColor = .white
        setupLayout()
        
        analyzeButton.setTitle(buttonText, for: .normal)
        analyzesLeftLabel.text = maxReachedText
    }
    
    private func setupLayout() {
        let view = self
        view.addSubview(topView)
        topView.addSubview(segmentedControl)
        view.addSubview(containerView)
        view.addSubview(transparentGradientView)
        view.addSubview(analyzeButton)
        view.addSubview(analyzesLeftLabel)
        
        let edgeOffset: CGFloat = Device.isIpad ? 75 : 35
        let transparentGradientViewHeight = NumericConstants.instaPickSelectionSegmentedTransparentGradientViewHeight
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        topView.heightAnchor.constraint(equalToConstant: 50).activate()
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.leadingAnchor
            .constraint(equalTo: topView.leadingAnchor, constant: edgeOffset).activate()
        segmentedControl.trailingAnchor
            .constraint(equalTo: topView.trailingAnchor, constant: -edgeOffset).activate()
        segmentedControl.centerYAnchor.constraint(equalTo: topView.centerYAnchor).activate()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let topAnchor = needShowSegmentedControll ? topView.bottomAnchor : view.topAnchor
        containerView.topAnchor.constraint(equalTo: topAnchor).activate()
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        
        transparentGradientView.translatesAutoresizingMaskIntoConstraints = false
        transparentGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        transparentGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        transparentGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        transparentGradientView.heightAnchor.constraint(equalToConstant: transparentGradientViewHeight).activate()
        
        analyzeButton.translatesAutoresizingMaskIntoConstraints = false
        
        analyzeButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 10).activate()
        analyzeButton.centerYAnchor.constraint(equalTo: transparentGradientView.centerYAnchor).activate()
        analyzeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        analyzeButton.heightAnchor.constraint(equalToConstant: 54).activate()
        analyzeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 206).activate()

        analyzesLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        analyzesLeftLabel.bottomAnchor.constraint(equalTo: transparentGradientView.topAnchor,
                                                  constant: Device.isIpad ? -20 : 0).activate()
        if Device.isIpad {
            analyzesLeftLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        } else {
            analyzesLeftLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 14).activate()
            analyzesLeftLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -14).activate()
        }
    }
}
