//
//  PhotoPrintAddAdressPopup.swift
//  Depo
//
//  Created by Ozan Salman on 15.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

enum TappedView {
    case city
    case district
}

final class PhotoPrintAddAdressPopup: BasePopUpController {
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.addAddress)
        }
    }
    
    @IBOutlet private weak var exitImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconCancelUnborder.image
        }
    }
    
    @IBOutlet weak var lineLabel: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.lightGrayColor.color
        }
    }
    
    @IBOutlet weak var adressTitleView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressTitle)
            newValue.textField.quickDismissPlaceholder = localized(.addressTitlePlaceholder)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
        }
    }

    @IBOutlet weak var cityView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressCity)
            newValue.textField.quickDismissPlaceholder = localized(.selectCityDistrict)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
            newValue.isEditState = false
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: newValue.textField.frame.height))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 16, width: 24, height: 24))
            imageView.image = Image.iconArrowDownSmall.image
            rightView.addSubview(imageView)
            newValue.textField.rightView = rightView
            newValue.textField.rightViewMode = .always
        }
    }
    
    @IBOutlet weak var districtView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressDistrict)
            newValue.textField.quickDismissPlaceholder = localized(.selectCityDistrict)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
            newValue.isEditState = false
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: newValue.textField.frame.height))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 16, width: 24, height: 24))
            imageView.image = Image.iconArrowDownSmall.image
            rightView.addSubview(imageView)
            newValue.textField.rightView = rightView
            newValue.textField.rightViewMode = .always
        }
    }
    
    @IBOutlet weak var neighbourhoodView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressNeighbourhood)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
        }
    }
    
    @IBOutlet weak var streetView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressStreet)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
        }
    }
    
    @IBOutlet weak var buildingNoView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressBuildingNo)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
        }
    }
    
    @IBOutlet weak var apartmentNoView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressApartmentNo)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
        }
    }
    
    @IBOutlet weak var postaCodeView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressPostacode)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
        }
    }
    
    @IBOutlet weak var checkButton: UIButton! {
        willSet {
            newValue.setImage(Image.iconSelectEmpty.image, for: .normal)
            newValue.setImage(Image.iconSelectFills.image, for: .selected)
        }
    }
    
    @IBOutlet weak var checkLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.addSavedMyAddress)
        }
    }
    
    @IBOutlet weak var saveAdressButton: UIButton! {
        willSet {
            newValue.setTitle(localized(.saveAddress), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.switcherGrayColor.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.switcherGrayColor.cgColor
            newValue.isUserInteractionEnabled = true
        }
    }
    
    private let service = PhotoPrintService()
    private var cityList: [CityResponse]?
    private var districtList: [DistrictResponse]?
    private var tableView: UITableView!
    private let tableContainerView = UIView()
    private var selectedCityId = Int()
    private var selectedDistrictId = Int()
    private var tappedView: TappedView = .city
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setTapped()
        getCity()
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
        tableContainerView.isHidden = true
        tableView.isHidden = true
        enableButton(isEnable: true)
    }
    
    @IBAction func saveAdressButtonTapped(_ sender: Any) {
        
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
    
    private func enableButton(isEnable: Bool) {
        if isEnable {
            saveAdressButton.backgroundColor = AppColor.darkBlueColor.color
            saveAdressButton.layer.borderColor = AppColor.darkBlueColor.cgColor
            saveAdressButton.isUserInteractionEnabled = true
        } else {
            saveAdressButton.backgroundColor = AppColor.switcherGrayColor.color
            saveAdressButton.layer.borderColor = AppColor.switcherGrayColor.cgColor
            saveAdressButton.isUserInteractionEnabled = false
        }
    }
    
    @objc private func cityViewTapped() {
        tappedView = .city
        tableViewConfig(withView: cityView)
        tableView.reloadData()
    }
    
    @objc private func districtViewTapped() {
        tappedView = .district
        tableViewConfig(withView: districtView)
        tableView.reloadData()
    }
    
    private func tableViewConfig(withView: UIView) {
        tableContainerView.isHidden = false
        tableView.isHidden = false
        tableContainerView.frame = CGRect(x: 12, y: withView.frame.maxY, width: view.frame.width - 48, height: 240)
    }
    
    private func configureTableView() {
        view.addSubview(tableContainerView)
        tableContainerView.frame = CGRect(x: 12, y: cityView.frame.maxY, width: view.frame.width - 48, height: 240)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: tableContainerView.frame.width, height: tableContainerView.frame.height))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self

        tableContainerView.addSubview(tableView)
        
        tableContainerView.isHidden = true
        tableView.isHidden = true

        let thickness: CGFloat = 1.0
        let leftBorder = CALayer()
        let rightBorder = CALayer()
        let bottomBorder = CALayer()
        leftBorder.frame = CGRect(x: 0, y: -6, width: thickness, height: tableContainerView.frame.size.height + 6)
        rightBorder.frame = CGRect(x: tableContainerView.frame.width - 1, y: -6, width: thickness, height: tableContainerView.frame.size.height + 6)
        bottomBorder.frame = CGRect(x: 0, y: tableContainerView.frame.height, width: tableContainerView.frame.size.width, height: thickness)

        leftBorder.backgroundColor = AppColor.borderColor.cgColor
        rightBorder.backgroundColor = AppColor.borderColor.cgColor
        bottomBorder.backgroundColor = AppColor.borderColor.cgColor

        tableContainerView.layer.addSublayer(leftBorder)
        tableContainerView.layer.addSublayer(rightBorder)
        tableContainerView.layer.addSublayer(bottomBorder)
    }
}

