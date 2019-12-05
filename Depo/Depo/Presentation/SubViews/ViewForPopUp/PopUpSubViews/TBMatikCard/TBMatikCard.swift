import UIKit

final class TBMatikCard: BaseCardView {
    
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
            newValue.text = TextConstants.tbMatiHomeCardTitle
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 14)
            newValue.textColor = ColorConstants.whiteColor
            newValue.numberOfLines = 0
            newValue.text = TextConstants.tbMatiHomeCardSubtitle
        }
    }
    
    @IBOutlet private weak var dateLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 12)
            newValue.numberOfLines = 0
            newValue.textColor = ColorConstants.whiteColor
            newValue.text = " "
        }
    }
    
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.setTitleColor(ColorConstants.blueColor, for: .normal)
            newValue.setTitle(TextConstants.tbMatiHomeCardButtonTitle, for: .normal)
        }
    }
    
    private lazy var imageHeight: CGFloat = imagesStackView.bounds.height
    
    private let imageDownloder = ImageDownloder()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    /// "func set(object:" called twice.
    /// you can find comment 'seems like duplicated logic "set(object:".' in the project.
    /// if you cannot find it then drop logic for this variable.
    private var isCardSetuped = false
    
    private var items = [Item]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        analyticsService.logScreen(screen: .tbmatikHomePageCard)
        analyticsService.trackDimentionsEveryClickGA(screen: .tbmatikHomePageCard)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = actionButton.frame.origin.y + actionButton.frame.size.height
        if calculatedH != height {
            calculatedH = height
            layoutIfNeeded()
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        if isCardSetuped {
            return
        }
        
        isCardSetuped = true
        
        let requirementItemsNumber = 3
        guard let jsonArray = object?.details?.array?.cutFirstItems(itemsNumber: requirementItemsNumber) else {
            assertionFailure()
            return
        }
        
        let items = jsonArray
            .compactMap { SearchItemResponse(withJSON: $0) }
            .compactMap { WrapData(remote: $0) }
        
        self.items = items
        
        setupDate(for: items.first)
        
        let urls = items.compactMap { $0.metaData?.mediumUrl }
        
        guard urls.hasItems else {
            return
        }
        setupImages(by: urls)
        
        setupRecognizer()
    }
    
    private func setupDate(for item: Item?) {
        let currentYear = Date().getYear()
        
        guard
            let photoYear = item?.metaDate.getYear(),
            currentYear >= photoYear
        else {
            return
        }

        let intervar = currentYear - photoYear
        
        let timePast: String
        switch intervar {
        case 0:
            timePast = TextConstants.tbMatiHomeCardThisYear
        case 1:
            timePast = String(format: TextConstants.tbMatiHomeCardYearAgo, intervar)
        default:
            ///all more then 1 year (no negative integers, they sorts in guard condition)
            timePast = String(format: TextConstants.tbMatiHomeCardYearsAgo, intervar)
        }

        DispatchQueue.main.async {
            self.dateLabel.text = timePast
        }
    }
    
    private func setupImages(by urls: [URL]) {
        var images = [UIImage]()
        let group = DispatchGroup()
        
        urls.forEach { url in
            group.enter()
            imageDownloder.getImageByTrimming(url: url) { image in
                guard let image = image else {
                    group.leave()
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
    
    private func setupRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onActionButton))
        addGestureRecognizer(recognizer)
    }
    
    private func createImageView(with image: UIImage) -> UIImageView {
        let width = image.size.width
        let height = image.size.height
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
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .tbmatik, eventLabel: .tbmatik(.letsSee))
        
        guard items.hasItems else {
            return
        }
        let vc = TBMatikPhotosViewController.with(items: items)
        RouterVC().presentViewController(controller: vc)
    }
    
    @IBAction private func onCloseButton(_ sender: UIButton) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .tbmatik, eventLabel: .tbmatik(.close))
        deleteCard()
    }
}
