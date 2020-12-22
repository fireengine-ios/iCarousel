//
//  FaceImageAddNameViewController.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImageAddNameViewController: BaseFilesGreedChildrenViewController {
    
    @IBOutlet private weak var searchTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTitle(withString: mainTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.font = UIFont.TurkcellSaturaBolFont(size: 18)
        if mainTitle == TextConstants.faceImageAddName {
            searchTextField.text = ""
        } else {
            searchTextField.text = mainTitle
        }
        searchTextField.placeholder = TextConstants.faceImageSearchAddName
        searchTextField.becomeFirstResponder()
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func stopSelection() { }
    
    override func configurateNavigationBar() {
        navigationBarWithGradientStyle()
        let done = NavBarWithAction(navItem: NavigationBarList().done, action: { [weak self] _ in
            if let output = self?.output as? FaceImageAddNameViewOutput,
                let text = self?.searchTextField.text {
                output.changeName(text)
            }
        })

        navBarConfigurator.configure(right: [done], left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let output = output as? FaceImageAddNameViewOutput,
            let text = textField.text {
            output.onSearchPeople(text)
        }
    }

}
