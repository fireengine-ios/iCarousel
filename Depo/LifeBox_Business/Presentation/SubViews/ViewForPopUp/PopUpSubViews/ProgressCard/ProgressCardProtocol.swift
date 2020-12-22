//
//  ProgressPopUpProtocol.swift
//  Depo_LifeTech
//
//  Created by Oleg on 20.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol ProgressCardProtocol {
    func setProgress(allItems: Int?, readyItems: Int?)
    func configurateWithType(viewType: OperationType)
    func setImageForUploadingItem(item: WrapData)
}
