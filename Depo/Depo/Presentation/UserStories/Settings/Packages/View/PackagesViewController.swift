//
//  PackagesPackagesViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class PackagesViewController: BaseViewController {
    var output: PackagesViewOutput!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak private var topStackView: UIStackView!

    @IBOutlet weak private var collectionView: ResizableCollectionView!
    @IBOutlet weak private var promoView: PromoView!
    @IBOutlet var keyboardHideManager: KeyboardHideManager!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var policyTextView: UITextView!
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = TextConstants.packageSectionTitle
        }
    }
    
    private lazy var activityManager = ActivityIndicatorManager()
    
    private let policyHeaderSize: CGFloat = Device.isIpad ? 15 : 13
    private let policyTextSize: CGFloat = Device.isIpad ? 13 : 10
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDesign()

        automaticallyAdjustsScrollViewInsets = false
        setTitle(withString: TextConstants.packages)
        activityManager.delegate = self
        promoView.deleagte = self
        setupCollectionView()
        policyTextView.text = ""
        
        output.viewIsReady()
        
        descriptionLabel.text = TextConstants.descriptionLabelText
        
        MenloworksAppEvents.onPackagesOpen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        setupStackView(with: output.getStorageCapacity())
    }
    
    private func setupCollectionView() {
        collectionView.register(nibCell: SubscriptionPlanCollectionViewCell.self)
    }

    private func setupDesign() {
        subtitleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        subtitleLabel.textColor = ColorConstants.darkText
    }

    private func setupPolicy() {
        let attributedString = NSMutableAttributedString(
            string: TextConstants.packagesPolicyHeader,
            attributes: [.foregroundColor: ColorConstants.textGrayColor,
                         .font: UIFont.TurkcellSaturaBolFont(size: policyHeaderSize)])
        
        let policyAttributedString = NSMutableAttributedString(
            string: "\n\n" + TextConstants.packagesPolicyText,
            attributes: [.foregroundColor: ColorConstants.textGrayColor,
                         .font: UIFont.TurkcellSaturaRegFont(size: policyTextSize)])
        attributedString.append(policyAttributedString)

        let termsAttributedString = NSMutableAttributedString(
            string: TextConstants.termsOfUseLinkText,
            attributes: [.link: TextConstants.NotLocalized.termsOfUseLink,
                         .font: UIFont.TurkcellSaturaRegFont(size: policyTextSize)])
        attributedString.append(termsAttributedString)
        
        policyTextView.attributedText = attributedString
        policyTextView.clipsToBounds = true
        policyTextView.layer.cornerRadius = 5
        policyTextView.layer.borderColor = ColorConstants.textLightGrayColor.cgColor
        policyTextView.layer.borderWidth = 1
        view.layoutIfNeeded()
    }

    func showRestoreButton() {
        //IF THE USER NON CELL USER
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "refresh_icon"), style: .plain, target: self, action: #selector(restorePurhases))
        moreButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = moreButton
    }
    
    func showInAppPolicy() {
        setupPolicy()
    }
    
    @objc private func restorePurhases() {
        startActivityIndicator()
        output.restorePurchasesPressed()
    }
    
}

// MARK: PackagesViewInput
extension PackagesViewController: PackagesViewInput {

    func reloadPackages() {
        collectionView.reloadData()
    }
    
    func successedPromocode() {
        stopActivityIndicator()
        UIApplication.showSuccessAlert(message: TextConstants.promocodeSuccess)
        
        promoView.endEditing(true)
        promoView.codeTextField.text = ""
        promoView.errorLabel.text = ""
        reloadPackages()
    }
    
    func show(promocodeError: String) {
        stopActivityIndicator()
        promoView.errorLabel.text = promocodeError
        view.layoutIfNeeded()
        scrollView.scrollToBottom(animated: true)
    }
    
    func display(error: ErrorResponse) {
        UIApplication.showErrorAlert(message: error.description)
    }

    func display(errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func showActivateOfferAlert(for offer: PackageModelResponse, planIndex: Int) {
        let bodyText = "\(offer.period ?? "") \(offer.price ?? 0)"
        
        let vc = DarkPopUpController.with(title: offer.displayName, message: bodyText, buttonTitle: TextConstants.purchase) { [weak self] vc in
            vc.close(animation: {
                self?.output.buy(offer: offer, planIndex: planIndex)
            })
        }
        present(vc, animated: false, completion: nil)
    }
    
    func showSubTurkcellOpenAlert(with text: String) {
        let vc = DarkPopUpController.with(title: TextConstants.offersInfo, message: text, buttonTitle: TextConstants.offersOk)
        present(vc, animated: false, completion: nil)
    }

    func setupStackView(with storageCapacity: Int64) {
        for view in topStackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        let isPremium = AuthoritySingleton.shared.isPremium

        let firstView = PackageInfoView.initFromNib()
        isPremium ?
            firstView.configure(with: .premiumUser) :
            firstView.configure(with: .standard)

        let secondView = PackageInfoView.initFromNib()
        secondView.configure(with: .myStorage, capacity: storageCapacity)

        output.configureViews([firstView, secondView])

        topStackView.addArrangedSubview(firstView)
        topStackView.addArrangedSubview(secondView)
    }
}

// MARK: UICollectionViewDataSource
extension PackagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return output.availableOffers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: SubscriptionPlanCollectionViewCell.self, for: indexPath)
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configure(with: output.availableOffers[indexPath.item], accountType: output.getAccountType())
        return cell
    }
}

// MARK: SubscriptionPlanCellDelegate
extension PackagesViewController: SubscriptionPlanCellDelegate {
    func didPressSubscriptionPlanButton(at indexPath: IndexPath) {
        let plan = output.availableOffers[indexPath.row]
        
        if let tag = MenloworksSubscriptionStorage(rawValue: plan.name) {
            MenloworksAppEvents.onSubscriptionClicked(tag)
        }
        output.didPressOn(plan: plan, planIndex: indexPath.row)
    }
}

// MARK: - ActivityIndicator
extension PackagesViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}

// MARK: - PromoViewDelegate
extension PackagesViewController: PromoViewDelegate {
    func promoView(_ promoView: PromoView, didPressApplyWithPromocode promocode: String) {
        startActivityIndicator()
        output.submit(promocode: promocode)
        keyboardHideManager.dismissKeyboard()
    }
}

// MARK: - UITextViewDelegate
extension PackagesViewController: UITextViewDelegate {
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == TextConstants.NotLocalized.termsOfUseLink {
            DispatchQueue.toMain {
                self.output.openTermsOfUseScreen()
            }
            return true
        }
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return UIApplication.shared.openURL(URL)
    }
}
