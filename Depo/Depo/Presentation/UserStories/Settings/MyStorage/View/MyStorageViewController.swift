//
//  MyStorageViewController.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class MyStorageViewController: BaseViewController {
    
    //MARK: Properties
    var output: MyStorageViewOutput!
    private lazy var activityManager = ActivityIndicatorManager()

    @IBOutlet weak var menuTableView: ResizableTableView! {
        willSet {
            newValue.rowHeight = 65
            let nib = UINib(nibName: String(describing: PackagesTableViewCell.self), bundle: nil)
            let identifier = String(describing: PackagesTableViewCell.self)
            newValue.register(nib, forCellReuseIdentifier: identifier)
            newValue.separatorStyle = .none
            newValue.isScrollEnabled = false
            
            newValue.layer.cornerRadius = 16
            newValue.layer.borderColor = AppColor.settingsPackagesCell.cgColor
            newValue.layer.borderWidth = 1
            newValue.backgroundColor = AppColor.settingsPackagesCell.color
            setupShadow(view: newValue)
        }
    }
    
    
    @IBOutlet private weak var scrollView: ControlContainableScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
        
    @IBOutlet private weak var restorePurchasesButton: RoundedInsetsButton! {
        willSet {
            newValue.isHidden = true
            newValue.isEnabled = false
            newValue.clipsToBounds = true
            newValue.adjustsFontSizeToFitWidth()
            newValue.insets = UIEdgeInsets(topBottom: 8, rightLeft: 12)
            newValue.setTitle(TextConstants.restorePurchasesButton, for: .normal)
            newValue.setTitleColor(AppColor.settingsRestoreTextColor.color, for: .normal)
            newValue.backgroundColor = .white
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.settingsRestoreTextColor.cgColor
            newValue.layer.cornerRadius = 23
        }
    }
    
    @IBOutlet private weak var packagesStackView: UIStackView! {
        willSet {
            newValue.spacing = 24
        }
    }
    
    @IBOutlet weak var cardsStackView: UIStackView!
    
    lazy var myPackages: UIStackView = {
        let view = UIStackView()
        view.spacing = 16
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 16
        view.layer.borderColor = AppColor.settingsMyPackages.cgColor
        view.backgroundColor = AppColor.settingsMyPackages.color
        return view
    }()
    
    lazy var packages: UIStackView = {
        let view = UIStackView()
        view.spacing = 16
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 16
        view.layer.borderColor = AppColor.settingsPackages.cgColor
        view.backgroundColor = AppColor.settingsPackages.color
        return view
    }()
    
    lazy var packagesTitleLabel: UILabel = {
       let view = UILabel()
        view.textColor = AppColor.settingsRestoreTextColor.color
        view.text = TextConstants.packageSectionTitle
        view.font = .appFont(.medium, size: 14)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var myPackagesTitleLabel: UILabel = {
       let view = UILabel()
        view.textColor = ColorConstants.darkText
        view.text = TextConstants.myPackages
        view.font = .appFont(.medium, size: 14)
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var policyStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private lazy var policyView = SubscriptionsPolicyView()
    private lazy var bannerView = PackagesBannerBuyPremiumView()
    
    private var menuViewModels = [ControlPackageType]()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        output.viewDidLoad()
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        bannerView.delegate = self
        
        setupCardStackView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewWillAppear()
    }
    
    // MARK: Utility Methods (private)
    private func setup() {
        setTitle(withString: output.title)
        self.view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        
        activityManager.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        setupLayout()
        addPremiumBanner()
    }
    
    private func setupLayout() {
        packagesStackView.addArrangedSubview(myPackages)
        packagesStackView.addArrangedSubview(packages)
        packagesStackView.addArrangedSubview(policyStackView)
        policyStackView.addArrangedSubview(policyView)
    }
    
    private func addPremiumBanner() {
        guard !AuthoritySingleton.shared.accountType.isPremium else { return }
        
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        bannerView.heightAnchor.constraint(equalToConstant: 137).activate()
    }

    @IBAction private func restorePurhases() {
        startActivityIndicator()
        output.restorePurchasesPressed()
    }
    
    private func setupShadow(view: UIView) {
        let shadowColor = UIColor(red: 126 / 255, green: 129 / 255, blue: 133 / 255, alpha:0.4)
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 16
        view.layer.masksToBounds = false
    }
}

// MARK: - MyStorageViewInput
extension MyStorageViewController: MyStorageViewInput {
    
