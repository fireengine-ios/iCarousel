//
//  ContainerNavVC.swift
//  Depo
//
//  Created by Aleksandr on 7/19/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class EmptyContainerNavVC: ViewController {
    

    class func setupContainer(withSubVC subVC: UIViewController) -> EmptyContainerNavVC {
        
        let emptyContainerVC = EmptyContainerNavVC(nibName: nil,
                                                   bundle: nil)
        emptyContainerVC.configurate(subVC)
        
        return emptyContainerVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarStyle(.byDefault)
    }
    
    private func configurate(_ subVC: UIViewController) {

        addChildViewController(subVC)
        subVC.view.frame = view.bounds
        view.addSubview(subVC.view)
    }
    
}
