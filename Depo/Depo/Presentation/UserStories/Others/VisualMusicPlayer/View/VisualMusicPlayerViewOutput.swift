//
//  VisualMusicPlayerVisualMusicPlayerViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol VisualMusicPlayerViewOutput {

    /**
        @author AlexanderP
        Notify presenter that view is ready
    */

    func viewIsReady(view: UIView, alert: AlertFilesActionsSheetPresenter)
    func closeMediaPlayer()
}
