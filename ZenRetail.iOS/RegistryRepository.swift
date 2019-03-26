//
//  RegistryRepository.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 29/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData

class RegistryRepository: RegistryProtocol {

	private let service: ServiceProtocol
	
	init() {
		service = IoCContainer.shared.resolve() as ServiceProtocol
	}
	
	func getAll(search: String) throws -> [(key: String, value: [Registry])] {
		let request: NSFetchRequest<Registry> = Registry.fetchRequest()
        if search.isEmpty {
			request.predicate = NSPredicate.init(format: "registryName <> ''")
        } else {
            request.predicate = NSPredicate.init(format: "registryName <> '' and registryName contains %@", search)
        }
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "registryName", ascending: true)
		request.sortDescriptors = [idDescriptor]
		
		return try service.context.fetch(request)
			.groupBy { $0.registryName![$0.registryName!.startIndex].description }
			.sorted { $0.key < $1.key }
	}

	func get(id: Int32) throws -> Registry? {
		let fetchRequest: NSFetchRequest<Registry> = Registry.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "registryId == \(id)")
		fetchRequest.fetchLimit = 1
		let object = try service.context.fetch(fetchRequest)
		
		return object.first
	}
	
	func add() throws -> Registry {
		let registry = Registry(context: service.context)
		registry.registryId = try self.newId()
		try service.context.save()
		
		return registry
	}
	
	func update(id: Int32, item: Registry) throws {
		let current = try self.get(id: id)!
		current.registryName = item.registryName
		current.registryEmail = item.registryEmail
		current.registryPhone = item.registryPhone
		current.registryAddress = item.registryAddress
		current.registryCity = item.registryCity
		current.registryZip = item.registryZip
        current.registryProvince = item.registryProvince
        current.registryCountry = item.registryCountry
		current.registryFiscalCode = item.registryFiscalCode
		current.registryVatNumber = item.registryVatNumber
		current.updatedAt = Int32.now()
		try service.context.save()
	}
	
	func delete(id: Int32) throws {
		let item = try self.get(id: id)
		service.context.delete(item!)
		try service.context.save()
	}
	
	private func newId() throws -> Int32 {
		var newId: Int32 = -1;
		
		let fetchRequest: NSFetchRequest<Registry> = Registry.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "registryId", ascending: true)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try service.context.fetch(fetchRequest)
		if(results.count == 1) {
			newId = results.first!.registryId - 1
		}
		
		return newId
	}
}
