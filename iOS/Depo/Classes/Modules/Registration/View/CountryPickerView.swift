//
//  CountryPickerView.swift
//  Depo
//
//  Created by Aleksandr on 6/12/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import UIKit

class CountryPickerView: UIView {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBAction func chooseAction(_ sender: Any) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
