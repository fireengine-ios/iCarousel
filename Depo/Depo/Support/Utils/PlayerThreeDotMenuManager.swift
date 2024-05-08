//
//  PlayerThreeDotMenuManager.swift
//  Depo
//
//  Created by Ozan Salman on 16.10.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class PlayerThreeDotMenuManager {
    
    private lazy var alert: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = delegate
        return alert
    }()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
//    func showActions(sender: Any?, item: WrapData, isSaved: Bool) {
//        var elementTypes: [ElementTypes] = []
//        if isSaved {
//            elementTypes.append(.download)
//            elementTypes.append(.share)
//        } else {
//            elementTypes.append(.delete)
//        }
//        alert.showVideoPlayer(with: elementTypes, for: item, presentedBy: sender, onSourceView: nil, viewController: nil)
//    }
    
    func showActions(sender: Any?, item: WrapData, isSaved: Bool) {
        var elementTypes: [ElementTypes] = []
        
        elementTypes.append(.delete)
        
        alert.showVideoPlayer(with: elementTypes, for: item, presentedBy: sender, onSourceView: nil, viewController: nil)
    }
}
