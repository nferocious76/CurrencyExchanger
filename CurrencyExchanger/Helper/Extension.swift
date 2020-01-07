//
//  View+Extension.swift
//  CurrencyExchanger
//
//  Created by Neil Francis Hipona on 1/7/20.
//  Copyright © 2020 Neil Francis Hipona. All rights reserved.
//

import UIKit
import Foundation

// MARK: - View

extension UIView {
    
    func pinToSuperView(view: UIView) {
        
        let lead = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trail = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        view.addConstraints([lead, trail, top, bottom])
    }
}
