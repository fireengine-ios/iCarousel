//
//  AutoNextEditingRowPasser.swift
//  Depo
//
//  Created by Aleksandr on 6/16/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoNextEditingRowPasser {
    
    static func  passToNextEditingRow(withEditedCell editedCell: ProtoInputTextCell, inTable table: UITableView) -> ProtoInputTextCell? {
        guard let editedRowIndexPath = table.indexPath(for: editedCell) else {
            return nil
        }
        for i in editedRowIndexPath.row + 1 ... table.visibleCells.count {
            guard let cell = table.cellForRow(at: IndexPath(item: i, section: editedRowIndexPath.section)) as? ProtoInputTextCell else {
                break
            }
            
            if i >= table.visibleCells.count - 1 {
                cell.changeReturnKey(to: .done)
            }
            cell.startEditing()
            
            return cell
        }
        return nil
    }
}
