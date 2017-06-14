//
//  GSMCodeView.swift
//  Depo
//
//  Created by Aleksandr on 6/13/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol Events {
    func viewTapped()
}

class GSMCodeView: UIView {
    @IBOutlet weak var codeLabel: UILabel!
    
    var eventsProtocol: Events?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("TAP tap")
        eventsProtocol?.viewTapped()
    }
}
