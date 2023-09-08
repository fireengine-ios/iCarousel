//
//  PhotoPrintViewController.swift
//  Depo
//
//  Created by Ozan Salman on 22.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

enum Subviews {
    case countTitleLabel
    case titleLabel
    case addDeleteContainer
    case rotateButton
    case imageContainerView
    case infoIcon
    case infoLabel
    case checkButton
    case checkLabel
    case newPhotoIcon
    case newPhotoLabel
    case contentContainerView
    case containerView
    
    var layerName: String {
        switch self {
        case .countTitleLabel:
            return "countTitleLabel"
        case .titleLabel:
            return "titleLabel"
        case .addDeleteContainer:
            return "addDeleteContainer"
        case .rotateButton:
            return "rotateButton"
        case .imageContainerView:
            return "imageContainerView"
        case .infoIcon:
            return "infoIcon"
        case .infoLabel:
            return "infoLabel"
        case .checkButton:
            return "checkButton"
        case .checkLabel:
            return "checkLabel"
        case .newPhotoIcon:
            return "newPhotoIcon"
        case .newPhotoLabel:
            return "newPhotoLabel"
        case .contentContainerView:
            return "contentContainerView"
        case .containerView:
            return "containerView"
        }
    }
}

final class PhotoPrintViewController: BaseViewController {
    
