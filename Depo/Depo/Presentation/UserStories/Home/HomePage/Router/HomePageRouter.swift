//
//  HomePageHomePageRouter.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class HomePageRouter: HomePageRouterInput {
    
    private let router = RouterVC()
    weak var presenter: HomePagePresenter!
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    private let popUpService = HomePagePopUpsService.shared
    private var popUpsToPresent = [UIViewController]()
    
    private var ignoredQuotaPopUp: UIViewController?

    //MARK: Push controller
    func moveToSettingsScreen() {
        var controller: UIViewController?
        
        if Device.isIpad {
            controller = router.settingsIpad
        } else {
            controller = router.settings
        }
        
        router.pushViewController(viewController: controller!)
    }

    func moveToSyncContacts() {
        var controller: UIViewController?
        
        if Device.isIpad {
            controller = router.settingsIpad
        } else {
            controller = router.syncContacts
        }
        
        router.pushViewController(viewController: controller!)
    }
    
    func moveToAllFilesPage() {
        let allFiles = router.allFiles(moduleOutput: presenter,
                                       sortType: presenter.allFilesSortType,
                                       viewType: presenter.allFilesViewType)
        
        router.pushViewController(viewController: allFiles)
    }
    
    func moveToFavouritsFilesPage() {
        let favourites = router.favorites(moduleOutput: presenter,
                                          sortType: presenter.favoritesSortType,
                                          viewType: presenter.favoritesViewType)
        
        router.pushViewController(viewController: favourites)
    }
    
    func moveToCreationStory() {
        let controller = router.createStory(navTitle: TextConstants.createStory)
        
        router.pushViewController(viewController: controller)
    }
    
    func moveToSearchScreen(output: UIViewController?) {
        let controller = router.searchView(navigationController: output?.navigationController,
                                           output: output as? SearchModuleOutput)
        router.pushViewController(viewController: controller)
    }
    
    //MARK: Utility method
    private func moveToPremium(title: String, headerTitle: String, completion: VoidHandler?) {
        let controller = router.premium(title: title, headerTitle: headerTitle)
        
        router.pushViewController(viewController: controller)
    }
    
    //MARK: Present controller
    func showError(errorMessage: String) {
        let popUp = PopUpController.with(title: TextConstants.errorAlert,
                                  message: errorMessage,
                                  image: .error,
                                  buttonTitle: TextConstants.ok)
        
        popUpsToPresent.append(popUp)
    }
    
    func showPopupForNewUser(with message: String, title: String, headerTitle: String, completion: VoidHandler?) {
        let popUp = PopUpController.with(title: nil,
                                         message: message,
                                         image: .none,
                                         firstButtonTitle: TextConstants.noForUpgrade,
                                         secondButtonTitle: TextConstants.yesForUpgrade,
                                         secondAction: { [weak self] vc in
                                            vc.dismiss(animated: true, completion: {
                                                self?.moveToPremium(title: title,
                                                                    headerTitle: headerTitle,
                                                                    completion: completion)
                                            })
        })
        
        popUpsToPresent.append(popUp)
    }
    
    func presentSmallFullOfQuotaPopUp() {
        if let popUp = SmallFullOfQuotaPopUp.popUp() {
            
            popUpsToPresent.append(popUp)
        }
    }
    
    func presentFullOfQuotaPopUp(with type: LargeFullOfQuotaPopUpType) {
        let popUp = LargeFullOfQuotaPopUp.popUp(type: type)
        
        popUpsToPresent.append(popUp)
    }
    
    func presentEmailVerificationPopUp() {
        let popUp = router.verifyEmailPopUp
        
        popUpsToPresent.append(popUp)
    }
    
    func presentCredsUpdateCkeckPopUp(message: String, userInfo: AccountInfoResponse?) {
        let popUp = CredsUpdateCheckPopUp.with(message: message, userInfo: userInfo)
        
        popUpsToPresent.append(popUp)
    }
    
    func presentPopUps() {
        let popUps = popUpsToPresent
            .compactMap { $0 as? BasePopUpController }
            .sorted(by: { popUp1, _ in
                if popUp1 is VerifyEmailPopUp {
                    return true
                } else {
                    return false
                }
            })
        
        popUpsToPresent.removeAll()
        
        popUpService.addPopUs(popUps)
    }
    
    func openCampaignDetails() {
        let controller = router.campaignDetailViewController()
        router.pushViewController(viewController: controller)
    }
    
    func presentMobilePaymentPermissionPopUp(url: String, isFirstAppear: Bool) {
        let popup = getPopUpController(url: url)
        popUpsToPresent.append(popup)
        isFirstAppear ? () : presentPopUps()
    }
    
    private func getPopUpController(url: String) -> PopUpController {
        let plainMessage = TextConstants.mobilePaymentOpenPopupDescriptionLabel
        let range = (plainMessage as NSString).range(of: TextConstants.mobilePaymentOpenPopupDescriptionBoldRangeLabel)
        let attributeMessage = NSMutableAttributedString(string: plainMessage)
        let attribute = [NSAttributedString.Key.font : UIFont.TurkcellSaturaDemFont(size: 16), NSAttributedString.Key.strokeColor : ColorConstants.marineTwo]
        attributeMessage.addAttributes(attribute, range: range)
        let popup = PopUpController.with(title: TextConstants.mobilePaymentOpenPopupTitleLabel, attributedMessage: attributeMessage, image: .none, firstButtonTitle: TextConstants.mobilePaymentOpenPopupLaterButton, secondButtonTitle: TextConstants.mobilePaymentOpenPopupContinueButton, firstAction: getRemindMeLaterHandler(), secondAction: getContinueHandler(url: url))
        return popup
    }
    
    private func getContinueHandler(url: String) -> PopUpButtonHandler {
        return { [weak self] vc in
            guard let self = self else {
                return
            }
            self.trackGAEvent(eventLabel: .mobilePaymentAction(true))
            self.routeMobilePaymentPermissionVC(url: url)
            vc.close()
        }
    }
    
    private func getRemindMeLaterHandler() -> PopUpButtonHandler {
        return { [weak self] vc in
            guard let self = self else {
                return
            }
            self.trackGAEvent(eventLabel: .mobilePaymentAction(false))
            self.presenter.interactor.updateMobilePaymentPermissionFeedback()
            vc.close()
        }
    }
    
    private func routeMobilePaymentPermissionVC(url: String) {
        let router = RouterVC()
        let viewController = router.mobilePaymentPermissionController()
        viewController.urlString = url
        viewController.delegate = self
        router.pushViewController(viewController: viewController)
        analyticsService.logScreen(screen: .mobilePaymentPermission)
    }
    
    private func trackGAEvent(eventLabel: GAEventLabel) {
        self.analyticsService.trackCustomGAEvent(eventCategory: .popUp, eventActions: .mobilePaymentPermission, eventLabel: eventLabel)
    }
    
}

// MARK: Mobile Payment Permission Delegate
extension HomePageRouter: MobilePaymentPermissionProtocol {
    
    func approveTapped() {
        presenter.view.closePermissionPopUp()
        presenter.interactor.changePermissionsAllowed(type: .mobilePayment, isApproved: true)
    }
    
    func backTapped(url: String) {
        presentMobilePaymentPermissionPopUp(url: url, isFirstAppear: false)
    }
    
}
