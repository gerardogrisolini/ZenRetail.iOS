//
//  ArticleController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 06/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import Kingfisher

class ArticleController: UITableViewController, UISearchBarDelegate {
	
    @IBOutlet weak var vBounceHeader: JYBounceHeader!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var buttonDone: UIButton!
    
    private let repository: MovementArticleProtocol

    var product: Product!
	var articles: [ProductArticle]!
	var filtered: [ProductArticle]!
	var barcodes: [String]
    
	required init?(coder aDecoder: NSCoder) {
		self.barcodes = []
        repository = IoCContainer.shared.resolve() as MovementArticleProtocol
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true

        if Synchronizer.shared.movement.completed {
			self.navigationItem.rightBarButtonItem?.isEnabled = false
		}
 
        let imageUrl = URL(string: "\(Synchronizer.shared.baseURL)media/\(product.productImage!)")!
        vBounceHeader.iv.kf.setImage(
            with: imageUrl,
            placeholder: nil,
            options: [],
            progressBlock: { receivedSize, totalSize in
            },
            completionHandler: { image, error, cacheType, imageURL in
                self.vBounceHeader.updateImageView()
            }
        )
        
        self.vBounceHeader.bringSubview(toFront: self.searchBar)
        self.vBounceHeader.bringSubview(toFront: self.buttonDone)
        
        //navigationItem.title = product.productName
		searchBar.delegate = self
		articles = try! repository.getArticles(productId: product.productId)
		filtered = articles
		self.tableView.reloadData()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty {
			filtered = articles
		} else {
			filtered = articles.filter({ (item) -> Bool in
				let tmp: ProductArticle = item
				return tmp.articleAttributes!.contains(searchText) || tmp.articleBarcode!.contains(searchText)
			})
		}
		self.tableView.reloadData()
	}
	
	// MARK: - Table view data source
	
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        vBounceHeader.scrollViewDidScroll(scrollView.contentOffset)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(product.productCode!): \(product.productName!)"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filtered.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
		
		let item = filtered[indexPath.row]
//        if item.articleAttributes!.isEmpty {
//            cell.textLabel?.text = item.articleBarcode
//            cell.detailTextLabel?.text = product.productName
//        } else {
            cell.textLabel?.text = item.articleAttributes
            cell.detailTextLabel?.text = item.articleBarcode
//        }
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) {
			let barcode = filtered[indexPath.row].articleBarcode!
			if cell.accessoryType == .checkmark {
				cell.accessoryType = .none
				let index = barcodes.index(of: barcode)
				barcodes.remove(at: index!)
			} else {
				cell.accessoryType = .checkmark
				barcodes.append(barcode)
			}
		}
	}

	@IBAction func doneButton(_ sender: UIButton) {
		do {
			for barcode in barcodes {
				_ = try repository.add(barcode: barcode, movementId: Synchronizer.shared.movement.movementId)
			}
		} catch {
			print("\(error)")
		}

		let composeViewController = self.navigationController?.viewControllers[1] as! UITabBarController
        composeViewController.selectedIndex = barcodes.count == 0 ? 2 : 0
		self.navigationController?.popToViewController(composeViewController, animated: true)
        navigationController?.isNavigationBarHidden = false
	}
}
