//
//  RaffleViewController.swift
//  Lifebox
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

enum RaffleElement: String, Codable {
    case login = "LOGIN"
    case purchasePackage = "PURCHASING_PACKAGE"
    case photopick = "PHOTO_PICK"
    case createCollage = "CREATE_COLLAGE"
    case photoPrint = "PHOTO_PRINT"
    case createStory = "CREATE_STORY"
    
    var title: String {
        switch self {
        case .login: return TextConstants.loginTitle
        case .purchasePackage: return "PURCHASING_PACKAGE"
        case .photopick: return "Photopick"
        case .createCollage: return localized(.createCollageLabel)
        case .photoPrint: return localized(.photoPrint)
        case .createStory: return TextConstants.createStory
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
    
    private lazy var rightViewTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = AppColor.background.color
        view.textColor = AppColor.label.color
        view.font = .appFont(.regular, size: 10)
        view.textAlignment = .left
        view.layer.cornerRadius = 21
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var rightViewSummaryButton: UIButton = {
        let view = UIButton()
        view.setTitle("Çekiliş Özetini Gör", for: .normal)
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
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 45, height: 45)
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(RaffleCollectionViewCell.self, forCellWithReuseIdentifier: "RaffleCollectionViewCell")
        view.backgroundColor = AppColor.background.color
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    var output: RaffleViewOutput!
    private var id: Int = 0
    private var imageUrl: String = ""
    private var statusResponse: RaffleStatusResponse?
    private var raffleStatusElement: [RaffleElement] = [.login, .purchasePackage, .photopick, .createCollage, .photoPrint, .createStory]
    private var raffleStatusElementOppacity: [Float] = []
    
    init(id: Int, url: String) {
        self.id = id
        self.imageUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.drawDetailHeader))
        view.backgroundColor = AppColor.background.color
        
        showSpinner()
        output.getRaffleStatus(id: 1)
    }
    
    override func viewDidLayoutSubviews() {
        rightViewTextView.centerVertically()
    }
    
    @objc private func summaryButtonTapped() {
        print("aaaaaaaaaaaaa 0")
    }
    
    @objc private func infoLabelTapped() {
        print("aaaaaaaaaaaaa 1")
    }
    
    private func successStatus(status: RaffleStatusResponse) {
        DispatchQueue.main.async {
            self.statusResponse = status
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
        print("aaaaaaaaaaa \(oppacity)")
        cell.configure(image: raffle.icon, title: raffle.title, imageOppacity: oppacity)
        return cell
    }
}

extension RaffleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let columns: CGFloat = 3
        let row: CGFloat = 2
        let spacing: CGFloat = 5
        
        let totalHorizontalSpacing = (columns - 1) * spacing
        let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / columns
        
        let totalVerticalSpacing = (row - 1) * spacing
        let itemHeight = (collectionView.bounds.height - totalVerticalSpacing) / row
        
        let itemSize = CGSize(width: itemWidth, height: itemHeight)
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
        
        contentView.addSubview(rightView)
        rightView.translatesAutoresizingMaskIntoConstraints = false
        rightView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        rightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        rightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        rightView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        rightView.addSubview(rightViewTitleLabel)
        rightViewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rightViewTitleLabel.topAnchor.constraint(equalTo: rightView.topAnchor, constant: 12).isActive = true
        rightViewTitleLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 8).isActive = true
        rightViewTitleLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -8).isActive = true
        rightViewTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        rightView.addSubview(rightViewTextView)
        rightViewTextView.translatesAutoresizingMaskIntoConstraints = false
        rightViewTextView.topAnchor.constraint(equalTo: rightViewTitleLabel.bottomAnchor, constant: 8).isActive = true
        rightViewTextView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 8).isActive = true
        rightViewTextView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -8).isActive = true
        rightViewTextView.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        rightView.addSubview(rightViewSummaryButton)
        rightViewSummaryButton.translatesAutoresizingMaskIntoConstraints = false
        rightViewSummaryButton.topAnchor.constraint(equalTo: rightViewTextView.bottomAnchor, constant: 12).isActive = true
        rightViewSummaryButton.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 8).isActive = true
        rightViewSummaryButton.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -8).isActive = true
        rightViewSummaryButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        rightView.addSubview(rightViewInfoLabel)
        rightViewInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        rightViewInfoLabel.topAnchor.constraint(equalTo: rightViewSummaryButton.bottomAnchor, constant: 12).isActive = true
        rightViewInfoLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 8).isActive = true
        rightViewInfoLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -8).isActive = true
        rightViewInfoLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: rightView.bottomAnchor, constant: 20).activate()
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).activate()
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).activate()        
        collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).activate()
        collectionView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        for el in raffleStatusElement {
            var oppacity = 1.0
            for value in statusResponse?.details ?? [] {
                if el.rawValue == value.earnType {
                    oppacity = 0.2
                }
            }
            self.raffleStatusElementOppacity.append(Float(oppacity))
        }

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        imageView.loadImageData(with: URL(string: imageUrl))
        rightViewTitleLabel.text = "Hediye Çekiliş Hakkı"
        rightViewTextView.text = "59 Adet çekiliş hakkın mevcut"
        
        let attributedString = NSMutableAttributedString(string: "Kampanya Koşullarını öğrenmek için tıklayın.")
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
