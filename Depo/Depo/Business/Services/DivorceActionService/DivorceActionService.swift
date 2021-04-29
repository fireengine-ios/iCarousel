//
//  DivorceActionService.swift
//  Depo
//
//  Created by Raman Harhun on 2/17/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

//conform hide and smash(fun) functionality
protocol DivorceActionRoutingProtocol {
    func openPremium()
    func openFaceImageGrouping()
    func openPeopleAlbum()
}

@objc protocol DivorceActionStateProtocol {
    func onFail(_ error: Error)
    func onPopUpClosed()
    func onOpenPremium()
    func onOpenPeopleAlbum()
    func onOpenFaceImageGrouping()
    func onShare()
}

@objc protocol DivorceActionAnalyticsProtocol {
    var analytics: AnalyticsService { get }
    
    func trackPopUpClosed()
    func trackBecomePremium()
    func trackConfirmPopUpAppear()
    func trackProceedWithExistingPeople()
}

@objc protocol DivorceActionPopUpPresentProtocol {
    var state: HSCompletionPopUpsFactory.State { get }
    var confirmPopUp: BasePopUpController { get }
    var itemsCount: Int { get }
    
    func startOperation()
    func showSuccessPopUp()
    func getUserInfo(completion: @escaping VoidHandler)
}

class CommonDivorceActionService {
    private lazy var router = RouterVC()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var accountService: AccountServicePrl = AccountService()

    private lazy var completionPopUpFactory = HSCompletionPopUpsFactory()
    private lazy var albumWarningPopUpsFactory = SmartAlbumWarningPopUpsFactory()

    private(set) var faceImageGrouping: SettingsInfoPermissionsResponse?
    private(set) var permissions: PermissionsResponse?
    private var group: DispatchGroup?
}

//MARK: - DivorceActionPopUpPresentProtocol
extension CommonDivorceActionService: DivorceActionPopUpPresentProtocol {
    
    var state: HSCompletionPopUpsFactory.State {
        assertionFailure()
        return .actionSheetHideCompleted
    }
    
    var itemsCount: Int {
        assertionFailure()
        return 0
    }
    
    var confirmPopUp: BasePopUpController {
        assertionFailure()
        return BasePopUpController()
    }
    
    private var successPopUp: BasePopUpController {
        return completionPopUpFactory.getPopUp(for: state, itemsCount: itemsCount, delegate: self)
    }
    
    func startOperation() {
        showConfirmPopUp()
    }
    
    func showConfirmPopUp() {
        trackConfirmPopUpAppear()
        presentPopUp(controller: confirmPopUp)
    }
    
    func showSuccessPopUp() {
        presentPopUp(controller: successPopUp)
    }
    
    func needShowPopup() -> Bool {
        switch state {
        case .actionSheetHideCompleted:
            return !completionPopUpFactory.isDoNotShowAgainButtonPressed(for: state)
            
        case .bottomBarHideCompleted, .hideAlbumsCompleted:
            return false
            
        case .smashCompletedPremium, .smashCompletedStandart:
            return true
        }
    }
    
    func getUserInfo(completion: @escaping VoidHandler) {
        let group = DispatchGroup()
        let requiredPreparations = [getPermissions, getFaceImageGroupingStatus]
        
        requiredPreparations.forEach {
            group.enter()
            $0()
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.group = nil
            completion()
        }
        
        self.group = group
    }
}

//MARK: - DivorceActionStateProtocol
extension CommonDivorceActionService: DivorceActionStateProtocol {
    func onFail(_ error: Error) {
        group = nil
        UIApplication.showErrorAlert(message: error.localizedDescription)
    }
    
    func onPopUpClosed() {
        trackPopUpClosed()
    }
    
    func onOpenPremium() {
        trackBecomePremium()
        openPremium()
    }
    
    func onOpenPeopleAlbum() {
        preparePeopleAlbumOpenning()
    }
    
    func onOpenFaceImageGrouping() {
        trackProceedWithExistingPeople()
        trackFaceImageGroupingStates()
        
        if faceImageGrouping?.isFaceImageAllowed == true {
            openPeopleAlbum()
        } else {
            openFaceImageGrouping()
        }
    }
    
    func onShare() { }
}

//MARK: - DivorceActionRoutingProtocol
extension CommonDivorceActionService: DivorceActionRoutingProtocol {

    func openPeopleAlbum() {
        let controller = router.peopleListController()
        push(controller: controller)
    }

    func openPremium() {
        let controller = router.premium()
        push(controller: controller)
    }

