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
    
    private lazy var closeSelfButton = UIBarButtonItem(image: NavigationBarImage.back.image,
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(closeSelf))
    
    private var maxSelectablePhoto: Int = SingletonStorage.shared.accountInfo?.photoPrintMaxSelection ?? 0
    private var badQuailtySize: Double = 1
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
    private var isHaveEditedPhotos: Bool = false
    private var editedImages = [UIImage]()
    private var gettingImages = [UIImage]()
    private var contentInsetLeftConts = [CGFloat]()
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
        navigationItem.leftBarButtonItem = closeSelfButton
        NotificationCenter.default.addObserver(self,selector: #selector(navigationBackFromPopup),name: .navigationBack, object: nil)
        badQuailtySize = Double(FirebaseRemoteConfig.shared.printPhotoQualityMinMB) ?? 1
        
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
            let imageView = getView(tag: index, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0].subviews[0] as! UIImageView
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
                    self?.gettingImages.append(image)
                    if (self?.selectedPhotos.count ?? 1) - 1 == index {
                        self?.nextButtonEnabled()
                        self?.hideSpinner()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self?.setImageViewDetail(tag: index, byCallMethod: "viewDidLoad")
                    }
                }
            }
        }
        
        stackMainView.setCustomSpacing(32, after: stackMainView.subviews[selectedPhotos.count - 1])
        setLayoutSecondary()
        addRemoveContentContainerView(isAdd: totalPhotoCount() != maxSelectablePhoto, photoCount: totalPhotoCount())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        badQuailtySize = Double(FirebaseRemoteConfig.shared.printPhotoQualityMinMB) ?? 1
        switch photoSelectType {
        case .newPhotoSelection:
            setViewTag()
        case .changePhotoSelection:
            showSpinner()
            let newSelectedPhotos = PhotoPrintConstants.selectedChangePhotoItems 
            let imageView = getView(tag: selectedPhotoIndex, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0].subviews[0] as? UIImageView
            
            if newSelectedPhotos.isEmpty {
                hideSpinner()
                return
            }
            
            let imageUrl = newSelectedPhotos[0].metadata?.largeUrl
            let imageName = newSelectedPhotos[0].name
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
                    self?.addRemoveContentContainerView(isAdd: self?.totalPhotoCount() != self?.maxSelectablePhoto, photoCount: (self?.totalPhotoCount())!)
                    self?.nextButtonEnabled()
                    self?.hideSpinner()
                    self?.setTitleLabel(tag: self!.selectedPhotoIndex, name: imageName ?? "")
                    DispatchQueue.main.async {
                        self?.setImageViewDetail(tag: self!.selectedPhotoIndex)
                    }
                }
            }
        }
    }
    
    private func setImageViewDetail(tag: Int, byCallMethod: String = "") {
        let containerView = getView(tag: tag, layerName: Subviews.imageContainerView.layerName) as! UIView
        let scrollView = getView(tag: tag, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0] as! UIScrollView
        let imageView = getView(tag: tag, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0].subviews[0] as! UIImageView
        
        let w = containerView.frame.size.width
        let h = containerView.frame.size.height
        
        if let constraint = (imageView.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = h
        }
        if let constraint = (imageView.constraints.filter{$0.firstAttribute == .width}.first) {
            constraint.constant = w
        }
        
        imageView.frame = setAspectRatio(viewFrame: containerView.frame, imageWidth: imageView.frame.width, imageHeight: imageView.frame.height)
        
        var x = CGFloat()
        if scrollView.frame.height > scrollView.frame.width {
            x = (imageView.frame.width - containerView.frame.width) / 2
            scrollView.contentInset = UIEdgeInsets(top: 0, left: x, bottom: 0, right: x)
        } else {
            x = (imageView.frame.height - containerView.frame.height) / 2
            scrollView.contentInset = UIEdgeInsets(top: x, left: 0, bottom: x, right: 0)
        }
       
        if byCallMethod != "" {
            contentInsetLeftConts.append(x)
        } else {
            contentInsetLeftConts.insert(x, at: tag)
        }
    }
    
    @objc private func closeSelf() {
        if isHaveEditedPhotos {
            let vc = PhotoPrintCancelPopup.with()
            vc.openWithBlur()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func navigationBackFromPopup(){
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc private func addButtonTapped(sender: UIButton) {
        let view = getView(tag: sender.tag, layerName: Subviews.addDeleteContainer.layerName)
        let countLabel = view.subviews[1] as? UILabel
        
        if totalPhotoCount() < maxSelectablePhoto {
            let count = Int(countLabel?.text ?? "0") ?? 0
            if count < maxSelectablePhoto {
                countLabel?.text = String((count) + 1)
            }
            addRemoveContentContainerView(isAdd: totalPhotoCount() != maxSelectablePhoto, photoCount: totalPhotoCount())
            nextButtonEnabled()
        }
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
            if self.selectedPhotos.count > 1 {
                let viewInStack = self.stackMainView.arrangedSubviews[sender.tag]
                self.stackMainView.removeArrangedSubview(viewInStack)
                viewInStack.removeFromSuperview()
                self.selectedPhotos.remove(at: sender.tag)
                self.imageSizeArray.remove(at: sender.tag)
                self.contentInsetLeftConts.remove(at: sender.tag)
                self.setViewTag()
                isContentCheckBoxChecked = false
                contentCheckButton.isSelected = isContentCheckBoxChecked
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        nextButtonEnabled()
        addRemoveContentContainerView(isAdd: totalPhotoCount() != maxSelectablePhoto, photoCount: totalPhotoCount())
        setCountTitleLabel()
    }
    
    @objc private func checkButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let view = getView(tag: sender.tag, layerName: Subviews.checkButton.layerName)
        let button = view as? UIButton
        sender.isSelected ? button?.setImage(Image.iconPrintSelectBlue.image, for: .normal) : button?.setImage(Image.iconPrintSelectEmpty.image, for: .normal)
        let newPhotosButton = getView(tag: sender.tag, layerName: Subviews.newPhotoLabel.layerName)
        newPhotosButton.isUserInteractionEnabled = !sender.isSelected
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
        
        showSpinner()
        if let imageUrl = selectedPhotos[sender.tag].metadata?.largeUrl {
            let imageView = getView(tag: sender.tag, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0].subviews[0] as! UIImageView
            imageView.sd_setImage(with: imageUrl) { [weak self] (image, error, cache, url) in
                if error != nil {
                    self?.hideSpinner()
                    UIApplication.showErrorAlert(message: error?.localizedDescription ?? "", closed: {
                    })
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.hideSpinner()
                        self?.contentInsetLeftConts.remove(at: sender.tag)
                        self?.setImageViewDetail(tag: sender.tag)
                    }
                }
            }
        }
        setViewTag()
    }
    
    private func setAspectRatio(viewFrame: CGRect, imageWidth: CGFloat, imageHeight: CGFloat) -> CGRect {
        var returnFrame: CGRect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let aspectRatio1 = viewFrame.width / imageWidth
        let aspectRatio2 = viewFrame.height / imageHeight
        
        if aspectRatio1 >= aspectRatio2 {
            returnFrame = CGRect(x: 0, y: 0, width: imageWidth * aspectRatio1, height: imageHeight * aspectRatio1)
        } else {
            returnFrame = CGRect(x: 0, y: 0, width: imageWidth * aspectRatio2, height: imageHeight * aspectRatio2)
        }
        return returnFrame
    }
    
    @objc private func newPhotoSelectTapped(_ sender: AnyObject) {
        photoSelectType = .changePhotoSelection
        isContentCheckBoxChecked = false
        contentCheckButton.isSelected = isContentCheckBoxChecked
        selectedPhotoIndex = sender.view!.tag
        imageSizeArray.remove(at: sender.view!.tag)
        contentInsetLeftConts.remove(at: sender.view!.tag)
        router.openSelectPhotosWithChange(selectedPhotos: selectedPhotos, popupShowing: false)
    }
    
    @objc private func contentCheckButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.isSelected ? contentCheckButton.setImage(Image.iconPrintSelectBlue.image, for: .normal) : contentCheckButton.setImage(Image.iconPrintSelectEmpty.image, for: .normal)
        isContentCheckBoxChecked = sender.isSelected
        nextButtonEnabled()
    }
    
    @objc private func nextButtonTapped(sender: UIButton) {
        showSpinner()
        let service = PhotoPrintService()
        service.photoPrintMyAddress() { [weak self] result in
            switch result {
            case .success(let response):
                self?.hideSpinner()
                let vc = PhotoPrintSendPopup.with(address: response.first, editedImages: self?.getEditedImages() ?? [])
                vc.openWithBlur()
            case .failed(_):
                self?.hideSpinner()
                break
            }
        }
    }
    
    private func getEditedImages() -> [UIImage] {
        editedImages.removeAll()
        let subView = stackMainView.arrangedSubviews
        for (index, element) in subView.enumerated() {
            if element.layer.name == Subviews.containerView.layerName {
                let contentView = getView(tag: index, layerName: Subviews.imageContainerView.layerName).subviews[0]
                let image: UIImage = takeScreenshot(of: contentView)
                let countLabel = getView(tag: index, layerName: Subviews.addDeleteContainer.layerName).subviews[1] as? UILabel
                let count = Int(countLabel?.text ?? "0") ?? 0
                for _ in 0...count - 1 {
                    editedImages.append(image)
                }
            }
        }
        return editedImages
    }
    
    private func setImageReplace(tag: Int, image: UIImage) {
        let isPortrait = getIsPortraitOrLandscape(image: image)
        let portraitHeightConstant = (view.frame.width) / 0.664
        let landscapeHeightConstant = (view.frame.width) / 1.506
        
        let view = getView(tag: tag, layerName: Subviews.imageContainerView.layerName)
        let rotateButton = getView(tag: tag, layerName: Subviews.rotateButton.layerName)
        (rotateButton as? UIButton)?.isSelected = isPortrait ? true : false
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
        let imageContainerView = getView(tag: tag, layerName: Subviews.imageContainerView.layerName)
        
        if !isImageSizeControl(selectedPhotosIndex: tag) {
            (infoLabel as? UILabel)?.text = String(format: localized(.printPhotoBadQualityInfo), Int(badQuailtySize))
            (infoLabel as? UILabel)?.textColor = AppColor.forgetPassTextRed.color
            (infoIcon as? UIImageView)?.image = Image.iconPrintInfoRed.image
            infoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = false
            checkButton.isHidden = false
            checkLabel.isHidden = false
            newPhotoIcon.isHidden = false
            newPhotoLabel.isHidden = false
            (imageContainerView as? UIView)?.layer.borderColor = AppColor.forgetPassTextRed.cgColor
        } else {
            (infoLabel as? UILabel)?.text = localized(.printEditPhotoPageName)
            (infoLabel as? UILabel)?.textColor = AppColor.darkBlue.color
            (infoIcon as? UIImageView)?.image = Image.iconInfo.image
            (imageContainerView as? UIView)?.layer.borderColor = AppColor.tealBlue.cgColor
            infoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
            checkButton.isHidden = true
            checkLabel.isHidden = true
            newPhotoIcon.isHidden = true
            newPhotoLabel.isHidden = true
        }
    }
    
    private func isImageSizeControl(selectedPhotosIndex: Int) -> Bool {
        var selectedPhotosForControl = [SearchItemResponse]()
        var itemIndex: Int = selectedPhotosIndex
        switch photoSelectType {
        case .newPhotoSelection:
            selectedPhotosForControl = selectedPhotos
        case .changePhotoSelection:
            if PhotoPrintConstants.selectedChangePhotoItems.isEmpty {
                selectedPhotosForControl = selectedPhotos
            } else {
                selectedPhotosForControl = PhotoPrintConstants.selectedChangePhotoItems
                itemIndex = 0
            }
        }
        
        guard let photoSize = selectedPhotosForControl[itemIndex].bytes else { return false }
        var control: Bool = false
        control = Double(photoSize) / 1024 / 1024 > CGFloat(badQuailtySize) ? true : false
        return control
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
        if !getLowQualityPhotosCount() {
            nextButton.backgroundColor = AppColor.borderLightGray.color
            nextButton.isUserInteractionEnabled = false
        } else {
            if !contentViewIsHaveCheckBox {
                nextButton.backgroundColor = AppColor.darkBlueColor.color
                nextButton.isUserInteractionEnabled = true
            } else if contentViewIsHaveCheckBox && isContentCheckBoxChecked {
                nextButton.backgroundColor = AppColor.darkBlueColor.color
                nextButton.isUserInteractionEnabled = true
            } else if contentViewIsHaveCheckBox && !isContentCheckBoxChecked {
                nextButton.backgroundColor = AppColor.borderLightGray.color
                nextButton.isUserInteractionEnabled = false
            } else if !contentViewIsHaveCheckBox && !isContentCheckBoxChecked {
                nextButton.backgroundColor = AppColor.darkBlueColor.color
                nextButton.isUserInteractionEnabled = true
            }
        }
    }
    
    private func getLowQualityPhotosCount() -> Bool {
        var isHaveLowQuality: Bool = true
        let subView = stackMainView.arrangedSubviews
        for (index, element) in subView.enumerated() {
            if element.layer.name == Subviews.containerView.layerName {
                let checkButton = getView(tag: index, layerName: Subviews.checkButton.layerName) as? UIButton
                if checkButton?.isHidden == false && checkButton?.isSelected == false {
                    isHaveLowQuality = false
                }
            }
        }
        return isHaveLowQuality
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
            getView(tag: index, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0].subviews[0].tag = index
            getView(tag: index, layerName: Subviews.infoIcon.layerName).tag = index
            getView(tag: index, layerName: Subviews.infoLabel.layerName).tag = index
            getView(tag: index, layerName: Subviews.checkButton.layerName).tag = index
            getView(tag: index, layerName: Subviews.checkLabel.layerName).tag = index
            getView(tag: index, layerName: Subviews.newPhotoIcon.layerName).tag = index
            getView(tag: index, layerName: Subviews.newPhotoLabel.layerName).tag = index
            getView(tag: index, layerName: Subviews.contentContainerView.layerName).tag = index
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
    
    private func setCountTitleLabel() {
        let subView = stackMainView.arrangedSubviews
        for (index, element) in subView.enumerated() {
            if element.layer.name == Subviews.containerView.layerName {
                let label = getView(tag: index, layerName: Subviews.countTitleLabel.layerName) as? UILabel
                label?.text = String(index+1)
            }
        }
    }
    
    private func setTitleLabel(tag: Int, name: String) {
        let subView = stackMainView.arrangedSubviews
        let label = getView(tag: tag, layerName: Subviews.titleLabel.layerName) as? UILabel
        label?.text = name
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
            
            nextButton.backgroundColor = AppColor.borderLightGray.color
            nextButton.isUserInteractionEnabled = false
            contentCheckButton.setImage(Image.iconPrintSelectEmpty.image, for: .normal)
            photoCount < maxSelectablePhoto ? contentCheckButton.setImage(Image.iconPrintSelectEmpty.image, for: .normal) : contentCheckButton.setImage(Image.iconPrintInfoRed.image, for: .normal)
            contentCheckLabel.text = photoCount < maxSelectablePhoto ? String(format: localized(.morePhotoRight), maxSelectablePhoto - photoCount) : String(format: localized(.noMorePhotoRight), maxSelectablePhoto)
            contentCheckLabel.textColor = photoCount < maxSelectablePhoto ? AppColor.label.color : AppColor.forgetPassTextRed.color
            contentViewIsHaveCheckBox = true
            isContentCheckBoxChecked = false
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
    
    func takeScreenshot(of view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: view.frame.width, height: view.frame.height),
            false,
            2
        )
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return screenshot
    }
}

