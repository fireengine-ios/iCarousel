//
//  RaffleViewController.swift
//  Lifebox
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//
enum RafflePeriod: String, Codable {
    case daily = "DAILY"
    case weekly = "WEEKLY"
    case monthly = "MONTHLY"
    
    var title: String {
        switch self {
        case .daily: return localized(.daily)
        case .weekly: return localized(.weekly)
        case .monthly: return localized(.monthly)
        }
    }
}

enum RaffleElement: String, Codable {
    case login = "LOGIN"
    case purchasePackage = "PURCHASING_PACKAGE"
    case photopick = "PHOTO_PICK"
    case createCollage = "CREATE_COLLAGE"
    case photoPrint = "PHOTO_PRINT"
    case createStory = "CREATE_STORY"
    case createAlbum = "CREATE_ALBUM"
    case faceImage = "FACE_IMAGE"
    case fotoVideoUpload = "FOTO_VIDEO_UPLOAD"
    case inviteSignup = "INVITE_SIGNUP"
    
    var title: String {
        switch self {
        case .login: return TextConstants.loginTitle
        case .purchasePackage: return localized(.gamificationTitleBuy)
        case .photopick: return localized(.gamificationTitlePhotopick)
        case .createCollage: return localized(.gamificationTitleCreateCollage)
        case .photoPrint: return localized(.gamificationTitlePrint)
        case .createStory: return localized(.gamificationTitleCreateStory)
        case .createAlbum: return localized(.gamificationTitleCreateAlbum)
        case .faceImage: return localized(.gamificationTitleActFaceimage)
        case .fotoVideoUpload: return localized(.gamificationTitleUpload)
        case .inviteSignup: return localized(.gamificationTitleInvite)
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .login: return TextConstants.loginTitle
        case .purchasePackage: return localized(.gamificationBuy)
        case .photopick: return localized(.gamificationPhotopick)
        case .createCollage: return localized(.gamificationCreateCollage)
        case .photoPrint: return localized(.gamificationPrint)
        case .createStory: return localized(.gamificationCreateStory)
        case .createAlbum: return localized(.gamificationCreateAlbum)
        case .faceImage: return localized(.gamificationActFaceimage)
        case .fotoVideoUpload: return localized(.gamificationUpload)
        case .inviteSignup: return localized(.gamificationInvite)
        }
    }
    
    var icon: UIImage {
        switch self {
        case .login: return Image.raffleLogin.image
        case .purchasePackage: return Image.rafflePurchasePackage.image
        case .photopick: return Image.rafflePhotopick.image
        case .createCollage: return Image.raffleCreateCollage.image
        case .photoPrint: return Image.rafflePhotoPrint.image
        case .createStory: return Image.raffleCreateStory.image
        case .createAlbum: return Image.raffleCreateAlbum.image
        case .faceImage: return Image.raffleFaceImage.image
        case .fotoVideoUpload: return Image.raffleUploadPhotos.image
        case .inviteSignup: return Image.raffleCreateStory.image
        }
    }
    
    var detailText: String {
        switch self {
        default: return localized(.gamificationEventTriggerCount)
        }
    }
    
    var detailTextNoAction: String {
        switch self {
        default: return localized(.gamificationEventNotTrigerred)
        }
    }
    
    var infoLabelText: String {
        switch self {
        default: return localized(.gamificationEventCompleted)
        }
    }
}

final class RaffleViewController: BaseViewController {
    
