import UIKit

final class TBMatikCard: BaseCardView {
    
    @IBOutlet private weak var imagesContainer: UIView! {
        willSet {
            newValue.clipsToBounds = true
        }
    }
    
    @IBOutlet private weak var imageView1: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet private weak var imageView2: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 0
            newValue.text = TextConstants.tbMatiHomeCardTitle
        }
    }
    
    @IBOutlet private weak var dateLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.text = " "
        }
    }
    
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
            newValue.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            newValue.setTitle(TextConstants.tbMatiHomeCardButtonTitle, for: .normal)
        }
    }
    
    private let imageDownloder = ImageDownloder()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    /// "func set(object:" called twice.
    /// you can find comment 'seems like duplicated logic "set(object:".' in the project.
    /// if you cannot find it then drop logic for this variable.
    private var isCardSetuped = false
    
    private var items = [Item]()
    private var images = [UIImage]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        analyticsService.logScreen(screen: .tbmatikHomePageCard)
        analyticsService.trackDimentionsEveryClickGA(screen: .tbmatikHomePageCard)
    }
    
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
        let group = DispatchGroup()
        
        urls.forEach { url in
            group.enter()
            imageDownloder.getImageByTrimming(url: url) { [weak self] image in
                guard let image = image else {
                    group.leave()
                    return
                }
                self?.images.append(image)
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.imageView1.image = self.images.first
            
            if !self.images.isEmpty {
                self.startZoomAnimation()
            }
        }
    }
    
    private func setupRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onActionButton))
        addGestureRecognizer(recognizer)
    }
    
    private func startZoomAnimation() {
        imageView2.alpha = 0
        if let image = imageView1.image, let index = images.firstIndex(of: image) {
            imageView2.image = images[safe: index + 1] ?? images.first
        }
        
        imageView1.transform = .identity
        UIView.animate(withDuration: 4) { [weak self] in
            self?.imageView1.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { [weak self] _ in
            self?.startDissolveAnimation()
        }
    }
    
    private func startDissolveAnimation() {
        imageView2.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        UIView.animate(withDuration: 2, delay: 0, options: .curveLinear) { [weak self] in
            self?.imageView2.transform = .identity
            self?.imageView2.alpha = 1
        } completion: { [weak self] _ in
            self?.imageView1.image = self?.imageView2.image
            self?.startZoomAnimation()
        }
    }

    @IBAction private func onActionButton(_ sender: UIButton) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .tbmatik, eventLabel: .tbmatik(.letsSee))
        
        guard items.hasItems else {
            return
        }
        
        var selectedIndex = 0
        if let image = imageView1.image, let index = images.firstIndex(of: image) {
            selectedIndex = index
        }
        
        let vc = TBMatikPhotosViewController.with(items: items, selectedIndex: selectedIndex)
        RouterVC().presentViewController(controller: vc)
    }
    
    @IBAction private func onCloseButton(_ sender: UIButton) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .tbmatik, eventLabel: .tbmatik(.close))
        deleteCard()
    }
}
