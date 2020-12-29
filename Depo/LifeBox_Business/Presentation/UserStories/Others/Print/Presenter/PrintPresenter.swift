//
//  PrintPresenter.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PrintPresenter: BasePresenter {

    weak var view: PrintViewInput!
    var interactor: PrintInteractorInput!
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

// MARK: - PrintInteractorOutput

extension PrintPresenter: PrintInteractorOutput {
    
    func urlDidForm(urlRequest: URLRequest) {
        view.loadUrl(urlRequest)
    }
    
}

// MARK: - PrintViewOutput

extension PrintPresenter: PrintViewOutput {
    
    
    func viewIsReady() {
        interactor.formData()
    }
    
    func didStartLoad() {
        startAsyncOperation()
    }
    
    func didEndLoad() {
        asyncOperationSuccess()
    }
    
}
