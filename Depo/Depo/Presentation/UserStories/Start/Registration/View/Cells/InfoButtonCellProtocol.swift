//
//  InfoButtonCellProtocol.swift
//  Depo
//
//  Created by Aleksandr on 6/30/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol InfoButtonCellProtocol: AnyObject {
    func infoButtonGotPressed(with sender: Any?, andType type: UserValidationResults)
}