    func reloadPackages() {
        myPackages.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let outerTopView = UIView()
        outerTopView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        myPackages.addArrangedSubview(outerTopView)
        
        myPackages.addArrangedSubview(myPackagesTitleLabel)
        for offer in output.displayableOffers.enumerated() {
            let view = SubscriptionOfferView.initFromNib()
            let packageOffer = PackageOffer(quotaNumber: .zero, offers: [offer.element])
            view.configure(with: packageOffer, delegate: self, index: offer.offset, needHidePurchaseInfo: false)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            myPackages.addArrangedSubview(view)
            
            view.leadingAnchor.constraint(equalTo: myPackages.leadingAnchor,
                                          constant: 16).isActive = true
            view.trailingAnchor.constraint(equalTo: myPackages.trailingAnchor,
                                           constant: -16).isActive = true
        }
        let outerBottomView = UIView()
        outerBottomView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        myPackages.addArrangedSubview(outerBottomView)
    }
    
    func reloadData() {
        packages.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let outerTopView = UIView()
        outerTopView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        packages.addArrangedSubview(outerTopView)
        
        packages.addArrangedSubview(packagesTitleLabel)
        for offer in output.availableOffers.enumerated() {
            let view = SubscriptionOfferView.initFromNib()
            view.configure(with: offer.element, delegate: self, index: offer.offset)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            packages.addArrangedSubview(view)
            
            view.leadingAnchor.constraint(equalTo: packages.leadingAnchor,
                                          constant: 16).isActive = true
            view.trailingAnchor.constraint(equalTo: packages.trailingAnchor,
                                           constant: -16).isActive = true
        }
        
        let outerBottomView = UIView()
        outerBottomView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        packages.addArrangedSubview(outerBottomView)
    }
    
    func showRestoreButton() {
        restorePurchasesButton.isEnabled = true
        restorePurchasesButton.isHidden = false
    }

    
    func showInAppPolicy() {
        policyStackView.addArrangedSubview(policyView)
    }
    
    func setupCardStackView() {
        menuViewModels.removeAll()
        for view in cardsStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        let isMiddleUser = AuthoritySingleton.shared.accountType.isMiddle
        let isPremiumUser = AuthoritySingleton.shared.accountType.isPremium
        let type: ControlPackageType.AccountType = isPremiumUser ? .premium : (isMiddleUser ? .middle : .standard)
        addNewCard(type: .accountType(type))
        menuTableView.reloadData()
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

// MARK: - SubscriptionOfferViewDelegate
extension MyStorageViewController: SubscriptionOfferViewDelegate {
    func didPressSubscriptionPlanButton(planIndex: Int, storageOfferType: StorageOfferType) {
        
        switch(storageOfferType) {
        case.packageOffer:
            let plan = output.availableOffers[planIndex]
            presentPaymentPopUp(plan: plan, planIndex: planIndex)
        case.subscriptionPlan:
  
            guard let plan = output?.displayableOffers[planIndex] else {
                return
            }
            output?.didPressOn(plan: plan, planIndex: planIndex)
        }
    }
    
    private func presentPaymentPopUp(plan: PackageOffer, planIndex: Int) {
        guard let offer = plan.offers.first else {
            assertionFailure()
            return
        }
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackageClick(packageName: offer.name))
        
        let paymentMethods: [PaymentMethod] = plan.offers.compactMap { offer in
            if let model = offer.model as? PackageModelResponse {
                return createPaymentMethod(
                    model: model,
                    priceString: offer.price,
                    introPriceString: offer.introductoryPrice,
                    offer: plan,
                    planIndex: planIndex
                )
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
    
    private func createPaymentMethod(
        model: PackageModelResponse,
        priceString: String,
        introPriceString: String?,
        offer: PackageOffer,
        planIndex: Int
    ) -> PaymentMethod? {
        guard let name = model.name, let type = model.type, let price = model.price else {
            return nil
        }
        
        let paymentType = type.paymentType
        return PaymentMethod(
            name: name,
            price: price,
            priceLabel: priceString,
            introPriceLabel: introPriceString,
            type: paymentType
        ) { [weak self] in
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
            
            self?.output.didPressOnOffers(plan: subscriptionPlan, planIndex: planIndex)
        }
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

// MARK: - UITableViewDataSource
extension MyStorageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeue(reusable: PackagesTableViewCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuViewModels.count
    }
}

// MARK: - UITableViewDelegate
extension MyStorageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        guard let item = menuViewModels[safe: indexPath.row] else {
            return
        }
        
        let cell = cell as? PackagesTableViewCell
        cell?.configure(type: item)
        
        cell?.layer.cornerRadius = 16
        cell?.contentView.backgroundColor = AppColor.settingsBackground.color
        cell?.backgroundColor = AppColor.settingsBackground.color
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = menuViewModels[safe: indexPath.row] else {
            return
        }
        (output as? PackageInfoViewDelegate)?.onSeeDetailsTap(with: type)
    }
}

// MARK: - ActivityIndicator
extension MyStorageViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }

    func stopActivityIndicator() {
        activityManager.stop()
    }
}

// MARK: - BuyPremiumBannerDelegate
extension MyStorageViewController: BuyPremiumBannerDelegate {
    func buyPremium() {
        output.showPremiumProcess()
    }
}
