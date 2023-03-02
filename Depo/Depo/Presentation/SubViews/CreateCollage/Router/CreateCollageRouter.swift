//
//  CreateCollageRouter.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class CreateCollageRouter: CreateCollageRouterInput {
    func navigateToSeeAll(for view: ForYouSections) {
        print("12121212")
    }
    
    func displayItem(item: WrapData) {
        print("qweqeqwe")
    }
    
    private let router = RouterVC()
    weak var presenter: CreateCollagePresenter!
}
