//
//  PhoneEnterController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PhoneEnterController: UIViewController, NibInit {
    
    @IBOutlet private var customizator: PhoneEnterCustomizator!
    
//    @IBOutlet private weak var approveButton: UIButton!
    @IBOutlet private weak var emailTextField: UnderlineTextField!
    
    private lazy var attemptsCounter = AttemptsCounter(limit: NumericConstants.emptyEmailUserCloseLimit, complition: { 
        AppConfigurator.logout()
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction private func actionApproveButton(_ sender: UIButton) {
        print("actionApproveButton")
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        attemptsCounter.up()
        dismiss(animated: true, completion: nil)
    }
}

final class AttemptsCounter {
    
    static func unicID(function: String = #function, file: String = #file, line: Int = #line) -> String {
        return "\(function).\(file).\(line)"
    }
    
    private let userDefaultsKey: String
    private var attempts: Int {
        get { return UserDefaults.standard.integer(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }
    
    private let limit: Int
    private let complition: VoidHandler
    
    init(limit: Int, userDefaultsKey: String = AttemptsCounter.unicID(), complition: @escaping VoidHandler) {
        self.userDefaultsKey = userDefaultsKey
        self.limit = limit
        self.complition = complition
    }
    
    func up() {
        attempts += 1
        if attempts >= limit {
            reset()
            complition()
        }
    }
    
    func reset() {
        attempts = 0
    }
}
