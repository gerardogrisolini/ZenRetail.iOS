////
////  HttpClient.swift
////  iWebretail
////
////  Created by Gerardo Grisolini on 22/02/18.
////  Copyright © 2018 Gerardo Grisolini. All rights reserved.
////
//
//import Foundation
//
//struct Item : Decodable {
//    var id: String
//    var value: String
//}
//
//class HttpClient {
//
//    func get() {
//    
//        guard let url = URL(string: "https://www.webretail.cloud/api/ecommerce/product/anja") else {
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            
//            if let error = error {
//                print(error)
//                return
//            }
//            
//            guard let data = data else {
//                print("No data")
//                return
//            }
//            
//            do {
//                let item = try JSONDecoder().decode(Article.self, from: data)
//                print(item.productName)
//            }
//            catch let jsonErr {
//                print(jsonErr)
//            }
//
//        }.resume()
//    }
//}
