import UIKit

struct PaymentModel {
    let name: String
    let priceLabel: String
    let types: [PaymentMethod]
}

struct PaymentMethod {
    let name: String
    let priceLabel: String
    let type: PaymentType
}

enum PaymentType {
    case appStore
    case paycell
    case slcm
    
    var image: UIImage? {
        let imageName: String
        switch self {
        case .appStore:
            imageName = "payment_app_store"
        case .paycell:
            imageName = "payment_paycell"
        case .slcm:
            imageName = "payment_slcm"
        }
        return UIImage(named: imageName)
    }
}

final class PaymentTypeView: UIView, NibInit {
    
    var paymentMethod: PaymentMethod? {
        didSet {
            guard let paymentMethod = paymentMethod else {
                assertionFailure()
                return
            }
            titleLabel.text = paymentMethod.name
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
            //newValue.insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
            
//            newValue.setTitleColor(UIColor.white, for: .normal)
//            newValue.setTitleColor(UIColor.white.darker(by: 30), for: .highlighted)
//            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
//            newValue.setBackgroundColor(UIColor.lrTealish.darker(by: 30), for: .highlighted)
            
//            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBAction private func onActionButton() {
        
    }
}
