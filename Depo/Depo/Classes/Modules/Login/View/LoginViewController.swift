//
//  LoginLoginViewController.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, LoginViewInput, UITableViewDelegate, UITableViewDataSource {

    var output: LoginViewOutput!
    
    var tableDataMArray:Array<UITableViewCell> = Array()
    
    @IBOutlet weak var bacgroungImageView: UIImageView!
    @IBOutlet weak var tableView:UITableView!
    

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //output.viewIsReady()
        
        //let nib = UINib(nibName: "LoginTableViewCell", bundle: nil)
        //self.tableView.register(nib, forCellReuseIdentifier: "LoginTableViewCell")
        
        self.tableView.backgroundColor = UIColor.clear
        
        var cell = LoginTableViewCell.initFromNib()
        cell.configurateWithType(cellType: TextInputView.TextInputViewType.Text)
        self.tableDataMArray.append(cell)
        
        cell = LoginTableViewCell.initFromNib()
        cell.configurateWithType(cellType: TextInputView.TextInputViewType.Password)
        self.tableDataMArray.append(cell)
        
        let cell2 = BottomLoginTableViewCell.initFromNib()
        self.tableDataMArray.append(cell2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.contentInset = UIEdgeInsetsMake(50.0, 0.0, 0.0, 0.0)
    }

    // MARK: LoginViewInput
    func setupInitialState(array :Array<UITableViewCell>) {
        self.tableDataMArray.removeAll()
        self.tableDataMArray.insert(contentsOf: array, at: 0)
        self.tableView.reloadData()
    }
    
    func showCapcha(){
        
    }
    
    
//MARC: UITableView delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableDataMArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == self.tableDataMArray.count - 1){
            return 254.0
        }
        return LoginTableViewCell.cellH()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "LoginTableViewCell", for: indexPath)
//        return cell
        return self.tableDataMArray[indexPath.row]
    }
    
}
