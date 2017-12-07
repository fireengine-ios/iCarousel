//
//  PackagesPackagesViewOutput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PackagesViewOutput {
    func viewIsReady()
    func didPressOn(plan: SubscriptionPlan)
    func buy(offer: OfferServiceResponse)
    func submit(promocode: String)
}