    private lazy var containerScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColor.background.color
        view.isScrollEnabled = true
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColor.background.color
        return view
    }()
    
    private lazy var imageView: LoadingImageView = {
        let view = LoadingImageView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageLabel: PaddingLabel = {
        let view = PaddingLabel()
        view.numberOfLines = 1
        view.layer.backgroundColor = AppColor.background.cgColor
        view.font = .appFont(.medium, size: 12)
        view.textColor = AppColor.label.color
        view.textAlignment = .center
        view.paddingLeft = 15
        view.paddingRight = 15
        view.paddingTop = 8
        view.paddingBottom = 8
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private lazy var rightView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.raffleView.color
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var rightViewTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.bold, size: 16)
        view.textColor = AppColor.settingsButtonColor.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var rightViewSummaryButton: UIButton = {
        let view = UIButton()
        view.setTitle(localized(.gamificationRaffleBrief), for: .normal)
        view.titleLabel?.font = .appFont(.medium, size: 14)
        view.setTitleColor(.white, for: .normal)
        view.setTitleColor(.white, for: .selected)
        view.backgroundColor = AppColor.darkBlueColor.color
        view.layer.cornerRadius = 21
        view.clipsToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = AppColor.darkBlueColor.cgColor
        view.addTarget(self, action: #selector(summaryButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var rightViewInfoLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 12)
        view.textColor = AppColor.raffleLabel.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        view.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(infoLabelTapped))
        view.addGestureRecognizer(tapImage)
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 12)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 45, height: 45)
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(RaffleCollectionViewCell.self, forCellWithReuseIdentifier: "RaffleCollectionViewCell")
        view.backgroundColor = AppColor.background.color
        view.showsHorizontalScrollIndicator = false
        view.isScrollEnabled = false
        return view
    }()
    
    var output: RaffleViewOutput!
    private var id: Int = 0
    private var imageUrl: String = ""
    private var conditionImageUrl: String = ""
    private var statusResponse: RaffleStatusResponse?
    private var raffleStatusElement: [RaffleElement] = []
    private var raffleStatusElementOppacity: [Float] = []
    private var nextDayIsHidden: [Bool] = []
    private var rafflePeriod: [String] = []
    private var endDateText: String = ""
    
    init(id: Int, url: String, endDateText: String, conditionImageUrl: String) {
        self.id = id
        self.imageUrl = url
        self.conditionImageUrl = conditionImageUrl
        self.endDateText = endDateText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.gamificationRaffleInfo))
        view.backgroundColor = AppColor.background.color
        
        showSpinner()
        output.getRaffleStatus(id: id)
    }
    
    @objc private func summaryButtonTapped() {
        output.goToRaffleSummary(statusResponse: statusResponse)
    }
    
    @objc private func infoLabelTapped() {
        output.goToRaffleCondition(statusResponse: statusResponse, conditionImageUrl: conditionImageUrl)
    }
    
    private func successStatus(status: RaffleStatusResponse) {
        DispatchQueue.main.async {
            self.statusResponse = status
            for detail in self.statusResponse?.details ?? [] {
                let element = RaffleElement(rawValue: detail.earnType ?? RaffleElement.login.rawValue)
                self.raffleStatusElement.append(element)
            }
            self.setupLayout()
        }
    }
    
    private func failStatus(error: String) {
        UIApplication.showErrorAlert(message: error)
    }
}

extension RaffleViewController: RaffleViewInput {
    func successRaffleStatus(status: RaffleStatusResponse) {
        successStatus(status: status)
    }
    
    func failRaffleStatus(error: String) {
        failStatus(error: error)
    }
}

extension RaffleViewController: RaffleCollectionViewCellDelegate {
    func didImageTapped(raffle: RaffleElement) {
        let router = RaffleRouter()
        router.goToPages(raffle: raffle)
    }
}

extension RaffleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return raffleStatusElement.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RaffleCollectionViewCell", for: indexPath) as? RaffleCollectionViewCell else {
            return UICollectionViewCell()
        }
        let raffle = raffleStatusElement[indexPath.row]
        let oppacity = raffleStatusElementOppacity[indexPath.row]
        let isHidden = nextDayIsHidden[indexPath.row]
        let period = rafflePeriod[indexPath.row]
        cell.delegate = self
        cell.configure(raffle: raffle, imageOppacity: oppacity, nextLabelIsHidden: isHidden, period: period)
        return cell
    }
}

