//
//  PhotoPrintAddAdressPopup.swift
//  Depo
//
//  Created by Ozan Salman on 15.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

struct LocalAddress: Encodable {
    let id: Int
    let addressName: String
    let nameSurname: String
    let cityId: Int
    let city: String
    let districtId: Int
    let district: String
    let neighbourhood: String
    let street: String
    let buildNo: String
    let apartmentNo: String
    let postalCode: Int
}

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
    
    @IBOutlet weak var nameView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.printReceiptNme)
            newValue.textField.quickDismissPlaceholder = localized(.printReceiptNamePlaceholder)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            newValue.textField.delegate = self
        }
    }
    
    @IBOutlet weak var adressTitleView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressTitle)
            newValue.textField.quickDismissPlaceholder = localized(.addressTitlePlaceholder)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            newValue.textField.delegate = self
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
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            newValue.textField.delegate = self
        }
    }
    
    @IBOutlet weak var streetView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressStreet)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            newValue.textField.delegate = self
        }
    }
    
    @IBOutlet weak var buildingNoView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressBuildingNo)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            newValue.textField.delegate = self
        }
    }
    
    @IBOutlet weak var apartmentNoView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressApartmentNo)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            newValue.textField.delegate = self
        }
    }
    
    @IBOutlet weak var postaCodeView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.addressPostacode)
            newValue.textField.setLeftPaddingPoints(25)
            newValue.textField.autocorrectionType = .no
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            newValue.textField.delegate = self
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
            newValue.setTitle(localized(.useAddress), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.borderLightGray.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.borderLightGray.cgColor
            newValue.isUserInteractionEnabled = true
        }
    }
    
    private let service = PhotoPrintService()
    private var cityList: [CityResponse]?
    private var districtList: [DistrictResponse]?
    private var address: AddressResponse?
    private var tableView: UITableView!
    private let tableContainerView = UIView()
    private var selectedCityId = Int()
    private var selectedDistrictId = Int()
    private var isAddressSave = Bool()
    private var checkButtonIsChecked: Bool = false
    private var tappedView: TappedView = .city
    private var localAddress: LocalAddress?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        configureTableView()
        setTapped()
        getCity()
        setTextFromAddress(address: address)
        hideKeyboardWhenTappedAround()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
        
    @objc func dismissKeyboard() {
        tableContainerView.isHidden = true
        isTextFieldEmpty()
        setTextArrowImage(view: cityView, status: false)
        setTextArrowImage(view: districtView, status: false)
        view.endEditing(true)
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
        checkButtonIsChecked = (sender as! UIButton).isSelected
        checkButtonIsChecked ? checkButton.setImage(Image.iconSelectFills.image, for: .normal) : checkButton.setImage(Image.iconSelectEmpty.image, for: .normal)
    }
    
    @IBAction func saveAdressButtonTapped(_ sender: Any) {
        if isAddressSave {
            checkButtonIsChecked ? addAddressFunc(saveStatus: true) : addAddressFunc(saveStatus: false)
        } else {
            checkButtonIsChecked ? updateAddressFunc(saveStatus: true) : updateAddressFunc(saveStatus: false)
        }
    }
    
    private func addAddressFunc(saveStatus: Bool) {
        addAdress(addressName: adressTitleView.textField.text ?? "", recipientName: nameView.textField.text ?? "", recipientNeighbourhood: neighbourhoodView.textField.text ?? "", recipientStreet: streetView.textField.text ?? "", recipientBuildingNumber: buildingNoView.textField.text ?? "", recipientApartmentNumber: apartmentNoView    .textField.text ?? "", recipientCityId: selectedCityId, recipientDistrictId: selectedDistrictId, postalCode: Int(postaCodeView.textField.text ?? "") ?? 0, saveStatus: saveStatus)
    }
    
    private func updateAddressFunc(saveStatus: Bool) {
        updateAddress(id: address?.id ?? 0, addressName: adressTitleView.textField.text ?? "", recipientName: nameView.textField.text ?? "", recipientNeighbourhood: neighbourhoodView.textField.text ?? "", recipientStreet: streetView.textField.text ?? "", recipientBuildingNumber: buildingNoView.textField.text ?? "", recipientApartmentNumber: apartmentNoView.textField.text ?? "", recipientCityId: selectedCityId, recipientDistrictId: selectedDistrictId, postalCode: Int(postaCodeView.textField.text ?? "") ?? 0, saveStatus: saveStatus)
    }
    
    @objc private func dismissPopup() {
        self.dismiss(animated: false, completion: {
            let vc = PhotoPrintSendPopup.with(address: self.address)
            vc.openWithBlur()
        })
    }
    
    private func enableButton(isEnable: Bool) {
        if isEnable {
            saveAdressButton.backgroundColor = AppColor.darkBlueColor.color
            saveAdressButton.layer.borderColor = AppColor.darkBlueColor.cgColor
            saveAdressButton.isUserInteractionEnabled = true
        } else {
            saveAdressButton.backgroundColor = AppColor.borderLightGray.color
            saveAdressButton.layer.borderColor = AppColor.borderLightGray.cgColor
            saveAdressButton.isUserInteractionEnabled = false
        }
    }
    
    @objc private func cityViewTapped() {
        if tableContainerView.isHidden {
            setTextArrowImage(view: cityView, status: true)
            cityView.textField.text = localized(.selectCityDistrict)
            cityView.textField.textColor = AppColor.borderColor.color
            tappedView = .city
            tableViewConfig(withView: cityView)
            tableView.reloadData()
        } else {
            tableContainerView.isHidden = true
            isTextFieldEmpty()
            setTextArrowImage(view: cityView, status: false)
        }
        
    }
    
    @objc private func districtViewTapped() {
        if districtList?.count == nil {
            return
        }
        if tableContainerView.isHidden {
            setTextArrowImage(view: districtView, status: true)
            districtView.textField.textColor = AppColor.borderColor.color
            tappedView = .district
            tableViewConfig(withView: districtView)
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        } else {
            tableContainerView.isHidden = true
            isTextFieldEmpty()
            setTextArrowImage(view: districtView, status: false)
        }
    }
    
    private func tableViewConfig(withView: UIView) {
        tableContainerView.isHidden = false
        tableView.isHidden = false
        tableContainerView.frame = CGRect(x: 12, y: withView.frame.maxY, width: withView.frame.width, height: 240)
    }
    
    private func setTextFromAddress(address: AddressResponse?) {
        if address != nil {
            isAddressSave = false
            getDistrict(id: address?.addressCity.id ?? 1)
            selectedCityId = address?.addressCity.id ?? 1
            selectedDistrictId = address?.addressDistrict.id ?? 1
            nameView.textField.text = address?.recipientName
            adressTitleView.textField.text = address?.name
            cityView.textField.text = address?.addressCity.name
            districtView.textField.text = address?.addressDistrict.name
            neighbourhoodView.textField.text = address?.neighbourhood
            streetView.textField.text = address?.street
            buildingNoView.textField.text = address?.buildingNumber
            apartmentNoView.textField.text = address?.apartmentNumber
            postaCodeView.textField.text = String(describing: address?.postalCode ?? 0)
            enableButton(isEnable: true)
            checkButton.isSelected = false
            cityView.textField.textColor = AppColor.borderColor.color
            districtView.textField.textColor = AppColor.borderColor.color
            saveAdressButton.setTitle(localized(.updateAddress), for: .normal)
            titleLabel.text = localized(.updateAddress)
        } else {
            isAddressSave = true
            saveAdressButton.setTitle(localized(.useAddress), for: .normal)
            titleLabel.text = localized(.addAddress)
        }
    }
    
    private func isTextFieldEmpty() {
        var result: Bool = true
        let view1 = view.subviews[0].subviews[0].subviews
        for (_, element) in view1.enumerated() {
            if element is ProfileTextEnterView {
                let enterView = element as! ProfileTextEnterView
                if enterView.textField.text?.count ?? 0 == 0 || enterView.textField.text == localized(.selectCityDistrict) {
                    result = false
                }
            }
            if element is UIStackView {
                for(_, subElement) in element.subviews.enumerated() {
                    let enterView = subElement as! ProfileTextEnterView
                    if enterView.textField.text?.count ?? 0 == 0 {
                        result = false
                    }
                }
            }
        }
        result ? enableButton(isEnable: true) : enableButton(isEnable: false)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        isTextFieldEmpty()
    }
    
    private func configureTableView() {
        view.addSubview(tableContainerView)
        tableContainerView.frame = CGRect(x: 12, y: cityView.frame.maxY, width: cityView.frame.width, height: 240)
        
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
    
    private func setTextArrowImage(view: ProfileTextEnterView, status: Bool) {
        if status {
            let rightImageView = view.textField.rightView?.subviews[0] as? UIImageView
            rightImageView?.image = Image.iconArrowUpSmall.image
        } else {
            let rightImageView = view.textField.rightView?.subviews[0] as? UIImageView
            rightImageView?.image = Image.iconArrowDownSmall.image
        }
    }
}

