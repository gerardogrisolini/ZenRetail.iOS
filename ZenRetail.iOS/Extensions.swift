//
//  Extensions.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

extension UINavigationController {
	func alert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension Int32 {
	static func now() -> Int32 {
		return Int32(Date.timeIntervalSinceReferenceDate)
	}
}

extension Double {
	func formatCurrency() -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 2;
		formatter.locale = Locale.current
		let result = formatter.string(from: self as NSNumber);
		
		return result!
	}
}

extension String {
    var locale: String {
        let string = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        return string
    }
    
    func toDateInput() -> Date {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.date(from: self)!
	}
	
	func toDateShort(format: String = "yyyy-MM-dd") -> Date {
        let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.date(from: self) ?? Date()
	}
	
	func getJSONValues() -> NSDictionary {
        if self.isEmpty { return NSDictionary() }
        
		let jsonData = self.data(using: String.Encoding.utf8)
        return try! JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves) as! NSDictionary
	}
}

extension NSDictionary {
	func getJSONString() -> String {
		let jsonData = try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
		return String(bytes: jsonData, encoding: String.Encoding.utf8)!
	}
}

extension Date {
	func formatDateInput() -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.string(from: self as Date)
	}
	
	func formatDateShort() -> String {
		return formatDate(format: "yyyy-MM-dd")
	}
	
	func formatDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.string(from: self as Date)
	}
}

extension NSData {
    func castToCPointer<T>() -> T {
        let mem = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T.Type>.size)
        self.getBytes(mem, length: MemoryLayout<T.Type>.size)
        return mem.move()
    }
}

extension Store {
	func setJSONValues(json: NSDictionary) {
		self.storeId = json["storeId"] as! Int32
		self.storeName = json["storeName"] as? String ?? ""
		self.storeAddress = json["storeAddress"] as? String ?? ""
		self.storeCity = json["storeCity"] as? String ?? ""
		self.storeZip = json["storeZip"] as? String ?? ""
		self.storeCountry = json["storeCountry"] as? String ?? ""
		self.updatedAt = json["updatedAt"] as! Int32
	}
	
	func getJSONValues() -> NSDictionary {
		return [
			"storeId": self.storeId,
			"storeName": self.storeName!,
			"storeAddress":	self.storeAddress!,
			"storeCity": self.storeCity!,
			"storeCountry": self.storeCountry!,
			"storeZip": self.storeZip!,
			"updatedAt": self.updatedAt
		]
	}
}

extension Causal {
	func setJSONValues(json: NSDictionary) {
		self.causalId = json["causalId"] as! Int32
		self.causalName = json["causalName"] as? String ?? ""
		self.causalIsPos = json["causalIsPos"] as? Bool ?? false
		self.causalQuantity = json["causalQuantity"] as! Int32
		self.causalBooked = json["causalBooked"] as! Int32
		self.updatedAt = json["updatedAt"] as! Int32
	}
	
	func getJSONValues() -> NSDictionary {
		return [
			"causalId": self.causalId,
			"causalName": self.causalName!,
			"causalQuantity": self.causalQuantity,
			"causalBooked": self.causalBooked,
			"causalIsPos": self.causalIsPos,
			"updatedAt": self.updatedAt
		]
	}
}

extension Registry {
	func setJSONValues(json: NSDictionary) {
		self.registryId = json["registryId"] as! Int32
		self.registryName = json["registryName"] as? String ?? ""
		self.registryEmail = json["registryEmail"] as? String ?? ""
		self.registryPhone = json["registryPhone"] as? String ?? ""
		self.registryAddress = json["registryAddress"] as? String ?? ""
		self.registryCity = json["registryCity"] as? String ?? ""
		self.registryZip = json["registryZip"] as? String ?? ""
        self.registryProvince = json["registryProvince"] as? String ?? ""
        self.registryCountry = json["registryCountry"] as? String ?? ""
		self.registryFiscalCode = json["registryFiscalCode"] as? String ?? ""
		self.registryVatNumber = json["registryVatNumber"] as? String ?? ""
		self.updatedAt = json["updatedAt"] as! Int32
	}

