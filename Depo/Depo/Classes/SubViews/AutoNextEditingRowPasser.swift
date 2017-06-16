//
//  AutoNextEditingRowPasser.swift
//  Depo
//
//  Created by Aleksandr on 6/16/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoNextEditingRowPasser {
    static func  passToNextEditingRow(withEditedCell editedCell: ProtoInputTextCell, inTable table: UITableView) {
        guard let editedRowIndexPath = table.indexPath(for: editedCell) else {
            return
        }
        for i in editedRowIndexPath.row + 1 ... table.visibleCells.count {
            guard let cell = table.cellForRow(at: IndexPath(item: i, section: editedRowIndexPath.section)) as? ProtoInputTextCell else {
                break
            }
            cell.startEditing()
            return
        }
    }
}
