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
    
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var cardsStackView: UIStackView!

    @IBOutlet weak private var collectionStackView: UIStackView! {
        willSet {
            newValue.spacing = 16
        }
    }
    
    @IBOutlet weak private var promoView: PromoView!
    @IBOutlet var keyboardHideManager: KeyboardHideManager!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var policyTextView: UITextView!
    
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
        
        policyTextView.text = ""
        setTitle(withString: TextConstants.accountDetails)
        descriptionLabel.text = TextConstants.descriptionLabelText

        promoView.deleagte = self
        activityManager.delegate = self
        
        output.viewIsReady()
        
        MenloworksAppEvents.onPackagesOpen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        output.viewWillAppear()
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
        
        let policyText = RouteRequests.isBillo ? TextConstants.packagesPolicyBilloText : TextConstants.packagesPolicyText
        
        let policyAttributedString = NSMutableAttributedString(
            string: "\n\n" + policyText,
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

    func reloadData() {
        collectionStackView.arrangedSubviews.forEach { collectionStackView.removeArrangedSubview($0) }
        for offer in output.availableOffers.enumerated() {
            let view = SubscriptionOfferView.initFromNib()
            view.configure(with: offer.element, delegate: self, index: offer.offset)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            collectionStackView.addArrangedSubview(view)
        }
    }
    
    func successedPromocode() {
        stopActivityIndicator()
        UIApplication.showSuccessAlert(message: TextConstants.promocodeSuccess)
        
        promoView.endEditing(true)
        promoView.codeTextField.text = ""
        promoView.errorLabel.text = ""
        reloadData()
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

    func showPaycellProcess(with cpcmOfferId: Int) {
        let controller = PaycellViewController.create(with: cpcmOfferId) { result in
            switch result {
            case .success():
                UIApplication.showSuccessAlert(message: TextConstants.successfullyPurchased)
            case .failed(_):
                UIApplication.showErrorAlert(message: TextConstants.errorUnknown)
            }
        }
        RouterVC().pushViewController(viewController: controller)
    }

    func setupStackView(with percentage: CGFloat) {
        for view in cardsStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        ///premium banner if needed
        let isPremiumUser = AuthoritySingleton.shared.accountType.isPremium
        if !isPremiumUser {
            addNewCard(type: .premiumBanner)
        }
        
        ///my profile card
        addNewCard(type: .myProfile)

        ///account type card
        let isMiddleUser = AuthoritySingleton.shared.accountType.isMiddle
        let type: ControlPackageType.AccountType = isPremiumUser ? .premium : (isMiddleUser ? .middle : .standard)

        addNewCard(type: .accountType(type))

        ///my storage card
        addNewCard(type: .myStorage, percentage: percentage)
    }
    
    private func addNewCard(type: ControlPackageType, percentage: CGFloat? = nil) {
        let card = PackageInfoView.initFromNib()
        card.configure(with: type, percentage: percentage)

        output.configureCard(card)
        cardsStackView.addArrangedSubview(card)
    }
}

// MARK: SubscriptionPlanCellDelegate
extension PackagesViewController: SubscriptionOfferViewDelegate {
    
    func didPressSubscriptionPlanButton(planIndex: Int) {
        let plan = output.availableOffers[planIndex]
        presentPaymentPopUp(plan: plan, planIndex: planIndex)
    }
    
    private func presentPaymentPopUp(plan: PackageOffer, planIndex: Int) {
        guard let name = plan.offers.first?.name else {
            assertionFailure()
            return
        }
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackageClick(packageName: name))
        
        let paymentMethods: [PaymentMethod] = plan.offers.compactMap { offer in
            if let model = offer.model as? PackageModelResponse {
                return createPaymentMethod(model: model, priceString: offer.priceString, offer: plan, planIndex: planIndex)
            } else {
                return nil
            }
        }
        
        let subtitle = TextConstants.storage
        let paymentModel = PaymentModel(name: name, subtitle: subtitle, types: paymentMethods)
        let popup = PaymentPopUpController.controllerWith(paymentModel)
        present(popup, animated: false, completion: nil)
    }
    
    private func createPaymentMethod(model: PackageModelResponse, priceString: String, offer: PackageOffer, planIndex: Int) -> PaymentMethod? {
        
        guard let name = model.name, let packageType = model.type else {
            return nil
        }
        
        let paymentType = packageType.paymentType
        
        return PaymentMethod(name: name, priceLabel: priceString, type: paymentType, action: { [weak self] in
            guard let subscriptionPlan = self?.getChoosenSubscriptionPlan(availableOffers: offer, packageType: packageType) else {
                assertionFailure()
                return
            }
            
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackageChannelClick(channelType: paymentType, packageName: subscriptionPlan.name))
            
            if let tag = MenloworksSubscriptionStorage(rawValue: subscriptionPlan.name) {
                MenloworksAppEvents.onSubscriptionClicked(tag)
            }
            
            let analyticsService: AnalyticsService = factory.resolve()
            
            let eventLabel: GAEventLabel = .paymentType(paymentType.quotaPaymentType(quota: subscriptionPlan.name))
            analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                eventActions: .clickQuotaPurchase,
                                                eventLabel: eventLabel)
            
            self?.output.didPressOn(plan: subscriptionPlan, planIndex: planIndex)
         
        })
        
    }
    
    private func getChoosenSubscriptionPlan(availableOffers: PackageOffer, packageType: PackageType ) -> SubscriptionPlan?  {
        
        return availableOffers.offers.first { plan -> Bool in
            guard let model = plan.model as? PackageModelResponse else {
                return false
            }
            return model.type == packageType
        }
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
