//
//  TextEnterDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 10/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class TextEnterDataSource: RegistrationDataSource {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cell = cell as? GSMUserInputCell {
            cell.setup(style: .textEnter)
        }
        return cell
    }
}
