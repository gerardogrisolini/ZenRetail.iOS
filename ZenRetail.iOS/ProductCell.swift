//
//  ProductCell.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/02/18.
//  Copyright © 2018 Gerardo Grisolini. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var labelCode: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