extension PhotoPrintAddAdressPopup {
    static func with(address: AddressResponse?) -> PhotoPrintAddAdressPopup {
        let vc = controllerWith(address: address)
        return vc
    }
    
    private static func controllerWith(address: AddressResponse?) -> PhotoPrintAddAdressPopup {
        let vc = PhotoPrintAddAdressPopup(nibName: "PhotoPrintAddAdressPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.address = address
        return vc
    }
}

extension PhotoPrintAddAdressPopup: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == postaCodeView.textField {
            let currentCharacterCount = textField.text?.count ?? 0
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return newLength <= 5 && allowedCharacters.isSuperset(of: characterSet)
        } else if textField == adressTitleView.textField || textField == neighbourhoodView.textField || textField == streetView.textField || textField == nameView.textField {
            let currentCharacterCount = textField.text?.count ?? 0
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 100
        } else if textField == buildingNoView.textField || textField == apartmentNoView.textField {
            let currentCharacterCount = textField.text?.count ?? 0
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 10
        }
        return false
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
        cell.textLabel!.textColor = AppColor.borderColor.color
        cell.textLabel!.font = .appFont(.regular, size: 14)
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
            cityView.textField.textColor = AppColor.borderColor.color
            districtView.textField.text = localized(.selectCityDistrict)
            getDistrict(id: cityList?[indexPath.row].id ?? 1)
            isTextFieldEmpty()
            setTextArrowImage(view: cityView, status: false)
        } else {
            selectedDistrictId = districtList?[indexPath.row].id ?? 0
            districtView.textField.textColor = AppColor.borderColor.color
            districtView.textField.text = districtList?[indexPath.row].name ?? ""
            isTextFieldEmpty()
            setTextArrowImage(view: districtView, status: false)
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
    
    private func addAdress(addressName: String, recipientName: String, recipientNeighbourhood: String, recipientStreet: String, recipientBuildingNumber: String, recipientApartmentNumber: String, recipientCityId: Int, recipientDistrictId: Int, postalCode: Int, saveStatus: Bool) {
        showSpinner()
        service.photoPrintAddAddress(addressName: addressName, recipientName: recipientName, recipientNeighbourhood: recipientNeighbourhood, recipientStreet: recipientStreet, recipientBuildingNumber: recipientBuildingNumber, recipientApartmentNumber: recipientApartmentNumber, recipientCityId: recipientCityId, recipientDistrictId: recipientDistrictId, postalCode: postalCode, saveStatus: saveStatus) { [weak self] result in
            switch result {
            case .success(let response):
                self?.hideSpinner()
                self?.setLocalAddress(address: response)
                self?.dismiss(animated: false, completion: {
                    let vc = PhotoPrintSendPopup.with(address: response)
                    vc.openWithBlur()
                })
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.localizedDescription)
                self?.hideSpinner()
                break
            }
        }
    }
    
    private func updateAddress(id: Int, addressName: String, recipientName: String, recipientNeighbourhood: String, recipientStreet: String, recipientBuildingNumber: String, recipientApartmentNumber: String, recipientCityId: Int, recipientDistrictId: Int, postalCode: Int, saveStatus: Bool) {
        showSpinner()
        service.photoPrintUpdateAddress(id: id, addressName: addressName, recipientName: recipientName, recipientNeighbourhood: recipientNeighbourhood, recipientStreet: recipientStreet, recipientBuildingNumber: recipientBuildingNumber, recipientApartmentNumber: recipientApartmentNumber, recipientCityId: recipientCityId, recipientDistrictId: recipientDistrictId, postalCode: postalCode, saveStatus: saveStatus) { [weak self] result in
            switch result {               
            case .success(let response):
                self?.hideSpinner()
                self?.setLocalAddress(address: response)
                self?.dismiss(animated: false, completion: {
                    let vc = PhotoPrintSendPopup.with(address: response)
                    vc.openWithBlur()
                })
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.localizedDescription)
                self?.hideSpinner()
                break
            }
        }
    }
    
    private func setLocalAddress(address: AddressResponse) {
        localAddress = LocalAddress(id: address.id,addressName: address.name, nameSurname: address.recipientName, cityId: address.addressCity.id, city: address.addressCity.name, districtId: address.addressDistrict.id, district: address.addressDistrict.name, neighbourhood: address.neighbourhood, street: address.street, buildNo: address.buildingNumber, apartmentNo: address.apartmentNumber, postalCode: address.postalCode)
    }
    
}
