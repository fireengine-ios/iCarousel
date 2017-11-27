//
//  PullToRefreshKit+LifeBox.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/18/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import PullToRefreshKit

protocol SetupForLifeBox {
    func setupForLifeBox()
}

extension DefaultRefreshHeader: SetupForLifeBox {
    func setupForLifeBox() {
        setText(TextConstants.pullToRefreshPull, mode: .pullToRefresh)
        setText(TextConstants.pullToRefreshRelease, mode: .releaseToRefresh)
        setText(TextConstants.pullToRefreshSuccess, mode: .refreshSuccess)
        setText(TextConstants.pullToRefreshRefreshing, mode: .refreshing)
        setText(TextConstants.pullToRefreshFailed, mode: .refreshFailure)
        textLabel.textColor = ColorConstants.activityTimelineDraws
        imageView.tintColor = ColorConstants.activityTimelineDraws
        spinner.color = ColorConstants.activityTimelineDraws
    }
}

extension DefaultRefreshFooter: SetupForLifeBox {
    func setupForLifeBox() {
        setText(TextConstants.pullToRefreshPull, mode: .pullToRefresh)
        setText(TextConstants.pullToRefreshRefreshing, mode: .refreshing)
        textLabel.textColor = ColorConstants.activityTimelineDraws
        spinner.color = ColorConstants.activityTimelineDraws
    }
}

extension SetUp where Self: SetupForLifeBox {
    func setupForLifeBox() {
        setupForLifeBox()
    }
}

