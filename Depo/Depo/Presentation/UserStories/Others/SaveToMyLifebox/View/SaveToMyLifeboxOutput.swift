//
//  SaveToMyLifeboxOutput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

protocol SaveToMyLifeboxViewOutput: AnyObject {
    func viewIsReady()
    func onSelect(item: WrapData)
    func saveToMyLifeboxSaveRoot()
}