    func openFaceImageGrouping() {
        let controller = router.faceImage
        push(controller: controller)
    }

    private func push(controller: UIViewController) {
        router.tabBarController?.dismiss(animated: true) {
            self.router.pushViewController(viewController: controller)
        }
    }
}

//MARK: - DivorceActionAnalyticsProtocol
extension CommonDivorceActionService: DivorceActionAnalyticsProtocol {
    private enum AnalyticsEventType {
        case popUpClose
        case becomePremium
        case openFaceImageGrouping
        case proceedWithExistingPeople
    }

    var analytics: AnalyticsService {
        return analyticsService
    }

    func trackPopUpClosed() {
        trackEvents(analyticsEvent: .popUpClose)
    }

    func trackBecomePremium() {
        trackEvents(analyticsEvent: .becomePremium)
    }

    func trackOpenFaceImageGrouping() {
        trackEvents(analyticsEvent: .openFaceImageGrouping)
    }

    func trackProceedWithExistingPeople() {
        trackEvents(analyticsEvent: .proceedWithExistingPeople)
    }

    func trackConfirmPopUpAppear() { }

    private func trackFaceImageGroupingStates() {
        let screen: AnalyticsAppScreens
        let event: NetmeraScreenEventTemplate
        
        if faceImageGrouping?.isFaceImageAllowed == true {
            screen = .standardUserWithFIGroupingOnPopUp
            event = NetmeraEvents.Screens.StandardUserFIRGroupingON()
            
        } else if AuthoritySingleton.shared.accountType.isPremium {
            screen = .nonStandardUserWithFIGroupingOffPopUp
            event = NetmeraEvents.Screens.NonStandardUserFIGroupingOFF()
            
        } else {
            screen = .standardUserWithFIGroupingOffPopUp
            event = NetmeraEvents.Screens.StandardUserFIGroupingOFF()
        }
        
        analyticsService.logScreen(screen: screen)
        AnalyticsService.sendNetmeraEvent(event: event)
    }

    private func trackEvents(analyticsEvent: AnalyticsEventType) {
        var event: GAEventLabel {
            switch analyticsEvent {
            case .openFaceImageGrouping:
                return GAEventLabel.enableFIGrouping
            case .becomePremium:
                return GAEventLabel.becomePremium
            case .proceedWithExistingPeople:
                return GAEventLabel.proceedWithExistingPeople
            case .popUpClose:
                return GAEventLabel.cancel
            }
        }
        
        let action: GAEventAction
        if faceImageGrouping?.isFaceImageAllowed == true {
            action = .standardUserWithFIGroupingOn
        } else if AuthoritySingleton.shared.accountType.isPremium {
            action = .nonStandardUserWithFIGroupingOff
        } else {
            action = .standardUserWithFIGroupingOff
        }
        
        analyticsService.trackCustomGAEvent(eventCategory: .popUp, eventActions: action, eventLabel: event)
    }
}

//MARK: - Utility
private extension CommonDivorceActionService {
    func presentPopUp(controller: BasePopUpController) {
        router.presentViewController(controller: controller, animated: false)
    }
}

//MARK: - Interactor
private extension CommonDivorceActionService {
    func getPermissions() {
        accountService.permissions { [weak self] response in
            switch response {
            case .success(let permissions):
                self?.permissions = permissions
                self?.group?.leave()

            case .failed(let error):
                self?.onFail(error)
                
            }
        }
    }

    func getFaceImageGroupingStatus() {
        accountService.getSettingsInfoPermissions { [weak self] response in
            switch response {
            case .success(let result):
                self?.faceImageGrouping = result
                self?.group?.leave()

            case .failed(let error):
                self?.onFail(error)
                
            }
        }
    }
}

//MARK: - On people album tap processing
private extension CommonDivorceActionService {
    func preparePeopleAlbumOpenning() {
        getUserInfo { [weak self] in
            self?.didObtainPeopleAlbumInfo()
        }
    }
    
    func didObtainPeopleAlbumInfo() {
        if permissions?.hasPermissionFor(.faceRecognition) == true, faceImageGrouping?.isFaceImageAllowed == true {
            openPeopleAlbum()
            
        } else if let controller = albumWarningPopUpsFactory.getPopUp(permissions: permissions,
                                                                      faceImageGrouping: faceImageGrouping,
                                                                      delegate: self) {
            presentPopUp(controller: controller)
            
        } else {
            assertionFailure("could't create pop up with recieved permissions and faceImageGrouping responses")
            
        }
    }
}
