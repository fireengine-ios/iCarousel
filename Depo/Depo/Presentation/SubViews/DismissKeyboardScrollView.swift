//
//  DismissKeyboardScrollView.swift
//  Depo
//
//  Created by Alex Developer on 16.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class DismissKeyboardScrollView: UIScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}