    private var containerScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints  = false
        view.backgroundColor = AppColor.background.color
        view.isScrollEnabled = true
        return view
    }()

    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints  = false
        view.backgroundColor = AppColor.background.color
        return view
    }()
        
    private let stackMainView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 40
        return view
    }()
    
    private let nextButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.titleLabel?.font = .appFont(.medium, size: 16)
        view.setTitle(localized(.printContinueButton), for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private var contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints  = false
        view.backgroundColor = AppColor.background.color
        view.layer.name = Subviews.contentContainerView.layerName
        return view
    }()
    
    private lazy var contentCheckButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(Image.iconPrintSelectEmpty.image, for: .normal)
        view.addTarget(self, action: #selector(contentCheckButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var contentCheckLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.light, size: 14)
        view.textColor = AppColor.label.color
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        view.textAlignment = .left
        return view
    }()
    
    private var lowQualityPhotosCount: Int = 0
    private var maxSelectablePhoto: Int = 5
    private var badQuailtySize: Int = 3
    private var contentViewIsHaveCheckBox: Bool = false
    private var isContentCheckBoxChecked: Bool = false
    private var defaultW = Double()
    private var defaultH = Double()
    private var beforeMinPinch = 0
    private var afterMinPinch = 0
    private var imageSizeArray = [CGSize]()
    private var selectedPhotos = [SearchItemResponse]()
    private var photoSelectType = PrintPhotoSelectType.newPhotoSelection
    private var selectedPhotoIndex: Int = 0
    private let router = PhotoPrintRouter()
    var output: PhotoPrintViewOutput!
    
    init(selectedPhotos: [SearchItemResponse]) {
        self.selectedPhotos = selectedPhotos
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("PhotoPrintViewController viewDidLoad")
        
        setTitle(withString: localized(.printEditPhotoPageName))
        view.backgroundColor = AppColor.background.color
        setLayout()
        
        for index in 0..<selectedPhotos.count {
            let view = createView(selectedPhotos: selectedPhotos[index], index: index)
            stackMainView.addArrangedSubview(view)
            view.leadingAnchor.constraint(equalTo: stackMainView.leadingAnchor, constant: 0).isActive = true
        }
        
        for index in 0..<selectedPhotos.count {
            showSpinner()
            let imageUrl = selectedPhotos[index].metadata?.largeUrl
            let imageView = getView(tag: index, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0] as! UIImageView
            imageView.sd_setImage(with: imageUrl) { [weak self] (image, error, cache, url) in
                if error != nil {
                    self?.hideSpinner()
                    UIApplication.showErrorAlert(message: error?.localizedDescription ?? "", closed: {
                        let router = RouterVC()
                        router.popViewController()
                    })
                } else {
                    self?.setHidden(image: image!, tag: index)
                    self?.setImageReplace(tag: index, image: image!)
                    self?.imageSizeArray.append(image!.size)
                    if (self?.selectedPhotos.count ?? 1) - 1 == index {
                        self?.nextButtonEnabled()
                        self?.hideSpinner()
                    }
                }
            }
        }
        
        stackMainView.setCustomSpacing(32, after: stackMainView.subviews[selectedPhotos.count - 1])
        setLayoutSecondary()
        addRemoveContentContainerView(isAdd: totalPhotoCount() != 5, photoCount: totalPhotoCount())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        switch photoSelectType {
        case .newPhotoSelection:
            setViewTag()
        case .changePhotoSelection:
            showSpinner()
            let newSelectedPhotos = PhotoPrintConstants.selectedChangePhotoItems 
            let imageView = getView(tag: selectedPhotoIndex, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0] as? UIImageView
            
            let imageUrl = newSelectedPhotos[0].metadata?.largeUrl
            imageView?.sd_setImage(with: imageUrl) { [weak self] (image, error, cache, url) in
                if error != nil {
                    self?.hideSpinner()
                    UIApplication.showErrorAlert(message: error?.localizedDescription ?? "", closed: {
                        
                    })
                } else {
                    self?.setHidden(image: image!, tag: self!.selectedPhotoIndex)
                    self?.setImageReplace(tag: self!.selectedPhotoIndex, image: image!)
                    self?.imageSizeArray.insert(image!.size, at: self!.selectedPhotoIndex)
                    self?.nextButtonEnabled()
                    self?.setViewTag()
                    self?.addRemoveContentContainerView(isAdd: self?.totalPhotoCount() != 5, photoCount: (self?.totalPhotoCount())!)
                    self?.nextButtonEnabled()
                }
            }
        }
        
    }
    
    @objc private func addButtonTapped(sender: UIButton) {
        let view = getView(tag: sender.tag, layerName: Subviews.addDeleteContainer.layerName)
        let countLabel = view.subviews[1] as? UILabel

        let count = Int(countLabel?.text ?? "0") ?? 0
        if count < maxSelectablePhoto {
            countLabel?.text = String((count) + 1)
        }
        addRemoveContentContainerView(isAdd: totalPhotoCount() != 5, photoCount: totalPhotoCount())
        nextButtonEnabled()
    }
    
    @objc private func deleteButtonTapped(sender: UIButton) {
        let minCount = 1
        let view = getView(tag: sender.tag, layerName: Subviews.addDeleteContainer.layerName)
        let countLabel = view.subviews[1] as? UILabel
        
        let count = Int(countLabel?.text ?? "0") ?? 0
        if count > minCount {
            countLabel?.text = String((count) - 1)
        }
        
        if count == 1 {
            
            let controller = PopUpController.with(title: TextConstants.actionSheetDelete,
                                                  message: "Fotoğraf kaldırılacak ve düzenlemeler kaybedilecektir",
                                                  image: .delete,
                                                  firstButtonTitle: TextConstants.cancel,
                                                  secondButtonTitle: TextConstants.ok,
                                                  secondAction: { vc in
                vc.close(completion: {
                    if self.selectedPhotos.count > 1 {
                        let imageView = self.getView(tag: sender.tag, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0] as? UIImageView
                        self.setLowQualityPhotosCount(image: (imageView?.image)!)
                        let viewInStack = self.stackMainView.arrangedSubviews[sender.tag]
                        self.stackMainView.removeArrangedSubview(viewInStack)
                        viewInStack.removeFromSuperview()
                        self.selectedPhotos.remove(at: sender.tag)
                        self.imageSizeArray.remove(at: sender.tag)
                        self.showSpinner()
                        self.setViewTag()
                    } else {
                        print("aaaaaaa geri dön")
                    }
                })
            })
            
            controller.open()
        }
        addRemoveContentContainerView(isAdd: totalPhotoCount() != 5, photoCount: totalPhotoCount())
        nextButtonEnabled()
    }
    
    @objc private func checkButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let view = getView(tag: sender.tag, layerName: Subviews.checkButton.layerName)
        let button = view as? UIButton
        sender.isSelected ? button?.setImage(Image.iconPrintSelectBlue.image, for: .normal) : button?.setImage(Image.iconPrintSelectEmpty.image, for: .normal)
        lowQualityPhotosCount = sender.isSelected ? lowQualityPhotosCount - 1 : lowQualityPhotosCount + 1
        nextButtonEnabled()
    }
    
    @objc private func rotateButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let portraitHeightConstant = (view.frame.width) / 0.664
        let landscapeHeightConstant = (view.frame.width) / 1.506

        let view = getView(tag: sender.tag, layerName: Subviews.imageContainerView.layerName)
        if let constraint = (view.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = sender.isSelected ? portraitHeightConstant : landscapeHeightConstant
        }
        setViewTag()
    }
    
    @objc private func newPhotoSelectTapped(_ sender: AnyObject) {
        photoSelectType = .changePhotoSelection
        selectedPhotoIndex = sender.view!.tag
        let imageView = getView(tag: sender.view!.tag, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0] as! UIImageView
        setLowQualityPhotosCount(image: imageView.image!)
        imageSizeArray.remove(at: sender.view!.tag)
        router.openSelectPhotosWithChange(selectedPhotos: selectedPhotos, popupShowing: false)
    }
    
    @objc private func contentCheckButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.isSelected ? contentCheckButton.setImage(Image.iconPrintSelectBlue.image, for: .normal) : contentCheckButton.setImage(Image.iconPrintSelectEmpty.image, for: .normal)
        isContentCheckBoxChecked = sender.isSelected
        nextButtonEnabled()
    }
    
    @objc private func nextButtonTapped(sender: UIButton) {
        print(totalPhotoCount())
    }
    
    private func setImageReplace(tag: Int, image: UIImage) {
        let isPortrait = getIsPortraitOrLandscape(image: image)
        let portraitHeightConstant = (view.frame.width) / 0.664
        let landscapeHeightConstant = (view.frame.width) / 1.506
        
        let view = getView(tag: tag, layerName: Subviews.imageContainerView.layerName)
        if let constraint = (view.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = isPortrait ? portraitHeightConstant : landscapeHeightConstant
        }
    }
    
    private func getIsPortraitOrLandscape(image: UIImage) -> Bool {
        if image.size.width < image.size.height {
            return true
        }
        return false
    }
    
    private func setHidden(image: UIImage, tag: Int) {
        let containerView = stackMainView.arrangedSubviews[tag]
        let infoIcon = getView(tag: tag, layerName: Subviews.infoIcon.layerName)
        let infoLabel = getView(tag: tag, layerName: Subviews.infoLabel.layerName)
        let checkButton = getView(tag: tag, layerName: Subviews.checkButton.layerName)
        let checkLabel = getView(tag: tag, layerName: Subviews.checkLabel.layerName)
        let newPhotoIcon = getView(tag: tag, layerName: Subviews.newPhotoIcon.layerName)
        let newPhotoLabel = getView(tag: tag, layerName: Subviews.newPhotoLabel.layerName)
        
        if getImageSize(image: image) < CGFloat(badQuailtySize) {
            lowQualityPhotosCount += 1
            (infoLabel as? UILabel)?.text = String(format: localized(.printPhotoBadQualityInfo), badQuailtySize)
            (infoLabel as? UILabel)?.textColor = AppColor.forgetPassTextRed.color
            (infoIcon as? UIImageView)?.image = Image.iconPrintInfoRed.image
            infoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = false
            checkButton.isHidden = false
            checkLabel.isHidden = false
            newPhotoIcon.isHidden = false
            newPhotoLabel.isHidden = false
        } else {
            (infoLabel as? UILabel)?.text = localized(.printEditPhotoPageName)
            (infoLabel as? UILabel)?.textColor = AppColor.darkBlue.color
            (infoIcon as? UIImageView)?.image = Image.iconInfo.image
            infoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
            checkButton.isHidden = true
            checkLabel.isHidden = true
            newPhotoIcon.isHidden = true
            newPhotoLabel.isHidden = true
        }
    }
    
    private func getImageSize(image: UIImage) -> Double {
        let imgData = NSData(data: image.pngData()!)
        let imageSize: Int = imgData.count
        return Double(imageSize) / 1000.0 / 1000.0
    }
    
    private func getView(tag: Int, layerName: String) -> UIView {
        let view = stackMainView.arrangedSubviews[tag].subviews
        for (_, element) in view.enumerated() {
            if element.layer.name == layerName {
                return element
            }
        }
        return view[0]
    }
    
    private func totalPhotoCount() -> Int {
        var photoCount: Int = 0
        let subView = stackMainView.arrangedSubviews
        for (index, element) in subView.enumerated() {
            if element.layer.name == Subviews.containerView.layerName {
                let countLabel = getView(tag: index, layerName: Subviews.addDeleteContainer.layerName).subviews[1] as? UILabel
                photoCount += Int(countLabel?.text ?? "0") ?? 0
            }
        }
        return photoCount
    }
    
    private func nextButtonEnabled() {
        if lowQualityPhotosCount > 0 {
            nextButton.backgroundColor = AppColor.borderLightGray.color
            nextButton.isUserInteractionEnabled = false
        } else if lowQualityPhotosCount == 0 && !contentViewIsHaveCheckBox {
            nextButton.backgroundColor = AppColor.darkBlueColor.color
            nextButton.isUserInteractionEnabled = true
        } else if lowQualityPhotosCount == 0 && contentViewIsHaveCheckBox && isContentCheckBoxChecked {
            nextButton.backgroundColor = AppColor.darkBlueColor.color
            nextButton.isUserInteractionEnabled = true
        } else if lowQualityPhotosCount == 0 && contentViewIsHaveCheckBox && !isContentCheckBoxChecked {
            nextButton.backgroundColor = AppColor.borderLightGray.color
            nextButton.isUserInteractionEnabled = false
        }
    }
    
    private func setLowQualityPhotosCount(image: UIImage) {
        if self.getImageSize(image: image) < CGFloat(self.badQuailtySize) {
            self.lowQualityPhotosCount -= 1
        }
    }
    
    private func setViewTag() {
        for index in 0..<selectedPhotos.count {
            getView(tag: index, layerName: Subviews.countTitleLabel.layerName).tag = index
            getView(tag: index, layerName: Subviews.titleLabel.layerName).tag = index
            getView(tag: index, layerName: Subviews.addDeleteContainer.layerName).tag = index
            getView(tag: index, layerName: Subviews.addDeleteContainer.layerName).subviews[0].tag = index
            getView(tag: index, layerName: Subviews.addDeleteContainer.layerName).subviews[1].tag = index
            getView(tag: index, layerName: Subviews.addDeleteContainer.layerName).subviews[2].tag = index
            getView(tag: index, layerName: Subviews.rotateButton.layerName).tag = index
            getView(tag: index, layerName: Subviews.imageContainerView.layerName).tag = index
            getView(tag: index, layerName: Subviews.imageContainerView.layerName).subviews[0].tag = index
            getView(tag: index, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0].tag = index
            getView(tag: index, layerName: Subviews.infoIcon.layerName).tag = index
            getView(tag: index, layerName: Subviews.infoLabel.layerName).tag = index
            getView(tag: index, layerName: Subviews.checkButton.layerName).tag = index
            getView(tag: index, layerName: Subviews.checkLabel.layerName).tag = index
            getView(tag: index, layerName: Subviews.newPhotoIcon.layerName).tag = index
            getView(tag: index, layerName: Subviews.newPhotoLabel.layerName).tag = index
            getView(tag: index, layerName: Subviews.contentContainerView.layerName).tag = index
        }
        
        for view in contentView.subviews {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addSeparatorToContentView()
            self.hideSpinner()
        }
    }
    
    private func addSeparatorToContentView() {
        for index in 0..<selectedPhotos.count - 1 {
            let stackView = contentView.subviews[0].subviews[index]
            let separator = UILabel(frame: CGRect(x: 0, y: stackView.frame.maxY + 30.0, width: view.frame.size.width, height: 1))
            separator.backgroundColor = AppColor.borderLightGray.color
            contentView.addSubview(separator)
        }
        let stackView = contentView.subviews[0].subviews[selectedPhotos.count - 1]
        let separator = UILabel(frame: CGRect(x: 0, y: stackView.frame.maxY + 30.0, width: view.frame.size.width, height: 1))
        separator.backgroundColor = AppColor.borderLightGray.color
        contentView.addSubview(separator)
    }
}

