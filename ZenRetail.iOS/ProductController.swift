//
//  ProductController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 29/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import Kingfisher

class ProductController: UITableViewController, UISearchBarDelegate {
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	var products = [(key: String, value:[Product])]()
	private let repository: MovementArticleProtocol
	
	required init?(coder aDecoder: NSCoder) {
		repository = IoCContainer.shared.resolve() as MovementArticleProtocol
		
//        KingfisherManager.shared.cache.clearMemoryCache()
//        KingfisherManager.shared.cache.clearDiskCache()

        super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.contentOffset = CGPoint(x: 0, y: 44)
		searchBar.delegate = self

        products = try! repository.getProducts(search: "")
        self.tableView.prefetchDataSource = self
		self.tableView.reloadData()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		products = try! repository.getProducts(search: searchBar.text!)
		self.tableView.reloadData()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return products.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return products[section].key
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return products[section].value.count
	}

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         (cell as! ProductCell).imageProduct.kf.cancelDownloadTask()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let product = products[indexPath.section].value[indexPath.row]
        let c = cell as! ProductCell

        if let productImage = product.productImage, !productImage.isEmpty {
            let imageUrl = URL(string: Synchronizer.shared.baseURL + "thumb/" + productImage)!
            c.imageProduct.kf.setImage(
                with: imageUrl,
                placeholder: nil,
                options: [.transition(ImageTransition.fade(1))]
//                progressBlock: { receivedSize, totalSize in
//                    print("\(indexPath.row + 1): \(receivedSize)/\(totalSize)")
//                },
//                completionHandler: { image, error, cacheType, imageURL in
//                    print("\(indexPath.row + 1): Finished")
//                    DispatchQueue.main.async { cell.imageView?.setNeedsDisplay() }
//                }
            )
        }
        
        /*
        if let productImage = product.productImage, !productImage.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let imageData = try Data(contentsOf: imageUrl)
                    DispatchQueue.main.async {
                    //cell.imageView?.autoresizingMask = UIViewAutoresizing.flexibleHeight
                    //cell.imageView?.clipsToBounds = true
                    //cell.imageView?.frame = CGRect(x: 0 ,y: 0, width: 80, height: 80);
                    cell.imageView?.contentMode = .scaleAspectFill
                    cell.imageView?.image = UIImage(data: imageData)
                } catch {
                    print(error)
                }
            }
        }
        */
        
        c.labelCode.text = product.productCode!
        c.labelTitle.text = product.productName!
        c.labelSubtitle.text = product.productCategories!
        var price = product.productSelling.formatCurrency()
        if product.productDiscount > 0 {
            price += " -> " + product.productDiscount.formatCurrency()
        }
        c.labelPrice.text = price
    }

    
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.imageProduct.kf.indicatorType = .activity
        
		return cell
	}

	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let articleController: ArticleController = segue.destination as! ArticleController
		
		let indexPath = self.tableView?.indexPathForSelectedRow
		articleController.product = products[indexPath!.section].value[indexPath!.row]
	}
}

extension ProductController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap {
            URL(string: "\(Synchronizer.shared.baseURL)thumb/\(products[$0.section].value[$0.row].productImage!)")
        }
        
        ImagePrefetcher(urls: urls).start()
    }
}

