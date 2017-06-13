//
//  IntroduceIntroduceViewController.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import QuartzCore

class IntroduceViewController: UIViewController, IntroduceViewInput {

    var output: IntroduceViewOutput!
    var dataSource = IntroduceDataSource()
    
    @IBOutlet weak var startUsingLifeBoxButton: UIButton!
    @IBOutlet weak var haveAccountButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self.dataSource
        self.dataSource.scrollView = self.scrollView
        self.dataSource.pageControll = self.pageControll
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configurateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewIsReady()
    }
    
    func configurateView(){
        self.startUsingLifeBoxButton.setTitle(NSLocalizedString(TextConstants.itroViewGoToRegisterButtonText, comment: ""), for: UIControlState.normal)
        self.startUsingLifeBoxButton.backgroundColor = ColorConstants.whiteColor
        self.startUsingLifeBoxButton.setTitleColor(ColorConstants.blueColor, for: UIControlState.normal)
        self.startUsingLifeBoxButton.titleLabel?.font = UIFont(name: "TurkcellSaturaBol", size: 20)
        self.startUsingLifeBoxButton.layer.cornerRadius = self.startUsingLifeBoxButton.frame.size.height * 0.5
        
        self.haveAccountButton.setTitle(NSLocalizedString(TextConstants.introViewGoToLoginButtonText, comment: ""), for: UIControlState.normal)
        self.haveAccountButton.backgroundColor = UIColor.clear
        self.haveAccountButton.setTitleColor(ColorConstants.whiteColor, for: UIControlState.normal)
        self.haveAccountButton.titleLabel?.font = UIFont(name: "TurkcellSaturaBol", size: 12)
        self.haveAccountButton.layer.borderWidth = 1.0
        self.haveAccountButton.layer.borderColor = ColorConstants.whiteColor.cgColor
        self.haveAccountButton.layer.cornerRadius = 3.0
        self.haveAccountButton.layer.masksToBounds = true
    }


    // MARK: IntroduceViewInput
    func setupInitialState(models : [IntroduceModel]){
        self.dataSource.configurateScrollViewWithModels(models: models)
    }
    
    // MARK: Actions
    
    @IBAction func onStartUsingLifeBoxButton(){
        self.output.onStartUsingLifeBox()
    }
    
    @IBAction func onHaveAccountButton(){
        self.output.onLoginButton()
    }
    
}
