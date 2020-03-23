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
    
    //MARK: IBOutlet
    @IBOutlet private weak var menuTableView: ResizableTableView! {
        willSet {
            newValue.rowHeight = 51
            let nib = UINib(nibName: String(describing: PackagesTableViewCell.self), bundle: nil)
            let identifier = String(describing: PackagesTableViewCell.self)
            newValue.register(nib, forCellReuseIdentifier: identifier)
            newValue.isScrollEnabled = false
        }
    }
    
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

    @IBOutlet private weak var scrollView: UIScrollView!
    
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
            newValue.setBackgroundColor(.white, for: UIControl.State())
            newValue.titleLabel?.font = .TurkcellSaturaBolFont(size: 16)
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = UIColor.lrTealishTwo.cgColor
        }
    }
    
    @IBOutlet weak var cardStackView: UIStackView!
    
    private var menuViewModels = [ControlPackageType]()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
        setup()
        output.viewDidLoad()
    }
    
    // MARK: Utility Methods (private)
    private func setup() {
        setTitle(withString: output.title)
        self.view.backgroundColor = ColorConstants.fileGreedCellColor
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        activityManager.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
        
    @IBAction private func restorePurhases() {
        startActivityIndicator()
        output.restorePurchasesPressed()
    }
}

// MARK: - MyStorageViewInput
extension MyStorageViewController: MyStorageViewInput {
    func reloadPackages() {
        packagesStackView.arrangedSubviews.forEach { packagesStackView.removeArrangedSubview($0) }
        for offer in output.displayableOffers.enumerated() {
            let view = SubscriptionOfferView.initFromNib()
            let packageOffer = PackageOffer(quotaNumber: .zero, offers: [offer.element])
            view.configure(with: packageOffer, delegate: self, index: offer.offset, needHidePurchaseInfo: false)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            packagesStackView.addArrangedSubview(view)
        }
    }
    
    func showRestoreButton() {
        restorePurchasesButton.isEnabled = true
        restorePurchasesButton.isHidden = false
    }
    
    func setupStackView() {
        menuViewModels.removeAll()
        for view in cardStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        let isMiddleUser = AuthoritySingleton.shared.accountType.isMiddle
        let isPremiumUser = AuthoritySingleton.shared.accountType.isPremium
        let type: ControlPackageType.AccountType = isPremiumUser ? .premium : (isMiddleUser ? .middle : .standard)
        addNewCard(type: .accountType(type))
        self.menuTableView.reloadData()
    }
    
    private func addNewCard(type: ControlPackageType) {
        if Device.isIpad {
            let card = PackageInfoView.initFromNib()
            card.configure(with: type)
            
            output.configureCard(card)
            cardStackView.addArrangedSubview(card)
        } else {
            menuViewModels.append(type)
        }
    }
}

// MARK: - SubscriptionOfferViewDelegate
extension MyStorageViewController: SubscriptionOfferViewDelegate {
    func didPressSubscriptionPlanButton(planIndex: Int) {
        guard let plan = output?.displayableOffers[planIndex] else {
            return
        }
        output?.didPressOn(plan: plan, planIndex: planIndex)
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = menuViewModels[safe: indexPath.row] else {
            return
        }
        (output as? PackageInfoViewDelegate)?.onSeeDetailsTap(with: type)
    }
}