extension PhotoPrintViewController: UIGestureRecognizerDelegate {
    @objc private func pinch(_ sender: UIPinchGestureRecognizer) {
        guard let view = sender.view else { return }
        view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
        
        if sender.state == .ended {
            let imageContainerView = getView(tag: sender.view?.tag ?? 0, layerName: Subviews.imageContainerView.layerName) as! UIView
            let scrollView = getView(tag: sender.view?.tag ?? 0, layerName: Subviews.imageContainerView.layerName).subviews[0] as! UIScrollView
            let imageView = getView(tag: sender.view?.tag ?? 0, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0] as! UIImageView
            
            imageContainerView.layer.borderColor = AppColor.tealBlue.cgColor
            
            let viewFrame = scrollView.frame
            let imageViewWidth = imageView.frame.width
            let imageViewHeight = imageView.frame.height
            
            if viewFrame.width >= viewFrame.height {
                if imageViewWidth <= viewFrame.width {
                    imageView.transform = .identity
                    imageView.frame = CGRect(x: 0, y: 0, width: imageSizeArray[sender.view?.tag ?? 0].width, height: imageSizeArray[sender.view?.tag ?? 0].height)
                    defaultW = imageView.frame.width
                    defaultH = imageView.frame.height
                    beforeMinPinch = 1
                }
            } else {
                if imageViewHeight <= viewFrame.height {
                    imageView.transform = .identity
                    imageView.frame = CGRect(x: 0, y: 0, width: imageSizeArray[sender.view?.tag ?? 0].width, height: imageSizeArray[sender.view?.tag ?? 0].height)
                    defaultW = imageView.frame.width
                    defaultH = imageView.frame.height
                    beforeMinPinch = 1
                }
            }
            
            let x = imageView.frame.origin.x
            let y = imageView.frame.origin.y
            let scrollContentSizeWidth = scrollView.contentSize.width
            let scrollContentSizeHeight = scrollView.contentSize.height
            let imageWidth = imageView.frame.width
            let imageHeight = imageView.frame.height
            let _ = scrollContentSizeHeight - imageHeight
            let _ = scrollContentSizeWidth - imageWidth
            var bottom1 = Double()
            var right1 = Double()
            
            
            if beforeMinPinch == 0 && afterMinPinch == 0 {
                scrollView.contentInset = UIEdgeInsets(top: -y, left: -x, bottom: -y, right: -x)
                return
            }
            
            if beforeMinPinch == 1 {
                scrollView.contentInset = UIEdgeInsets(top: -y, left: -x, bottom: -y, right: -x)
                beforeMinPinch = 0
                afterMinPinch = 1
                return
            }
            
            if beforeMinPinch == 0 && afterMinPinch == 1 {
                bottom1 = scrollContentSizeHeight - defaultH
                right1 = scrollContentSizeWidth - defaultW
                scrollView.contentInset = UIEdgeInsets(top: -y, left: -x, bottom: -y - bottom1, right: -x - right1)
            }
        }
    }
}

