//
//  CreateStoryPhotosCreateStoryInitializer.swift
//  Depo
//
//  Created by Oleg on 02/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryModuleInitializer: BaseFilesGreedModuleInitializer {

    class func initializePhotoSelectionViewControllerForStory(with nibName: String, story: PhotoStory) -> UIViewController {
        let viewController = CreateStoryPhotoSelectionViewController(nibName: nibName, bundle: nil)
        viewController.scrollablePopUpView.isEnable = false
        let configurator = CreateStorySelectionConfigurator()

        configurator.configure(viewController: viewController, remoteServices: PhotoAndVideoService(requestSize: 100, type: .image),
                               filters: [.localStatus(.nonLocal), .fileType(.image)], story: story)
        return viewController
    }
    
    class func initializeFavoritePhotoSelectionViewControllerForStory(with nibName: String, story: PhotoStory) -> UIViewController {
        let viewController = CreateStoryPhotoSelectionViewController(nibName: nibName, bundle: nil)
        viewController.scrollablePopUpView.isEnable = false
        viewController.isFavorites = true
        let configurator = CreateStorySelectionConfigurator()
        
        configurator.configure(viewController: viewController, remoteServices: FavouritesService(requestSize: 100),
                               filters: [.localStatus(.nonLocal), .favoriteStatus(.favorites), .fileType(.image)], story: story)
        return viewController
    }
    
    class func initializeAudioSelectionViewControllerForStory(with story: PhotoStory) -> UIViewController {
//        let viewController = CreateStoryAudioSelectionViewController()
//        viewController.scrollablePopUpView.isEnable = false
//        let configurator = CreateStorySelectionConfigurator()
//
//        configurator.configure(viewController: viewController, remoteServices: CreateStoryMusicService(),
//                               filters: [.fileType(.audio)], story: story)
        let viewController = CreateStoryAudioSelectionItemViewController(forStory: story)
        return viewController
    }

}