	func getJSONValues() -> NSDictionary {
		return [
			"registryId": self.registryId,
			"registryName": self.registryName!,
			"registryEmail": self.registryEmail!,
			"registryPhone": self.registryPhone!,
			"registryAddress": self.registryAddress!,
			"registryCity": self.registryCity!,
			"registryZip": self.registryZip!,
            "registryProvince": self.registryProvince!,
			"registryCountry": self.registryCountry!,
			"registryFiscalCode": self.registryFiscalCode!,
			"registryVatNumber": self.registryVatNumber!,
			"updatedAt": self.updatedAt
		]
	}
}

extension Product {
	func setJSONValues(json: NSDictionary) {
		self.productId = json["productId"] as! Int32
		self.productCode = json["productCode"] as? String ?? ""
		self.productName = json["productName"] as? String ?? ""
        self.productUm = json["productUm"] as? String ?? ""
        let media = (json["medias"] as! [NSDictionary]).first
        self.productImage = media?["name"] as? String ?? ""
        let price = json["price"] as? NSDictionary
        self.productSelling = price?["selling"] as? Double ?? 0
		let discount = json["discount"] as? NSDictionary
		self.productDiscount = discount?["price"] as? Double ?? 0
		let brand = json["brand"] as! NSDictionary
		self.productBrand = brand["brandName"] as? String ?? ""
		self.updatedAt = json["updatedAt"] as! Int32
        
        self.productCategories = ""
		for productCategory in json["categories"] as! [NSDictionary] {
			let category = productCategory["category"] as! NSDictionary
			self.productCategories!.append("\(category["categoryName"]!) ")
		}
	}
}

extension ProductArticle {
    func setJSONValues(json: NSDictionary, attributes: [NSDictionary], barcode: String) {
		self.articleId = json["articleId"] as! Int32
        self.articleBarcode = barcode
		var values = [Int:String]()
		for attribute in attributes {
			for attributeValue in attribute["attributeValues"] as! [NSDictionary] {
				let value = attributeValue["attributeValue"] as! NSDictionary
				values.updateValue(value["attributeValueName"] as! String, forKey: value["attributeValueId"] as! Int)
			}
		}
		self.articleAttributes = ""
		for attributeValue in json["attributeValues"] as! [NSDictionary] {
			let value = values[attributeValue["attributeValueId"] as! Int]
			self.articleAttributes!.append("\(value!) ")
		}
	}
}

extension Movement {
    func setJSONValues(json: NSDictionary) {
        self.movementNumber = json["movementNumber"] as! Int32
        self.movementDate = (json["movementDate"] as! String).toDateShort()
        self.movementNote = json["movementNote"] as? String ?? ""
        self.movementStatus = json["movementStatus"] as? String ?? ""
        self.movementUser = json["movementUser"] as? String ?? ""
        self.movementDevice = json["movementDevice"] as? String ?? ""
        self.movementPayment = json["movementPayment"] as? String ?? ""
        let store = json["movementStore"] as? NSDictionary
        self.movementStore = store?.getJSONString()
        let causal = json["movementCausal"] as? NSDictionary
        self.movementCausal = causal?.getJSONString()
        let registry = json["movementRegistry"] as? NSDictionary
        self.movementRegistry = registry?.getJSONString()
        self.movementAmount = json["movementAmount"] as! Double
        self.updatedAt = json["updatedAt"] as! Int32
    }
    
    func getJSONValues(rows: [MovementArticle]) -> NSDictionary {
		var items = [NSDictionary]()
		for row in rows {
			items.append([
				"movementArticleBarcode": row.movementArticleBarcode!,
				"movementArticleQuantity": row.movementArticleQuantity,
                "movementArticleDelivered": 0.0,
				"movementArticlePrice": row.movementArticlePrice
            ])
		}
        
        let response = [
            "movementNumber": self.movementNumber,
            "movementDate": self.movementDate!.formatDateShort(),
            "movementNote": self.movementNote!,
            "movementStatus": self.movementStatus!,
            "movementUser": self.movementUser!,
            "movementDevice": self.movementDevice!,
            "movementStore": self.movementStore!.getJSONValues(),
            "movementCausal": self.movementCausal!.getJSONValues(),
            "movementPayment": self.movementPayment!,
            "movementItems": items
        ] as NSDictionary
        
        if self.movementRegistry != nil {
            response.setValue(self.movementRegistry!.getJSONValues(), forKey: "movementRegistry")
        }
        
		return response
	}
}

