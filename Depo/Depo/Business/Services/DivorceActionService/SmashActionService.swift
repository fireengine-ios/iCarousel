//
//  SmashActionService.swift
//  Depo
//
//  Created by Raman Harhun on 2/18/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol SmashActionServiceProtocol: DivorceActionPopUpPresentProtocol {
    func startOperation(handler: @escaping BoolHandler)
    func smashSuccessed()
}

final class SmashActionService: CommonDivorceActionService {
    
    private var callback: BoolHandler?
    
    override var confirmPopUp: BasePopUpController {
        return PopUpController.with(title: TextConstants.save,
                                    message: TextConstants.smashPopUpMessage,
                                    image: .error,
                                    firstButtonTitle: TextConstants.cancel,
                                    secondButtonTitle: TextConstants.ok,
                                    firstAction: { popup in
                                        self.callback?(false)
                                        popup.close() },
                                    secondAction: { popup in
                                        popup.close()
                                        self.callback?(true)
        })
    }
}

//MARK: - SmashActionServiceProtocol
extension SmashActionService: SmashActionServiceProtocol {
    func startOperation(handler: @escaping BoolHandler) {
        self.callback = handler
        startOperation()
    }
    
    func smashSuccessed() {
        showSuccessPopUp()
    }
}

//MARK: - DivorceActionPopUpPresentProtocol
extension SmashActionService {
    override var state: HSCompletionPopUpsFactory.State {
        return .smashCompleted
    }
    
    override var itemsCount: Int {
        return 1
    }
}

//MARK: - DivorceActionAnalyticsProtocol
extension SmashActionService {
    override func trackConfirmPopUpAppear() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.SmashConfirmPopUp())
    }
}
