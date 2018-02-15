//
//  HelpAndSupportHelpAndSupportViewController.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import ExpandableTableViewController

class HelpAndSupportViewController: ExpandableTableViewController, HelpAndSupportViewInput {

    
    var (tableSectionDataArray, tableDataArray) = FaqUrlService.faqBuilder()
    
    var output: HelpAndSupportViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        output.viewIsReady()
        self.expandableTableView.expandableDelegate = self
        
        self.title = "Help and Support"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: HelpAndSupportViewInput
    func setupInitialState() {
    }
    
    // MARK: - Init
    
    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
            cell.preservesSuperviewLayoutMargins = false
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    //setting header view
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x:0, y:0, width: tableView.frame.size.width, height: 48))
        headerView.backgroundColor = UIColor.white
        
        let label = UILabel(frame: CGRect(x:10, y:0, width: tableView.frame.size.width-10, height: 47))
        label.textColor = UIColor.gray
        label.font = UIFont.TurkcellSaturaRegFont(size: 14)
        label.text = "Frequantly asked questions"
        label.backgroundColor = UIColor.white
        headerView.addSubview(label)
        
        let separator = UILabel(frame: CGRect(x:0, y:headerView.frame.size.height-1, width: tableView.frame.size.width, height: 1))
        separator.backgroundColor = UIColor(red: 237.0/255.0,
                                            green: 237.0/255.0,
                                            blue: 237.0/255.0,
                                            alpha: 1.0)
        headerView.addSubview(separator)
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        //customization for footer goes here
    }
    
}


extension HelpAndSupportViewController: ExpandableTableViewDelegate {
    
    // MARK: ExpandableTableViewDelegate
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int{
        return tableSectionDataArray.count
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let titleCell = expandableTableView.dequeueReusableCellWithIdentifier("HelpAndSupportSectionTableViewCell", forIndexPath: expandableIndexPath) as! HelpAndSupportSectionTableViewCell
        titleCell.configure(item: tableSectionDataArray[expandableIndexPath.row])
        cell = titleCell
        
        return cell
    }
    
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> CGFloat{
        return 44.0
        
    }
    func expandableTableView(_ expandableTableView: ExpandableTableView, estimatedHeightForRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> CGFloat{
        return 44.0
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath){
        self.expandableTableView.deselectRowAtExpandableIndexPath(expandableIndexPath, animated: false)
        let item = tableSectionDataArray[expandableIndexPath.row]
        item.selected = !item.selected
        let indexPath = IndexPath(row: expandableIndexPath.row, section: expandableIndexPath.section)
        
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            expandableTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    // SubRows
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfSubRowsInRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> Int{
        return 1
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, subCellForRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> UITableViewCell{
        var cell: UITableViewCell!
        
        let descriptionCell = expandableTableView.dequeueReusableCellWithIdentifier("HelpAndSupportDescriptionTableViewCell", forIndexPath: expandableIndexPath) as! HelpAndSupportDescriptionTableViewCell
        
        descriptionCell.setTextForLabel(titleText: tableDataArray[expandableIndexPath.row], needShowSeparator: false)
        cell = descriptionCell
        
        return cell
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForSubRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> CGFloat{
        return UITableViewAutomaticDimension
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, estimatedHeightForSubRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath) -> CGFloat{
        return 100.0
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectSubRowAtExpandableIndexPath expandableIndexPath: ExpandableIndexPath){
        self.expandableTableView.deselectRowAtExpandableIndexPath(expandableIndexPath, animated: false)
    }
}