extension MovementArticle {
    func setJSONValues(json: NSDictionary) {
        self.movementArticleBarcode = json["movementArticleBarcode"] as? String ?? ""
        self.movementArticleQuantity = json["movementArticleQuantity"] as! Double
        self.movementArticlePrice = json["movementArticlePrice"] as! Double
        let product = json["movementArticleProduct"] as? NSDictionary
        
        var values = [Int:String]()
        for attribute in product?["attributes"] as! [NSDictionary] {
            for attributeValue in attribute["attributeValues"] as! [NSDictionary] {
                let value = attributeValue["attributeValue"] as! NSDictionary
                values.updateValue(value["attributeValueName"] as! String, forKey: value["attributeValueId"] as! Int)
            }
        }
        self.movementProduct = product?["productName"] as? String ?? ""
        let article = (product?["articles"] as! [NSDictionary]).first
        if let article = article {
            for attributeValue in article["attributeValues"] as! [NSDictionary] {
                let value = values[attributeValue["attributeValueId"] as! Int]
                self.movementProduct?.append(" \(value!)")
            }
        }
    }
}

extension Sequence {
	func groupBy<G>(closure: (Iterator.Element)->G) -> [G: [Iterator.Element]] {
		var results = [G: Array<Iterator.Element>]()
		forEach {
			let key = closure($0)
			if var array = results[key] {
				array.append($0)
				results[key] = array
			}
			else {
				results[key] = [$0]
			}
		}
		return results
	}
}

extension UIColor {
	public convenience init?(hexString: String) {
		let r, g, b, a: CGFloat
		
		if hexString.hasPrefix("#") {
			let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString[start...]
			
			if hexColor.count == 8 {
                let scanner = Scanner(string: String(hexColor))
				var hexNumber: UInt64 = 0
				
				if scanner.scanHexInt64(&hexNumber) {
					r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
					g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
					b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
					a = CGFloat(hexNumber & 0x000000ff) / 255
					
					self.init(red: r, green: g, blue: b, alpha: a)
					return
				}
			}
		}
		
		return nil
	}
    
