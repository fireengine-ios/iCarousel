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
    
    init(data: [Item]) {
        self.data = data
    }
}

// MARK: - PrintInteractorInput

extension PrintInteractor: PrintInteractorInput {
    
    func formData() {
        
        guard let url = URL(string: PrintService.path) else {
            return
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = PrintService.dataJSON(with: data)
        
        output.urlDidForm(urlRequest: request as URLRequest)
    }
    
}