extension PhotoPrintViewController {
    private func setLayout() {
        view.addSubview(containerScrollView)
        containerScrollView.addSubview(contentView)
        contentView.addSubview(stackMainView)
        
        containerScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        containerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        containerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
        
        contentView.topAnchor.constraint(equalTo: containerScrollView.topAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 0).isActive = true
        contentView.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: 0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor, constant: 20).isActive = true
        contentView.widthAnchor.constraint(equalTo: containerScrollView.widthAnchor, constant: 0).isActive = true

        stackMainView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        stackMainView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8).isActive = true
        stackMainView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8).isActive = true
        stackMainView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -30).isActive = true
    }
    
    private func setLayoutSecondary() {
        stackMainView.addArrangedSubview(nextButton)
        nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        
        nextButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func addRemoveContentContainerView(isAdd: Bool, photoCount: Int) {
        if isAdd {
            stackMainView.addArrangedSubview(contentContainerView)
            contentContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
            contentContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
            contentContainerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
            
            contentContainerView.addSubview(contentCheckButton)
            contentCheckButton.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
            contentCheckButton.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
            contentCheckButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
            contentCheckButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            contentContainerView.addSubview(contentCheckLabel)
            contentCheckLabel.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
            contentCheckLabel.leadingAnchor.constraint(equalTo: contentCheckButton.trailingAnchor, constant: 8).isActive = true
            contentCheckLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -24).isActive = true
            
            contentCheckButton.setImage(Image.iconPrintSelectEmpty.image, for: .normal)
            photoCount < 5 ? contentCheckButton.setImage(Image.iconPrintSelectEmpty.image, for: .normal) : contentCheckButton.setImage(Image.iconPrintInfoRed.image, for: .normal)
            contentCheckLabel.text = photoCount < 5 ? String(format: localized(.morePhotoRight), maxSelectablePhoto - photoCount) : String(format: localized(.noMorePhotoRight), maxSelectablePhoto)
            contentCheckLabel.textColor = photoCount < 5 ? AppColor.label.color : AppColor.forgetPassTextRed.color
            contentViewIsHaveCheckBox = true
            stackMainView.setCustomSpacing(16, after: stackMainView.subviews[selectedPhotos.count])
        } else {
            contentViewIsHaveCheckBox = false
            isContentCheckBoxChecked = false
            stackMainView.removeArrangedSubview(contentContainerView)
            stackMainView.removeArrangedSubview(contentCheckButton)
            stackMainView.removeArrangedSubview(contentCheckLabel)
            contentContainerView.removeFromSuperview()
            contentCheckButton.removeFromSuperview()
            contentCheckLabel.removeFromSuperview()
        }
    }
}

