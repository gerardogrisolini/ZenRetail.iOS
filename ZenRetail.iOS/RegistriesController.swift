//
//  RegistriesController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 24/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class RegistriesController: UITableViewController, UISearchBarDelegate {

	@IBOutlet weak var searchBar: UISearchBar!
	
	var registries = [(key: String, value: [Registry])]()
	private let repository: RegistryProtocol
	
	required init?(coder aDecoder: NSCoder) {
		repository = IoCContainer.shared.resolve() as RegistryProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.contentOffset = CGPoint(x: 0, y: 44)
		searchBar.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		registries = try! repository.getAll(search: "")
		self.tableView.reloadData()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		registries = try! repository.getAll(search: searchText)
		self.tableView.reloadData()
	}

	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return registries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registries[section].value.count
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return registries[section].key
	}

	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return registries.map { $0.key }
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegistryCell", for: indexPath)

		let item = registries[indexPath.section].value[indexPath.row]
		cell.textLabel?.text = item.registryName
		cell.detailTextLabel?.text = item.registryEmail

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let movement = Synchronizer.shared.movement!
		if !movement.completed {
			let item = registries[indexPath.section].value[indexPath.row]
			movement.movementRegistry = item.getJSONValues().getJSONString()
			navigationController?.popViewController(animated: true)
		}
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let item = registries[indexPath.section].value[indexPath.row]
		let delete = UITableViewRowAction(style: .destructive, title: "Delete".locale) { action, index in
			do {
				try self.repository.delete(id: item.registryId)
				self.registries[indexPath.section].value.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .fade)
			} catch {
				self.navigationController?.alert(title: "Error".locale, message: "\(error)")
			}
		}

		let edit = UITableViewRowAction(style: .normal, title: "Edit".locale) { action, index in
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let vc = storyboard.instantiateViewController(withIdentifier: "RegistryView") as! RegistryController
			vc.registry = item
			self.navigationController!.pushViewController(vc, animated: true)
		}
		
		return [delete, edit]
	}
}
