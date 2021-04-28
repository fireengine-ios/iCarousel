//
//  ReferenceCard.swift
//  Depo
//
//  Created by Alper Kırdök on 26.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class ReferenceCard: BaseCardView {

    override func configurateView() {
        super.configurateView()

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //let bottomSpace : CGFloat = 21.0
//        let h = contentStackView.frame.origin.y + contentStackView.frame.size.height + bottomSpace
        let h: CGFloat = 200
        if calculatedH != h {
            calculatedH = h
        }
    }
}
