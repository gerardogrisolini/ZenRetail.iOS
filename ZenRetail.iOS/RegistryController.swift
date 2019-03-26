//
//  RegistryController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 25/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class RegistryController: UITableViewController {

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var phoneTextField: UITextField!
	@IBOutlet weak var addressTextField: UITextField!
	@IBOutlet weak var cityTextField: UITextField!
	@IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var provinceTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
	@IBOutlet weak var fiscalcodeTextField: UITextField!
	@IBOutlet weak var vatnumberTextField: UITextField!
	
	public var registry: Registry!
	private let repository: RegistryProtocol
	
	required init?(coder aDecoder: NSCoder) {
		repository = IoCContainer.shared.resolve() as RegistryProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		
		if registry != nil {
			nameTextField.text = registry.registryName
			emailTextField.text = registry.registryEmail
			phoneTextField.text = registry.registryPhone
			addressTextField.text = registry.registryAddress
			cityTextField.text = registry.registryCity
			zipTextField.text = registry.registryZip
            provinceTextField.text = registry.registryProvince
			countryTextField.text = registry.registryCountry
			fiscalcodeTextField.text = registry.registryFiscalCode
			vatnumberTextField.text = registry.registryVatNumber
		}
    }
	
	@IBAction func saveButton(_ sender: UIBarButtonItem) {
		do {
			if registry == nil {
				registry = try repository.add()
			}
			registry.registryName = nameTextField.text
			registry.registryEmail = emailTextField.text
			registry.registryPhone = phoneTextField.text
			registry.registryAddress = addressTextField.text
			registry.registryCity = cityTextField.text
			registry.registryZip = zipTextField.text
            registry.registryProvince = provinceTextField.text
			registry.registryCountry = countryTextField.text
			registry.registryFiscalCode = fiscalcodeTextField.text
			registry.registryVatNumber = vatnumberTextField.text
			try repository.update(id: registry.registryId, item: registry)

			self.navigationController?.popViewController(animated: true)
		} catch {
			self.navigationController?.alert(title: "Error".locale, message: "\(error)")
		}
	}
}