extension RaffleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3
        let spacing: CGFloat = 5
        let totalHorizontalSpacing = (columns - 1) * spacing
        let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / columns
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension RaffleViewController {
    private func setupLayout() {
        view.addSubview(containerScrollView)
        containerScrollView.addSubview(contentView)
        
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        containerScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        containerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        containerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
        
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: containerScrollView.topAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 0).isActive = true
        contentView.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: 0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor, constant: 20).isActive = true
        contentView.widthAnchor.constraint(equalTo: containerScrollView.widthAnchor, constant: 0).isActive = true
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        
        imageView.addSubview(imageLabel)
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10).isActive = true
        imageLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10).isActive = true
        imageLabel.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        contentView.addSubview(rightView)
        rightView.translatesAutoresizingMaskIntoConstraints = false
        rightView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        rightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        rightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        rightView.heightAnchor.constraint(equalToConstant: 138).isActive = true
        
        rightView.addSubview(rightViewTitleLabel)
        rightViewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rightViewTitleLabel.topAnchor.constraint(equalTo: rightView.topAnchor, constant: 12).isActive = true
        rightViewTitleLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 8).isActive = true
        rightViewTitleLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -8).isActive = true
        rightViewTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        rightView.addSubview(rightViewSummaryButton)
        rightViewSummaryButton.translatesAutoresizingMaskIntoConstraints = false
        rightViewSummaryButton.topAnchor.constraint(equalTo: rightViewTitleLabel.bottomAnchor, constant: 12).isActive = true
        rightViewSummaryButton.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 8).isActive = true
        rightViewSummaryButton.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -8).isActive = true
        rightViewSummaryButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        rightView.addSubview(rightViewInfoLabel)
        rightViewInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        rightViewInfoLabel.topAnchor.constraint(equalTo: rightViewSummaryButton.bottomAnchor, constant: 12).isActive = true
        rightViewInfoLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 8).isActive = true
        rightViewInfoLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -8).isActive = true
        rightViewInfoLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        contentView.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: rightView.bottomAnchor, constant: 10).activate()
        infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).activate()
        infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).activate()
        
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20).activate()
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).activate()
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).activate()        
        collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).activate()
        let rowCount = (CGFloat(raffleStatusElement.count) / 3.0).rounded(.awayFromZero)
        collectionView.heightAnchor.constraint(equalToConstant: rowCount * 120).isActive = true
        
        for el in raffleStatusElement {
            var oppacity: Float = 1.0
            var isHidden = true
            var period = RafflePeriod.daily
            for value in statusResponse?.details ?? [] {
                if el.rawValue == value.earnType {
                    let periodEarnLimit = value.periodEarnLimit ?? 0
                    let periodEarnedPoints = value.periodEarnedPoints ?? 0
                    let totalEarnLimit = value.totalEarnLimit ?? 0
                    let totalPointsEarnedRule = value.totalPointsEarnedRule ?? 0
                    if periodEarnLimit - periodEarnedPoints <= 0 || totalEarnLimit == totalPointsEarnedRule {
                        period = RafflePeriod(rawValue: value.periodType ?? RafflePeriod.daily.rawValue) ?? RafflePeriod.daily
                        isHidden = false
                        oppacity = 0.2
                    }
                }
            }
            raffleStatusElementOppacity.append(Float(oppacity))
            nextDayIsHidden.append(isHidden)
            rafflePeriod.append(period.title)
        }

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        imageView.loadImageData(with: URL(string: imageUrl))
        imageLabel.text = endDateText
        rightViewTitleLabel.text = String(format: localized(.gamificationRaffleCount), statusResponse?.totalPointsEarned ?? 0)
        infoLabel.text = localized(.gamificationEventDescription)
        
        let attributedString = NSMutableAttributedString(string: localized(.gamificationRaffleDraw))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        rightViewInfoLabel.attributedText = attributedString
        
        hideSpinner()
    }
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
