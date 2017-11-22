//
//  ImportFromInstagramPresenter.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/22/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ImportFromInstagramPresenter: BasePresenter {
    weak var view: ImportFromInstagramViewInput?
    var interactor: ImportFromInstagramInteractorInput!
    var router: ImportFromInstagramRouterInput!
}

// MARK: - ImportFromInstagramViewOutput
extension ImportFromInstagramPresenter: ImportFromInstagramViewOutput {
    
}

// MARK: - ImportFromInstagramInteractorOutput
extension ImportFromInstagramPresenter: ImportFromInstagramInteractorOutput {
    /// MAYBE WILL BE NEED
    // MARK: - Start to sync with FB
    
    //    func success(socialStatus: SocialStatusResponse) {
    //        compliteAsyncOperationEnableScreen()
    //    }
    //
    //    func failed(with errorMessage: String) {
    //        compliteAsyncOperationEnableScreen()
    ////        view.show(error: errorMessage)
    //    }
}
