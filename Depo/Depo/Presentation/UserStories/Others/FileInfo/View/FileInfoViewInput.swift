//
//  FileInfoFileInfoViewInput.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol FileInfoViewInput: class, ActivityIndicator, ErrorPresenter {
    func startRenaming()
    func setObject(object: BaseDataSourceItem)
    func goBack()
    func hideViews()
    func showViews()
    func show(name: String)
}
