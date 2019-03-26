//
//  RegistryProtocol.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 29/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

protocol RegistryProtocol {
	
	func getAll(search: String) throws -> [(key: String, value: [Registry])]
	
	func get(id: Int32) throws -> Registry?
	
	func add() throws -> Registry
	
	func update(id: Int32, item: Registry) throws
	
	func delete(id: Int32) throws
}