extension PhotoPrintViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let imageContainerView = getView(tag: scrollView.tag, layerName: Subviews.imageContainerView.layerName)
        isHaveEditedPhotos = true
        
        if isImageSizeControl(selectedPhotosIndex: scrollView.tag) {
            imageContainerView.layer.borderColor = AppColor.forgetPassTextGreen.cgColor
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        let imageView = getView(tag: scrollView.tag, layerName: Subviews.imageContainerView.layerName).subviews[0].subviews[0].subviews[0] as! UIImageView
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        let x = contentInsetLeftConts[scrollView.tag]
//        scrollView.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: x * scale)
        
        if scrollView.frame.height > scrollView.frame.width {
            let x = contentInsetLeftConts[scrollView.tag]
            scrollView.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: x * scale)
        } else {
            let x = contentInsetLeftConts[scrollView.tag]
            scrollView.contentInset = UIEdgeInsets(topBottom: x * scale, rightLeft: 0)
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
            view.layer.borderColor = AppColor.tealBlue.cgColor
            view.layer.name = Subviews.imageContainerView.layerName
            return view
        }()
        
        lazy var imageContentView: UIView = {
            let view = UIView()
            view.layer.name = "imageContentView"
            view.tag = index
            return view
        }()
        
        lazy var printScrollView: UIScrollView = {
            let view = UIScrollView()
            view.layer.cornerRadius = 8
            view.showsVerticalScrollIndicator = false
            view.showsHorizontalScrollIndicator = false
            view.layer.name = "printScrollView"
            view.tag = index
            view.delegate = self
            view.minimumZoomScale = 1.0
            view.maximumZoomScale = 4.0
            return view
        }()
        
        lazy var printImageView: UIImageView = {
            let view = UIImageView()
            view.isUserInteractionEnabled = true
            view.layer.cornerRadius = 8
            view.contentMode = .scaleAspectFill
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
            view.isHidden = true
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
        
        lazy var seperatorLabel: UILabel = {
            let view = UILabel()
            view.backgroundColor = AppColor.borderLightGray.color
            return view
        }()
        
        containerView.addSubview(countTitleLabel)
        countTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        countTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        countTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8).isActive = true
        countTitleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        countTitleLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        
        
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
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: countTitleLabel.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: countTitleLabel.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: countTitleLabel.trailingAnchor, constant: 8).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: rotateButton.leadingAnchor, constant: -8).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let heightConstant = (view.frame.width) / 1.506
        
        containerView.addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.topAnchor.constraint(equalTo: countTitleLabel.bottomAnchor, constant: 16).isActive = true
        imageContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        imageContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        imageContainerView.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        
        imageContainerView.addSubview(imageContentView)
        imageContentView.translatesAutoresizingMaskIntoConstraints = false
        imageContentView.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: 10).isActive = true
        imageContentView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: -10).isActive = true
        imageContentView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor, constant: 10).isActive = true
        imageContentView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: -10).isActive = true
        
        imageContentView.addSubview(printScrollView)
        printScrollView.translatesAutoresizingMaskIntoConstraints = false
        printScrollView.topAnchor.constraint(equalTo: imageContentView.topAnchor, constant: -2).isActive = true
        printScrollView.bottomAnchor.constraint(equalTo: imageContentView.bottomAnchor, constant: 2).isActive = true
        printScrollView.leadingAnchor.constraint(equalTo: imageContentView.leadingAnchor, constant: -2).isActive = true
        printScrollView.trailingAnchor.constraint(equalTo: imageContentView.trailingAnchor, constant: 2).isActive = true
        
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
        
        containerView.addSubview(seperatorLabel)
        seperatorLabel.translatesAutoresizingMaskIntoConstraints = false
        seperatorLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 15).isActive = true
        seperatorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -8).isActive = true
        seperatorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8).isActive = true
        seperatorLabel.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
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