extension PhotoPrintAddAdressPopup {
    static func with() -> PhotoPrintAddAdressPopup {
        let vc = controllerWith()
        return vc
    }
    
    private static func controllerWith() -> PhotoPrintAddAdressPopup {
        let vc = PhotoPrintAddAdressPopup(nibName: "PhotoPrintAddAdressPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        return vc
    }
}

extension PhotoPrintAddAdressPopup: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tappedView == .city {
            return cityList?.count ?? 0
        } else {
            return districtList?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        if tappedView == .city {
            cell.textLabel!.text = cityList?[indexPath.row].name ?? ""
        } else {
            cell.textLabel!.text = districtList?[indexPath.row].name ?? ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tappedView == .city {
            selectedCityId = cityList?[indexPath.row].id ?? 0
            cityView.textField.text = cityList?[indexPath.row].name ?? ""
            districtView.textField.text = localized(.selectCityDistrict)
            getDistrict(id: cityList?[indexPath.row].id ?? 1)
        } else {
            selectedDistrictId = cityList?[indexPath.row].id ?? 0
            districtView.textField.text = districtList?[indexPath.row].name ?? ""
        }
        
        tableContainerView.isHidden = true
    }
}

extension PhotoPrintAddAdressPopup {
    private func setTapped() {
        exitImageView.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        exitImageView.addGestureRecognizer(tapImage)
        
        cityView.textField.isUserInteractionEnabled = true
        let cityViewTapped = UITapGestureRecognizer(target: self, action: #selector(cityViewTapped))
        cityView.textField.addGestureRecognizer(cityViewTapped)
        
        districtView.textField.isUserInteractionEnabled = true
        let districtViewTapped = UITapGestureRecognizer(target: self, action: #selector(districtViewTapped))
        districtView.textField.addGestureRecognizer(districtViewTapped)
    }
}

extension PhotoPrintAddAdressPopup {
    
    private func getCity() {
        showSpinner()
        service.photoPrintCity() { [weak self] result in
            switch result {
            case .success(let response):
                self?.cityList = response
                self?.tableView.reloadData()
                self?.hideSpinner()
            case .failed(_):
                self?.hideSpinner()
                break
            }
        }
    }
    
    private func getDistrict(id: Int) {
        showSpinner()
        service.photoPrintDistrict(id: id) { [weak self] result in
            switch result {
            case .success(let response):
                self?.districtList = response
                self?.tableView.reloadData()
                self?.hideSpinner()
            case .failed(_):
                self?.hideSpinner()
                break
            }
        }
    }
}
