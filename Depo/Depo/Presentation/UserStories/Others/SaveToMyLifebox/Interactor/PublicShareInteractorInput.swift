//
//  PublicShareInteractorInput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol PublicShareInteractorInput {
    func fetchData()
    func fetchMoreIfNeeded()
    func savePublicSharedItems()
    func getPublicSharedItemsCount()
    func getAllPublicSharedItems(with itemCount: Int, fileName: String)
    func createPublicShareDownloadLink(with uuid: [String])
    func downloadPublicSharedItems(with url: String)
}
