import UIKit

final class PaymentTypeView: UIView, NibInit {
    
    var paymentMethod: PaymentMethod? {
        didSet {
            guard let paymentMethod = paymentMethod else {
                assertionFailure()
                return
            }
            titleLabel.text = paymentMethod.type.title
            subtitleLabel.text = paymentMethod.priceLabel
            iconImageView.image = paymentMethod.type.image
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.photoCell
        }
    }
    @IBOutlet private weak var iconImageView: UIImageView! {
        willSet {
            newValue.contentMode = .center
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor.lrTealish
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightText
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
        }
    }
    @IBOutlet private weak var actionButton: BlueButtonWithMediumWhiteText! {
        willSet {
            /// Custom type in IB
            newValue.isExclusiveTouch = true
            newValue.setTitle(TextConstants.purchase, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBAction private func onActionButton() {
        
        if let name = paymentMethod?.name, let paymentType = paymentMethod?.type {
            paymentMethod?.action(name)
        }
    }
}
