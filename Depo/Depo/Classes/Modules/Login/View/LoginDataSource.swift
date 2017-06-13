//
//  LoginDataSource.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class LoginDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var tableDataMArray: [BaseCellModel] = []
    
    
    func setupTableView(tableView: UITableView){
        self.tableView = tableView
        let nib = UINib(nibName: "BaseUserInputCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BaseUserInputCell")
    }
    
    func setupCellsWithModels(models:[BaseCellModel]){
        self.tableDataMArray.removeAll()
        self.tableDataMArray.insert(contentsOf: models, at: 0)
        self.tableView.reloadData()
    }

    //MARC: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableDataMArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseUserInputCell", for: indexPath) as! BaseUserInputCellView
        let model = self.tableDataMArray[indexPath.row]
        cell.titleLabel.text = model.title
        cell.textInputField.text = ""
        return cell
    }
    
    
}
