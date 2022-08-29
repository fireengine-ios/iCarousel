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
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.switcherGrayColor
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.backgroundColor = .clear
            newValue.numberOfLines = 0
            newValue.text = TextConstants.myPackagesDescription
        }
    }
    
    @IBOutlet private weak var packagesStackView: UIStackView! {
        willSet {
            newValue.spacing = 16
        }
    }

    @IBOutlet private weak var scrollView: ControlContainableScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var packagesLabel: UILabel! {
        willSet {
            newValue.adjustsFontSizeToFitWidth()
            newValue.text = TextConstants.packagesIHave
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
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
            newValue.setTitleColor(.lrBrownishGrey, for: .normal)
            newValue.setBackgroundColor(AppColor.secondaryBackground.color, for: UIControl.State())
            newValue.titleLabel?.font = .TurkcellSaturaBolFont(size: 16)
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = UIColor.lrTealishTwo.cgColor
        }
    }
        
    lazy var myPackages: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    lazy var packages: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    lazy var subtitleLabel: UILabel = {
       let view = UILabel()
        view.textColor = ColorConstants.darkText
        view.text = TextConstants.packageSectionTitle
        view.font = UIFont.TurkcellSaturaBolFont(size: 18)
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
    
    private var menuViewModels = [ControlPackageType]()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        output.viewDidLoad()
        
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
        
        packagesStackView.addArrangedSubview(myPackages)
        packagesStackView.addArrangedSubview(packages)
        packagesStackView.addArrangedSubview(policyStackView)
        policyStackView.addArrangedSubview(policyView)
    }
        
    @IBAction private func restorePurhases() {
        startActivityIndicator()
        output.restorePurchasesPressed()
    }
}

// MARK: - MyStorageViewInput
extension MyStorageViewController: MyStorageViewInput {
    
    func reloadPackages() {
        myPackages.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for offer in output.displayableOffers.enumerated() {
            let view = SubscriptionOfferView.initFromNib()
            let packageOffer = PackageOffer(quotaNumber: .zero, offers: [offer.element])
            view.configure(with: packageOffer, delegate: self, index: offer.offset, needHidePurchaseInfo: false)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            myPackages.addArrangedSubview(view)
        }
    }
    
    func reloadData() {
        packages.arrangedSubviews.forEach { $0.removeFromSuperview() }
        packages.addArrangedSubview(subtitleLabel)
        for offer in output.availableOffers.enumerated() {
            let view = SubscriptionOfferView.initFromNib()
            view.configure(with: offer.element, delegate: self, index: offer.offset)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            packages.addArrangedSubview(view)
        }
    }
    
    func showRestoreButton() {
        restorePurchasesButton.isEnabled = true
        restorePurchasesButton.isHidden = false
    }

    
    func showInAppPolicy() {
        policyStackView.addArrangedSubview(policyView)
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

// MARK: - ActivityIndicator
extension MyStorageViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }

    func stopActivityIndicator() {
        activityManager.stop()
    }
}
