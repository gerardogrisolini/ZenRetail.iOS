//
//  MovementProtocol.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 16/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import CoreData

protocol MovementProtocol {
	
	//func getAll() throws -> [Movement]
	
	func getAllGrouped(date: Date?) throws -> [(key:String, value:[Movement])]
	
	func get(id: Int32) throws -> Movement?
	
	func newNumber(isPos: Bool) throws -> Int32
	
	func add() throws -> Movement
	
	func update(id: Int32, item: Movement) throws
	
	func delete(id: Int32) throws

	func getStore() throws -> Store?

	func getCausals() throws -> [Causal]
	
	func getPayments() -> [String]
}
