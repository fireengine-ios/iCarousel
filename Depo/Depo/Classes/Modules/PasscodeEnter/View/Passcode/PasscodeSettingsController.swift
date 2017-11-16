////
////  PasscodeSettingsController.swift
////  LifeBox-new
////
////  Created by Bondar Yaroslav on 14/11/2017.
////  Copyright © 2017 Bondar Yaroslav. All rights reserved.
////
//
//import UIKit
//
///// ExampleappusingPhotosframework sections
//final class PasscodeSettingsController: UIViewController {
//
//    enum PasscodeType {
//        case enabled
//        case disabled
//    }
//
//    var state: PasscodeType = .disabled {
//        didSet {
//
//            let indexPaths = [
//                IndexPath(row: 1, section: 0),
//                IndexPath(row: 2, section: 0)
//            ]
//            //            tableView.beginUpdates()
//
//            switch state {
//            case .enabled:
//                //                tableView.insertRows(at: indexPaths, with: .automatic)
//                PasscodeCells.count = 3
//            case .disabled:
//                //                tableView.deleteRows(at: indexPaths, with: .automatic)
//                PasscodeCells.count = 1
//            }
//            tableView.reloadData()
//            //            tableView.endUpdates()
//        }
//    }
//
//    private enum PasscodeCells: Int {
//        static var count = 3
//
//        case enable
//        case touchID
//        case new
//    }
//
//    private enum Sections: Int {
//        static let titles: [String?] = [nil]
//        static let count = 1
//
//        case passcode
//    }
//
//    @IBOutlet weak var tableView: UITableView! {
//        didSet {
//            tableView.dataSource = self
//            tableView.delegate = self
//        }
//    }
//
//    private lazy var passcodeStorage: PasscodeStorage = PasscodeStorageDefaults()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        tableView.reloadData()
//        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SwitchCell
//        if passcodeStorage.isEmpty {
//            state = .disabled
//            cell?.enableSwitch.isOn = false
//        } else {
//            cell?.enableSwitch.isOn = true
//            state = .enabled
//        }
//    }
//
//}
//extension PasscodeSettingsController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return Sections.count
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch Sections(rawValue: section)! {
//        case .passcode: return PasscodeCells.count
//        }
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch Sections(rawValue: indexPath.section)! {
//        case .passcode:
//
//            switch PasscodeCells(rawValue: indexPath.row)! {
//            case .enable:
//                let cell = tableView.dequeue(reusable: SwitchCell.self, for: indexPath)
//                cell.fill(with: "Enable")
//                return cell
//
//            case .touchID:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "touchID", for: indexPath) as! SwitchCell
//                cell.fill(with: "Touch ID")
//                return cell
//
//            case .new:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "new", for: indexPath)
//                cell.textLabel?.text = "Set new"
//                return cell
//            }
//
//
//
//        }
//    }
//}
//extension PasscodeSettingsController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return Sections.titles[section]
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        switch Sections(rawValue: indexPath.section)! {
//        case .passcode:
//
//            switch PasscodeCells(rawValue: indexPath.row)! {
//            case .enable:
//                let cell = tableView.cellForRow(at: indexPath) as! SwitchCell
//                cell.select()
//
//
//                if state == .enabled {
//                    state = .disabled
//                    passcodeStorage.clearPasscode()
//
//                } else {
//                    let vc = PasscodeController.with(flow: .create)
//                    vc.success = {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                    navigationController?.pushViewController(vc, animated: true)
//                }
//
//            case .touchID:
//                let cell = tableView.cellForRow(at: indexPath) as! SwitchCell
//                cell.select()
//                TouchIdManager().isEnabledTouchId = cell.enableSwitch.isOn
//
//            case .new:
//                tableView.deselectRow(at: indexPath, animated: true)
//
//                let vc = PasscodeController.with(flow: .setNew)
//                vc.success = {
//                    self.navigationController?.popViewController(animated: true)
//                }
//                navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//    }
//}
//
