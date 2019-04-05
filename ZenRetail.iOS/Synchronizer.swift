//
//  Syncronizer.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

typealias ServiceResponse = (Data?) -> Void
let kProgressUpdateNotification = "kProgressUpdateNotification"
//let kProgressViewTag = 10000

class Synchronizer {
	
	static let shared = Synchronizer()
	
    private let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
	private let service = IoCContainer.shared.resolve() as ServiceProtocol

	public var baseURL = "https://localhost/"
    var deviceToken: String = ""
	var isSyncing: Bool = false
	var movement: Movement!
	
	func iCloudUserIDAsync() {
		let container = CKContainer.default()
		container.fetchUserRecordID() {
			recordID, error in
			if error != nil {
				self.service.push(title: "Attention".locale, message: error!.localizedDescription)
			} else {
				self.deviceToken = recordID!.recordName
				//print("fetched ID \(self.deviceToken)")
                if let baseURL = self.iCloudKeyStore?.string(forKey: "webretailURL") {
                    Synchronizer.shared.baseURL = baseURL
                }
			}
		}
	}
	
    func registerServer(baseURL: String) {
        self.baseURL = baseURL
        
        iCloudKeyStore?.set(Synchronizer.shared.baseURL, forKey: "webretailURL")
        iCloudKeyStore?.synchronize()
    }
    
    func isConnected() -> Bool {
        return self.baseURL != "https://localhost/"
    }
    
	func syncronize() {
		if deviceToken.isEmpty { return }
		
		isSyncing = true
		
		let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
		fetchRequest.fetchLimit = 1
		let results = try! service.context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 0

		makeHTTPGetRequest(url: "api/devicefrom/\(date)", onCompletion: { data in
			if let usableData = data {
                do {
                    let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
                    
                    for item in items {
                        if self.deviceToken == item["deviceToken"] as! String {
                            let store = results.count == 1 ? results.first! : Store(context: self.service.context)
                            store.setJSONValues(json: item["store"] as! NSDictionary)
                            store.updatedAt = item["updatedAt"] as! Int32
                            self.service.save()
                        }
                    }
                } catch {
                    self.service.push(title: "ErrorSync".locale + " " + "store".locale, message: error.localizedDescription)
                }
			}

			self.syncCausals()
		})
		
		while isSyncing {
			usleep(1000000)
		}
	}

	internal func syncCausals() {
		let fetchRequest: NSFetchRequest<Causal> = Causal.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! service.context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 1
		
		makeHTTPGetRequest(url: "api/causalfrom/\(date)", onCompletion: { data in
			if let usableData = data {
                do {
                    let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
                    
                    for item in items {

                        let innerFetchRequest: NSFetchRequest<Causal> = Causal.fetchRequest()
                        innerFetchRequest.predicate = NSPredicate.init(format: "causalId == \(item["causalId"] as! Int32)")
                        innerFetchRequest.fetchLimit = 1
                        let object = try self.service.context.fetch(innerFetchRequest)
                        
                        let causal = object.count == 1 ? object.first! : Causal(context: self.service.context)
                        causal.setJSONValues(json: item)
                    }
                } catch {
                    self.service.push(title: "ErrorSync".locale + " " + "causal".locale, message: error.localizedDescription)
                }
                
                self.service.save()
            }
			
			self.syncRegistry()
		})
	}