	public convenience init?(name: String) {
		let allColors = [
			"aliceblue": "#F0F8FFFF",
			"antiquewhite": "#FAEBD7FF",
			"aqua": "#00FFFFFF",
			"aquamarine": "#7FFFD4FF",
			"azure": "#F0FFFFFF",
			"beige": "#F5F5DCFF",
			"bisque": "#FFE4C4FF",
			"black": "#000000FF",
			"blanchedalmond": "#FFEBCDFF",
			"blue": "#0000FFFF",
			"blueviolet": "#8A2BE2FF",
			"brown": "#A52A2AFF",
			"burlywood": "#DEB887FF",
			"cadetblue": "#5F9EA0FF",
			"chartreuse": "#7FFF00FF",
			"chocolate": "#D2691EFF",
			"coral": "#FF7F50FF",
			"cornflowerblue": "#6495EDFF",
			"cornsilk": "#FFF8DCFF",
			"crimson": "#DC143CFF",
			"cyan": "#00FFFFFF",
			"darkblue": "#00008BFF",
			"darkcyan": "#008B8BFF",
			"darkgoldenrod": "#B8860BFF",
			"darkgray": "#A9A9A9FF",
			"darkgrey": "#A9A9A9FF",
			"darkgreen": "#006400FF",
			"darkkhaki": "#BDB76BFF",
			"darkmagenta": "#8B008BFF",
			"darkolivegreen": "#556B2FFF",
			"darkorange": "#FF8C00FF",
			"darkorchid": "#9932CCFF",
			"darkred": "#8B0000FF",
			"darksalmon": "#E9967AFF",
			"darkseagreen": "#8FBC8FFF",
			"darkslateblue": "#483D8BFF",
			"darkslategray": "#2F4F4FFF",
			"darkslategrey": "#2F4F4FFF",
			"darkturquoise": "#00CED1FF",
			"darkviolet": "#9400D3FF",
			"deeppink": "#FF1493FF",
			"deepskyblue": "#00BFFFFF",
			"dimgray": "#696969FF",
			"dimgrey": "#696969FF",
			"dodgerblue": "#1E90FFFF",
			"firebrick": "#B22222FF",
			"floralwhite": "#FFFAF0FF",
			"forestgreen": "#228B22FF",
			"fuchsia": "#FF00FFFF",
			"gainsboro": "#DCDCDCFF",
			"ghostwhite": "#F8F8FFFF",
			"gold": "#FFD700FF",
			"goldenrod": "#DAA520FF",
			"gray": "#808080FF",
			"grey": "#808080FF",
			"green": "#008000FF",
			"greenyellow": "#ADFF2FFF",
			"honeydew": "#F0FFF0FF",
			"hotpink": "#FF69B4FF",
			"indianred": "#CD5C5CFF",
			"indigo": "#4B0082FF",
			"ivory": "#FFFFF0FF",
			"khaki": "#F0E68CFF",
			"lavender": "#E6E6FAFF",
			"lavenderblush": "#FFF0F5FF",
			"lawngreen": "#7CFC00FF",
			"lemonchiffon": "#FFFACDFF",
			"lightblue": "#ADD8E6FF",
			"lightcoral": "#F08080FF",
			"lightcyan": "#E0FFFFFF",
			"lightgoldenrodyellow": "#FAFAD2FF",
			"lightgray": "#D3D3D3FF",
			"lightgreen": "#90EE90FF",
			"lightpink": "#FFB6C1FF",
			"lightsalmon": "#FFA07AFF",
			"lightseagreen": "#20B2AAFF",
			"lightskyblue": "#87CEFAFF",
			"lightslategrey": "#778899FF",
			"lightsteelblue": "#B0C4DEFF",
			"lightyellow": "#FFFFE0FF",
			"lime": "#00FF00FF",
			"limegreen": "#32CD32FF",
			"linen": "#FAF0E6FF",
			"magenta": "#FF00FFFF",
			"maroon": "#800000FF",
			"mediumaquamarine": "#66CDAAFF",
			"mediumblue": "#0000CDFF",
			"mediumorchid": "#BA55D3FF",
			"mediumpurple": "#9370D8FF",
			"mediumseagreen": "#3CB371FF",
			"mediumslateblue": "#7B68EEFF",
			"mediumspringgreen": "#00FA9AFF",
			"mediumturquoise": "#48D1CCFF",
			"mediumvioletred": "#C71585FF",
			"midnightblue": "#191970FF",
			"mintcream": "#F5FFFAFF",
			"mistyrose": "#FFE4E1FF",
			"moccasin": "#FFE4B5FF",
			"navajowhite": "#FFDEADFF",
			"navy": "#000080FF",
			"oldlace": "#FDF5E6FF",
			"olive": "#808000FF",
			"olivedrab": "#6B8E23FF",
			"orange": "#FFA500FF",
			"orangered": "#FF4500FF",
			"orchid": "#DA70D6FF",
			"palegoldenrod": "#EEE8AAFF",
			"palegreen": "#98FB98FF",
			"paleturquoise": "#AFEEEEFF",
			"palevioletred": "#D87093FF",
			"papayawhip": "#FFEFD5FF",
			"peachpuff": "#FFDAB9FF",
			"peru": "#CD853FFF",
			"pink": "#FFC0CBFF",
			"plum": "#DDA0DDFF",
			"powderblue": "#B0E0E6FF",
			"purple": "#800080FF",
			"rebeccapurple": "#663399FF",
			"red": "#FF0000FF",
			"rosybrown": "#BC8F8FFF",
			"royalblue": "#4169E1FF",
			"saddlebrown": "#8B4513FF",
			"salmon": "#FA8072FF",
			"sandybrown": "#F4A460FF",
			"seagreen": "#2E8B57FF",
			"seashell": "#FFF5EEFF",
			"sienna": "#A0522DFF",
			"silver": "#C0C0C0FF",
			"skyblue": "#87CEEBFF",
			"slategray": "#708090FF",
			"slategrey": "#708090FF",
			"snow": "#FFFAFAFF",
			"springgreen": "#00FF7FFF",
			"steelblue": "#4682B4FF",
			"tan": "#D2B48CFF",
			"teal": "#008080FF",
			"thistle": "#D8BFD8FF",
			"tomato": "#FF6347FF",
			"turquoise": "#40E0D0FF",
			"violet": "#EE82EEFF",
			"wheat": "#F5DEB3FF",
			"white": "#FFFFFFFF",
			"whitesmoke": "#F5F5F5FF",
			"yellow": "#FFFF00FF",
			"yellowgreen": "#9ACD32FF"
		]
		
		let cleanedName = name.replacingOccurrences(of: " ", with: "").lowercased()
		
		if let hexString = allColors[cleanedName] {
			self.init(hexString: hexString)
		} else {
			return nil
		}
     }
}
