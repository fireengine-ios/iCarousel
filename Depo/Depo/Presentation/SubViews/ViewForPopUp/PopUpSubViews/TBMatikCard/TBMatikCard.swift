import UIKit

final class TBMatikCard: BaseView {
    
    @IBOutlet private weak var imagesStackViewHeightСonstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imagesStackView: UIStackView! {
        willSet {
            newValue.spacing = 10
            newValue.alignment = .bottom
            newValue.axis = .horizontal
            newValue.distribution = .fill
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = ColorConstants.whiteColor
            newValue.numberOfLines = 0
            newValue.text = "Your today’s TB"
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 14)
            newValue.textColor = ColorConstants.whiteColor
            newValue.numberOfLines = 0
            newValue.text = "Lorem ipsum dolor sit amet.Lorem ipsum dolor!"
        }
    }
    
    @IBOutlet private weak var dateLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 12)
            newValue.numberOfLines = 0
            newValue.textColor = ColorConstants.whiteColor
            newValue.text = "12 NOVEMBER 2018"
        }
    }
    
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.setTitleColor(ColorConstants.blueColor, for: .normal)
            newValue.setTitle("Let's see", for: .normal)
        }
    }
    
    private let imageDownloder = ImageDownloder()
    
    /// "func set(object:" called twice.
    /// you can find comment 'seems like duplicated logic "set(object:".' in the project.
    /// if you cannot find it then drop logic for this variable.
    private var isCardSetuped = false
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        if isCardSetuped {
            return
        }
        
        isCardSetuped = true
        
        guard let jsonArray = object?.details?.array else {
            assertionFailure()
            return
        }
        
        let urls = jsonArray
            .cutFirstItems(itemsNumber: 3)
            .compactMap { json in
                json["metadata"]["Thumbnail-Large"].url
        }
        
        guard urls.hasItems else {
            return
        }
        
        var images = [UIImage]()
        let group = DispatchGroup()
        
        urls.forEach { url in
            group.enter()
            imageDownloder.getImage(patch: url) { image in
                guard let image = image else {
                    return
                }
                images.append(image)
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else {
                return
            }
            
            images
                .compactMap { self.createImageView(with: $0) }
                .forEach { self.imagesStackView.addArrangedSubview($0) }
        }
    }
    
    private lazy var imageHeight: CGFloat = imagesStackViewHeightСonstraint.constant
    
    private func createImageView(with image: UIImage) -> UIImageView {
        let width = image.size.width
        let height = image.size.height
//        let scaleFactor = (width > height) ? (width / height) : (height / width)
//        let scaleFactor = (width > height) ? (height / width) : (width / height)
        let scaleFactor = width / height
        let imageViewWidth = imageHeight * scaleFactor
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: imageViewWidth).activate()
        imageView.heightAnchor.constraint(equalToConstant: imageHeight).activate()
        imageHeight -= 10
        
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 2
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        return imageView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = actionButton.frame.origin.y + actionButton.frame.size.height
        if calculatedH != height {
            calculatedH = height
            layoutIfNeeded()
        }
    }
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        print("qqqq")
    }
    
    @IBAction private func onCloseButton(_ sender: UIButton) {
//        deleteCard()
    }
}

extension Array {
    func cutFirstItems(itemsNumber: Int) -> Self {
        return (self.count > itemsNumber) ? Array(self[0..<itemsNumber]) : self
    }
}
