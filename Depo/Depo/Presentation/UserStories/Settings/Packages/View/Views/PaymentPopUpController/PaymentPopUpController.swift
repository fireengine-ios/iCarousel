import UIKit

//typealias PopUpButtonHandler = (_: PopUpController) -> Void

// TODO: static func
// TODO: button handlers

final class PaymentPopUpController: UIViewController {
    
    static func controllerWith() -> PaymentPopUpController {
        let vc = PaymentPopUpController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var darkView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    @IBOutlet private weak var shadowView: UIView! {
        willSet {
            newValue.layer.cornerRadius = cornerRadius
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 10
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var containerView: UIStackView! {
        willSet {
            guard let paymentModel = paymentModel else {
                assertionFailure()
                return
            }
            
            paymentModel.types.forEach { paymentMethod in
                let paymentTypeView = PaymentTypeView.initFromNib()
                paymentTypeView.paymentMethod = paymentMethod
                newValue.addArrangedSubview(paymentTypeView)
            }
            
            newValue.addSubviewWith(backgroundColor: ColorConstants.whiteColor,
                                    cornerRadius: cornerRadius)
            
            /// to see background view with cornerRadius
            newValue.arrangedSubviews.forEach { $0.backgroundColor = .clear }
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkBlueColor
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 48)
            newValue.text = paymentModel?.priceLabel
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightText
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 16)
            newValue.text = paymentModel?.name
        }
    }
    
    // MARK: - Properties
    
    
    var paymentModel: PaymentModel?
    
    private let cornerRadius: CGFloat = 8
    private var isShown = false
    
    lazy var firstAction: PopUpButtonHandler = { vc in
        vc.close()
    }
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Animation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        open()
    }
    
    private func open() {
        if isShown {
            return
        }
        isShown = true
        shadowView.transform = NumericConstants.scaleTransform
        containerView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.shadowView.transform = .identity
            self.containerView.transform = .identity
        }
    }
    
    func close(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.shadowView.transform = NumericConstants.scaleTransform
            self.containerView.transform = NumericConstants.scaleTransform
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction private func onCloseButton() {
        close()
    }
}

extension UIStackView {
    
    /// https://stackoverflow.com/a/33929062/5893286
    func addSubviewWith(backgroundColor: UIColor, cornerRadius: CGFloat) {
        let backgroundView = UIView(frame: bounds)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.backgroundColor = backgroundColor
        insertSubview(backgroundView, at: 0)
        
        backgroundView.layer.cornerRadius = cornerRadius
        backgroundView.layer.masksToBounds = true
    }
}
