//
//  UsageInfoViewOutput.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol UsageInfoViewOutput {
    func upgradeButtonPressed(with navVC: UINavigationController?)
    func viewIsReady()
    func viewWillAppear()
}
