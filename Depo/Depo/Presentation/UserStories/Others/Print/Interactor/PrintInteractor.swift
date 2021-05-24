//
//  PrintInteractor.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PrintInteractor {

    weak var output: PrintInteractorOutput!

    private let data: [Item]
    private let printService = PrintService()
    
    init(data: [Item]) {
        self.data = data
    }
}

// MARK: - PrintInteractorInput

extension PrintInteractor: PrintInteractorInput {

    func formData() {
        loadAccountInfo { info in
            self.prepareFormData(with: info)
        } error: {
            self.output.failedToCreateFormData()
        }

        printService.sendLog(for: data) { _ in

        }
    }

    private func prepareFormData(with accountInfo: AccountInfoResponse) {
        guard let url = URL(string: PrintService.path) else {
            return
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = PrintService.dataJSON(with: data, userId: accountInfo.cellografId ?? "")

        output.urlDidForm(urlRequest: request as URLRequest)
    }

    private func loadAccountInfo(success: @escaping ValueHandler<AccountInfoResponse>, error: @escaping VoidHandler) {
        AccountService().info { response in
            guard let info = response as? AccountInfoResponse else {
                error()
                return
            }
            success(info)

        } fail: { _ in
            error()
        }
    }
}