	internal func syncRegistry() {
		let fetchRequest: NSFetchRequest<Registry> = Registry.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! service.context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 1
		
		makeHTTPGetRequest(url: "api/registryfrom/\(date)", onCompletion: { data in
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					let itemCount = items.count

                    for (index, item) in items.enumerated() {
                        
						let innerFetchRequest: NSFetchRequest<Registry> = Registry.fetchRequest()
						innerFetchRequest.predicate = NSPredicate.init(format: "registryId == \(item["registryId"] as! Int32)")
						innerFetchRequest.fetchLimit = 1
						let object = try self.service.context.fetch(innerFetchRequest)
						
						let registry = object.count == 1 ? object.first! : Registry(context: self.service.context)
						registry.setJSONValues(json: item)

                        self.service.save()

                        self.notify(total: itemCount, current: index + 1)
					}
				} catch {
					self.service.push(title: "ErrorSync".locale + " " + "registry".locale, message: error.localizedDescription)
				}
            }

			self.syncProducts()
		})
	}

	internal func syncProducts() {
		let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! service.context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 1
		
		makeHTTPGetRequest(url: "api/productfrom/\(date)", onCompletion: { data in
            if let usableData = data {
                do {
                    let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
                    let itemCount = items.count
                    
                    for (index, item) in items.enumerated() {
                        
                        if item["productIsActive"] as! Bool {
                            let innerFetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
                            innerFetchRequest.predicate = NSPredicate.init(format: "productId == \(item["productId"] as! Int32)")
                            innerFetchRequest.fetchLimit = 1
                            let object = try self.service.context.fetch(innerFetchRequest)
                            
                            let product = object.count == 1 ? object.first! : Product(context: self.service.context)
                            product.setJSONValues(json: item)
                            
                            for article in item["articles"] as! [NSDictionary] {
                                
                                let barcodes = article["barcodes"] as! [NSDictionary]
                                let barcode = barcodes.first(where: { ($0["tags"] as! [NSDictionary]).count == 0 })
                                let code = barcode?["barcode"] as? String ?? "***"
                                let request: NSFetchRequest<ProductArticle> = ProductArticle.fetchRequest()
                                request.predicate = NSPredicate.init(format: "articleBarcode == %@", code)
                                request.fetchLimit = 1
                                let rows = try self.service.context.fetch(request)
                                
                                let productArticle = rows.count == 1 ? rows.first! : ProductArticle(context: self.service.context)
                                productArticle.setJSONValues(json: article, attributes: item["attributes"] as! [NSDictionary], barcode: code)
                                productArticle.productId = product.productId
                            }
                            
                            self.service.save()
                        }
                        
                        self.notify(total: itemCount, current: index + 1)
                    }
                } catch {
                    self.service.push(title: "ErrorSync".locale + " " + "product".locale, message: error.localizedDescription)
                }
            }
            
			self.syncMovements()
		})
	}
    
    internal func syncMovements() {
        
        let firstRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
        firstRequest.sortDescriptors = [NSSortDescriptor(key: "movementId", ascending: false)]
        firstRequest.fetchLimit = 1
        let movementIds = try! service.context.fetch(firstRequest)
        var movementId = movementIds.count == 1 ? movementIds.first!.movementId + 1 : 1
        
        let secondRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
        secondRequest.sortDescriptors = [NSSortDescriptor(key: "movementArticleId", ascending: false)]
        secondRequest.fetchLimit = 1
        let movementArticleIds = try! service.context.fetch(secondRequest)
        var movementArticleId = movementArticleIds.count == 1 ? movementArticleIds.first!.movementArticleId + 1 : 1
        
        let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "synced == true")
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        let results = try! service.context.fetch(fetchRequest)
        let date = results.count == 1 ? results.first!.updatedAt : 1
        
        makeHTTPGetRequest(url: "api/movementfrom/\(date)", onCompletion: { data in
            if let usableData = data {
                do {
                    //print(String(data: usableData, encoding: .utf8)!)
                    let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
                    let itemCount = items.count
                    
                    let rows = items.enumerated()
                    for (index, item) in rows {
                        
                        let innerFetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
                        innerFetchRequest.fetchLimit = 1
                        innerFetchRequest.predicate = NSPredicate(format: "movementNumber == %@ AND movementDate == %@",
                                                                  argumentArray: [
                                                                      item["movementNumber"] as! Int32,
                                                                      (item["movementDate"] as! String).toDateShort()
                                                                  ])
                        let object = try self.service.context.fetch(innerFetchRequest)
                        let movement: Movement
                        if object.count == 0 {
                            movement = Movement(context: self.service.context)
                            movement.movementId = movementId
                            movement.synced = true
                            movement.completed = true
                            movementId += 1
                        } else {
                            movement = object.first!
                        }
                        movement.setJSONValues(json: item)
                        
                        for article in item["movementItems"] as! [NSDictionary] {
                            
                            let request: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
                            request.predicate = NSPredicate(format: "movementId == %@ AND movementArticleBarcode == %@",
                                                            argumentArray: [
                                                                movement.movementId,
                                                                article["movementArticleBarcode"] as! String
                                                            ])
                            request.fetchLimit = 1
                            let rows = try self.service.context.fetch(request)
                            
                            let movementArticle: MovementArticle
                            if rows.count == 0 {
                                movementArticle = MovementArticle(context: self.service.context)
                                movementArticle.movementId = movement.movementId
                                movementArticle.movementArticleId = movementArticleId
                                movementArticleId += 1
                            } else {
                                movementArticle = rows.first!
                            }
                            movementArticle.setJSONValues(json: article)
                        }
                        
                        self.service.save()

                        self.notify(total: itemCount, current: index + 1)
                    }
                } catch {
                    self.service.push(title: "ErrorSync".locale + " " + "movement".locale, message: error.localizedDescription)
                }
            }
            
            self.sendMovements()
        })
    }
    
    internal func sendMovements() {
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "completed == true AND synced == false")
		let items = try! service.context.fetch(fetchRequest)
		let count = items.count
		if count == 0 {
			self.notify(total: 0, current: 0)
			self.isSyncing = false
			return
		}
		
        for (index, item) in items.enumerated() {
			let rowsRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
			rowsRequest.predicate = NSPredicate.init(format: "movementId == \(item.movementId)")
			let rows = try! service.context.fetch(rowsRequest)
			let json = item.getJSONValues(rows: rows)
            
			makeHTTPPostRequest(url: "api/movement", body: json, onCompletion:  { data in
				if let usableData = data {
					do {
						let json = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! NSDictionary
						item.movementNumber = json["movementNumber"] as! Int32
						item.synced = true
					} catch {
						self.service.push(title: "ErrorSync".locale + " " + "movement".locale, message: error.localizedDescription)
					}

					if index + 1 == count {
						self.isSyncing = false
						self.service.save()
					}

					self.notify(total: count, current: index + 1)
				}
			})
		}
	}

	internal func makeHTTPGetRequest(url: String, onCompletion: @escaping ServiceResponse) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.setValue("*", forHTTPHeaderField: "Origin")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
		request.addValue("Basic \(UIDevice.current.name)#\(self.deviceToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
			if self.onResponse(response: response as? HTTPURLResponse, error: error) {
				onCompletion(data)
			}
		})
		task.resume()
	}
	
	internal func makeHTTPPostRequest(url: String, body: NSDictionary, onCompletion: @escaping ServiceResponse) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.setValue("*", forHTTPHeaderField: "Origin")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
		request.addValue("Basic \(UIDevice.current.name)#\(self.deviceToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "POST"
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
		} catch let error as NSError {
			print(error)
		}
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
			if self.onResponse(response: response as? HTTPURLResponse, error: error) {
				onCompletion(data)
			}
		})
		task.resume()
	}

	internal func onResponse(response: HTTPURLResponse?, error: Error?) -> Bool {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
		if error != nil {
			self.isSyncing = false
			service.push(title: "Error", message: error!.localizedDescription)
			return false
		}
		if response!.statusCode == 401 {
			self.isSyncing = false
			service.push(title: "Unauthorized".locale, message: "InvalidCredentials".locale)
			return false
		}
		return true
	}
	
	internal func notify(total: Int, current: Int) {
		let notification = ProgressNotification()
		notification.total = total
		notification.current = current
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProgressUpdateNotification), object: notification)
	}
}