extension PhotoPrintViewController {
    func createView(selectedPhotos: SearchItemResponse, index: Int) -> UIView {
        
        lazy var containerView: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 16
            view.backgroundColor = AppColor.background.color
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
            view.layer.name = "containerView"
            view.tag = index
            return view
        }()
        
        lazy var countTitleLabel: UILabel = {
            let view = UILabel()
            view.font = .appFont(.medium, size: 12)
            view.numberOfLines = 1
            view.textAlignment = .center
            view.backgroundColor = AppColor.background.color
            view.layer.borderWidth = 2
            view.layer.cornerRadius = 8
            view.layer.borderColor = AppColor.label.cgColor
            view.layer.masksToBounds = true
            view.text = String(index+1)
            view.layer.name = Subviews.countTitleLabel.layerName
            view.textColor = AppColor.label.color
            view.tag = index
            return view
        }()

        lazy var titleLabel: UILabel = {
            let view = UILabel()
            view.font = .appFont(.medium, size: 12)
            view.textColor = AppColor.label.color
            view.numberOfLines = 0
            view.textAlignment = .left
            view.lineBreakMode = .byWordWrapping
            view.backgroundColor = AppColor.background.color
            view.text = selectedPhotos.name
            view.layer.name = Subviews.titleLabel.layerName
            view.tag = index
            return view
        }()
        
