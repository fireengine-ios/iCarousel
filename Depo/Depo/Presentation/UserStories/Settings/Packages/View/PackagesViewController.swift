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
    
    @IBOutlet weak private var cardsTableView: UITableView! {
        willSet {
            newValue.delaysContentTouches = true
            newValue.rowHeight = UITableView.automaticDimension
            newValue.register(nibCell: PackagesTableViewCell.self)
            newValue.tableFooterView = UIView()
            newValue.isScrollEnabled = false
        }
    }
    
    @IBOutlet weak private var collectionStackView: UIStackView! {
        willSet {
            newValue.spacing = 16
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak private var scrollView: ControlContainableScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkText
            newValue.text = TextConstants.packageSectionTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak private var cardsStackView: UIStackView!
    @IBOutlet weak private var promoView: PromoView!
    @IBOutlet weak private var policyStackView: UIStackView!
    
    @IBOutlet var keyboardHideManager: KeyboardHideManager!
    
    private lazy var activityManager = ActivityIndicatorManager()
    private lazy var policyView = SubscriptionsPolicyView()
    
    private let policyHeaderSize: CGFloat = Device.isIpad ? 15 : 13
    private let policyTextSize: CGFloat = Device.isIpad ? 13 : 10
    
    private var menuViewModels: [ControlPackageType] = [.myProfile, .usage(percentage: 0), .myStorage(nil)]
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        setTitle(withString: TextConstants.accountDetails)
        
        promoView.deleagte = self
        activityManager.delegate = self
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
        self.view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        output.viewIsReady()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewWillAppear()
    }
    
    func showRestoreButton() {
        //IF THE USER NON CELL USER
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "refresh_icon"), style: .plain, target: self, action: #selector(restorePurhases))
        moreButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = moreButton
    }
    
    func showInAppPolicy() {
        policyStackView.addArrangedSubview(policyView)
    }
    
    @objc private func restorePurhases() {
        startActivityIndicator()
        output.restorePurchasesPressed()
    }
}

// MARK: PackagesViewInput
extension PackagesViewController: PackagesViewInput {
    
    func reloadData() {
        collectionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
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
    
    func setupStackView(with percentage: CGFloat) {
        menuViewModels.removeAll()
        cardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        ///my profile card
        addNewCard(type: .myProfile)
        
        ///my usage card
        addNewCard(type: .usage(percentage: percentage))
        
        ///my storage card
        let isMiddleUser = AuthoritySingleton.shared.accountType.isMiddle
        let isPremiumUser = AuthoritySingleton.shared.accountType.isPremium
        let type: ControlPackageType.AccountType = isPremiumUser ? .premium : (isMiddleUser ? .middle : .standard)
        addNewCard(type: .myStorage(type))
        
        cardsTableView.reloadData()
    }
    
    private func addNewCard(type: ControlPackageType) {
        if Device.isIpad {
            let card = PackageInfoView.initFromNib()
            card.configure(with: type)
            
            output.configureCard(card)
            cardsStackView.addArrangedSubview(card)
        } else {
            menuViewModels.append(type)
        }
    }
}

// MARK: SubscriptionPlanCellDelegate
extension PackagesViewController: SubscriptionOfferViewDelegate {
    
    func didPressSubscriptionPlanButton(planIndex: Int) {
        let plan = output.availableOffers[planIndex]
        presentPaymentPopUp(plan: plan, planIndex: planIndex)
    }
    
    private func presentPaymentPopUp(plan: PackageOffer, planIndex: Int) {
        guard let offer = plan.offers.first else {
            assertionFailure()
            return
        }
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackageClick(packageName: offer.name))
        
        let paymentMethods: [PaymentMethod] = plan.offers.compactMap { offer in
            if let model = offer.model as? PackageModelResponse {
                return createPaymentMethod(model: model, priceString: offer.price, offer: plan, planIndex: planIndex)
            } else {
                return nil
            }
        }
        
        let titles = createTitlesForPopUp(offer: offer)
        let showableMethods = prepareShowableMethods(with: paymentMethods)

        let paymentModel = PaymentModel(name: titles.title, subtitle: titles.subtitle, types: showableMethods)
        let popup = PaymentPopUpController.controllerWith(paymentModel)
        present(popup, animated: false, completion: nil)
    }

    private func prepareShowableMethods(with methods: [PaymentMethod]) -> [PaymentMethod] {
        var showableMethods: [PaymentMethod] = []

        let paycellMethods = methods.filter {$0.type == .paycell}.min { $0.price < $1.price }
        let appStoreMethods = methods.filter {$0.type == .appStore}.min { $0.price < $1.price }
        let slcmMethods = methods.filter {$0.type == .slcm}.min { $0.price < $1.price }

        showableMethods.append(paycellMethods)
        showableMethods.append(appStoreMethods)
        showableMethods.append(slcmMethods)

        return showableMethods.sorted { $0.price < $1.price }
    }
    
    private func createPaymentMethod(model: PackageModelResponse, priceString: String, offer: PackageOffer, planIndex: Int) -> PaymentMethod? {
        guard let name = model.name, let type = model.type, let price = model.price else {
            return nil
        }
        
        let paymentType = type.paymentType
        return PaymentMethod(name: name, price: price, priceLabel: priceString, type: paymentType, action: { [weak self] in
            guard let subscriptionPlan = self?.getChoosenSubscriptionPlan(availableOffers: offer, packageType: type) else {
                assertionFailure()
                return
            }
            
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackageChannelClick(channelType: paymentType, packageName: subscriptionPlan.name))
            
            let analyticsService: AnalyticsService = factory.resolve()
            
            let eventLabel: GAEventLabel = .paymentType(paymentType.quotaPaymentType(quota: subscriptionPlan.name))
            analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                eventActions: .clickQuotaPurchase,
                                                eventLabel: eventLabel)
            
            self?.output.didPressOn(plan: subscriptionPlan, planIndex: planIndex)
        })
        
    }
    
    private func getChoosenSubscriptionPlan(availableOffers: PackageOffer, packageType: PackageContentType) -> SubscriptionPlan?  {
        return availableOffers.offers.first(where: { ($0.model as? PackageModelResponse)?.type == packageType })
    }
    
    private func createTitlesForPopUp(offer: SubscriptionPlan) -> (title: String, subtitle: String) {
        if offer.addonType == .featureOnly {
            return (title: TextConstants.lifeboxPremium, subtitle: TextConstants.feature)
        } else {
            return (title: offer.name, subtitle: TextConstants.storage)
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
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == TextConstants.NotLocalized.termsOfUseLink {
            DispatchQueue.toMain {
                self.output.openTermsOfUseScreen()
            }
            return false
        }
        return defaultHandle(url: URL, interaction: interaction)
    }
}

// MARK: - UITableViewDataSource
extension PackagesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeue(reusable: PackagesTableViewCell.self)
    }
}

// MARK: - UITableViewDelegate
extension PackagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        guard let item = menuViewModels[safe: indexPath.row] else {
            return
        }
        
        let cell = cell as? PackagesTableViewCell
        cell?.configure(type: item)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = menuViewModels[safe: indexPath.row] else {
            return
        }
        
        let delegate = output as? PackageInfoViewDelegate
        delegate?.onSeeDetailsTap(with: item)
    }
}
