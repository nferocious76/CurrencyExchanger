//
//  CurrencyCVCell.swift
//  CurrencyExchanger
//
//  Created by Neil Francis Hipona on 1/7/20.
//  Copyright © 2020 Neil Francis Hipona. All rights reserved.
//

import UIKit

class CurrencyCVCell: UICollectionViewCell {
    
    @IBOutlet weak var balanceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        balanceLbl.text = ""
    }
    
}