        lazy var addDeleteContainer: UIView = {
            let view = UIView()
            view.backgroundColor = AppColor.background.color
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 8
            view.layer.borderColor = AppColor.tealBlue.cgColor
            view.layer.name = Subviews.addDeleteContainer.layerName
            view.tag = index
            return view
        }()
        
        lazy var addButton: UIButton = {
           let view = UIButton()
            view.setImage(Image.iconPrintAdd.image, for: .normal)
            view.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
            view.layer.name = "addButton"
            view.tag = index
            return view
        }()
        
        lazy var addDeleteCountLabel: UILabel = {
            let view = UILabel()
            view.font = .appFont(.medium, size: 12)
            view.numberOfLines = 0
            view.textAlignment = .center
            view.lineBreakMode = .byWordWrapping
            view.text = "1"
            view.layer.name = "addDeleteCountLabel"
            view.tag = index
            return view
        }()
        
        lazy var deleteButton: UIButton = {
            let view = UIButton()
            view.setImage(Image.iconPrintDelete.image, for: .normal)
            view.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
            view.layer.name = "deleteButton"
            view.tag = index
            return view
        }()
        
        lazy var rotateButton: UIButton = {
            let view = UIButton()
            view.setImage(Image.iconRotate1015.image, for: .normal)
            view.addTarget(self, action: #selector(rotateButtonTapped), for: .touchUpInside)
            view.tag = index
            view.layer.name = Subviews.rotateButton.layerName
            view.tag = index
            return view
        }()
        
        lazy var imageContainerView: UIView = {
            let view = UIView()
            view.backgroundColor = AppColor.background.color
            view.layer.borderWidth = 3
            view.layer.cornerRadius = 16
            view.layer.borderColor = AppColor.forgetPassTextGreen.cgColor
            view.layer.name = Subviews.imageContainerView.layerName
            return view
        }()
        
        lazy var printScrollView: UIScrollView = {
            let view = UIScrollView()
            view.layer.cornerRadius = 8
            view.showsVerticalScrollIndicator = false
            view.showsHorizontalScrollIndicator = false
            view.layer.name = "printScrollView"
            view.tag = index
            return view
        }()
        
        lazy var printImageView: UIImageView = {
            let view = UIImageView()
            view.isUserInteractionEnabled = true
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
            pinchGesture.delegate = self
            view.addGestureRecognizer(pinchGesture)
            view.layer.cornerRadius = 8
            view.contentMode = .scaleAspectFit
            view.layer.name = "printImageView"
            view.tag = index
            return view
        }()
        
        lazy var infoIcon: UIImageView = {
            let view = UIImageView()
            view.image = Image.iconInfo.image
            view.layer.name = Subviews.infoIcon.layerName
            view.tag = index
            return view
        }()
        
        lazy var infoLabel: UILabel = {
            let view = UILabel()
            view.font = .appFont(.medium, size: 12)
            view.text = localized(.printEditPhotoPageName)
            view.textColor = AppColor.darkBlue.color
            view.numberOfLines = 2
            view.textAlignment = .left
            view.lineBreakMode = .byWordWrapping
            view.backgroundColor = AppColor.background.color
            view.layer.name = Subviews.infoLabel.layerName
            view.tag = index
            return view
        }()
        
        lazy var checkButton: UIButton = {
            let view = UIButton()
            view.setImage(Image.iconPrintSelectEmpty.image, for: .normal)
            view.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
            view.isHidden = false
            view.layer.name = Subviews.checkButton.layerName
            view.tag = index
            return view
        }()
        
        lazy var checkLabel: UILabel = {
            let view = UILabel()
            view.font = .appFont(.light, size: 14)
            view.text = localized(.printPhotoBadQualityContinue)
            view.numberOfLines = 1
            view.textAlignment = .left
            view.backgroundColor = AppColor.background.color
            view.isHidden = false
            view.layer.name = Subviews.checkLabel.layerName
            view.tag = index
            return view
        }()
        
        lazy var newPhotoIcon: UIImageView = {
            let view = UIImageView()
            view.image = Image.iconPrintSelectPhoto.image
            view.isHidden = false
            view.layer.name = Subviews.newPhotoIcon.layerName
            view.tag = index
            return view
        }()
        
        lazy var newPhotoLabel: UILabel = {
            let view = UILabel()
            view.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(newPhotoSelectTapped(_:)))
            view.addGestureRecognizer(tapImage)
            view.text = localized(.printPhotoBadQualityNew)
            view.textColor = AppColor.tealBlue.color
            view.font = .appFont(.bold, size: 14)
            view.numberOfLines = 1
            view.textAlignment = .left
            view.backgroundColor = AppColor.background.color
            view.isHidden = false
            view.layer.name = Subviews.newPhotoLabel.layerName
            view.tag = index
            return view
        }()
        
        containerView.addSubview(countTitleLabel)
        countTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        countTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        countTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8).isActive = true
        countTitleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        countTitleLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: countTitleLabel.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: countTitleLabel.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: countTitleLabel.trailingAnchor, constant: 8).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        containerView.addSubview(addDeleteContainer)
        addDeleteContainer.translatesAutoresizingMaskIntoConstraints = false
        addDeleteContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        addDeleteContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        addDeleteContainer.heightAnchor.constraint(equalToConstant: 24).isActive = true
        addDeleteContainer.widthAnchor.constraint(equalToConstant: 76).isActive = true
        
        addDeleteContainer.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: addDeleteContainer.topAnchor, constant: 3).isActive = true
        addButton.bottomAnchor.constraint(equalTo: addDeleteContainer.bottomAnchor, constant: -3).isActive = true
        addButton.trailingAnchor.constraint(equalTo: addDeleteContainer.trailingAnchor, constant: -6).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        addDeleteContainer.addSubview(addDeleteCountLabel)
        addDeleteCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addDeleteCountLabel.topAnchor.constraint(equalTo: addDeleteContainer.topAnchor, constant: 3).isActive = true
        addDeleteCountLabel.bottomAnchor.constraint(equalTo: addDeleteContainer.bottomAnchor, constant: -3).isActive = true
        addDeleteCountLabel.leadingAnchor.constraint(equalTo: addDeleteContainer.leadingAnchor, constant: 30).isActive = true
        addDeleteCountLabel.trailingAnchor.constraint(equalTo: addDeleteContainer.trailingAnchor, constant: -30).isActive = true
        addDeleteCountLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        addDeleteContainer.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: addDeleteContainer.topAnchor, constant: 3).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: addDeleteContainer.bottomAnchor, constant: -3).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: addDeleteContainer.leadingAnchor, constant: 6).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        containerView.addSubview(rotateButton)
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
        rotateButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        rotateButton.trailingAnchor.constraint(equalTo: addDeleteContainer.leadingAnchor, constant: -16).isActive = true
        rotateButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        rotateButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        let heightConstant = (view.frame.width) / 1.506
        
        containerView.addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.topAnchor.constraint(equalTo: countTitleLabel.bottomAnchor, constant: 16).isActive = true
        imageContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        imageContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        imageContainerView.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        
        imageContainerView.addSubview(printScrollView)
        printScrollView.translatesAutoresizingMaskIntoConstraints = false
        printScrollView.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: 10).isActive = true
        printScrollView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: -10).isActive = true
        printScrollView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor, constant: 10).isActive = true
        printScrollView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: -10).isActive = true
        
        printScrollView.addSubview(printImageView)
        printImageView.translatesAutoresizingMaskIntoConstraints = false
        printImageView.topAnchor.constraint(equalTo: printScrollView.topAnchor).isActive = true
        printImageView.bottomAnchor.constraint(equalTo: printScrollView.bottomAnchor).isActive = true
        printImageView.leadingAnchor.constraint(equalTo: printScrollView.leadingAnchor).isActive = true
        printImageView.trailingAnchor.constraint(equalTo: printScrollView.trailingAnchor).isActive = true
        
        containerView.addSubview(infoIcon)
        infoIcon.translatesAutoresizingMaskIntoConstraints = false
        infoIcon.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 8).isActive = true
        infoIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        infoIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        infoIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        containerView.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 8).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = false
        infoLabel.leadingAnchor.constraint(equalTo: infoIcon.trailingAnchor, constant: 8).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        infoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        
        containerView.addSubview(checkButton)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        checkButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16).isActive = true
        checkButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        checkButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        checkButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        containerView.addSubview(checkLabel)
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        checkLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16).isActive = true
        checkLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8).isActive = true
        checkLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        checkLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        containerView.addSubview(newPhotoIcon)
        newPhotoIcon.translatesAutoresizingMaskIntoConstraints = false
        newPhotoIcon.topAnchor.constraint(equalTo: checkLabel.bottomAnchor, constant: 16).isActive = true
        newPhotoIcon.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        newPhotoIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        newPhotoIcon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        newPhotoIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        containerView.addSubview(newPhotoLabel)
        newPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
        newPhotoLabel.topAnchor.constraint(equalTo: checkLabel.bottomAnchor, constant: 16).isActive = true
        newPhotoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        newPhotoLabel.leadingAnchor.constraint(equalTo: newPhotoIcon.trailingAnchor, constant: 8).isActive = true
        newPhotoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        return containerView
    }
}


extension PhotoPrintViewController: PhotoPrintViewInput {
    func didFinishedAllRequests() {
    }
}

extension PhotoPrintViewController: PhotoPrintViewOutput {
    func getSectionsCountAndName() {
        
    }
    
    func viewIsReady() {
        
    }
}
