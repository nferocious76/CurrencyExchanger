//
//  ExchangerView.swift
//  CurrencyExchanger
//
//  Created by Neil Francis Hipona on 1/7/20.
//  Copyright © 2020 Neil Francis Hipona. All rights reserved.
//

import UIKit
import Foundation

protocol ExchangerViewDelegate: AnyObject {
    
    func exchangerView(view: ExchangerView, didChangeRate rate: String, andCurrency currency: String)
    func exchangerViewDidTapCurrency(view: ExchangerView)
}

class ExchangerView: UIView {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var inputTF: UITextField!
    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var dropdownIconView: UIImageView!
    @IBOutlet weak var dropdownButtonPlaceholder: UIButton!
    
    @IBOutlet weak var separatorLineView: UIView!
    
    weak var delegate: ExchangerViewDelegate?
    
    class func instance() -> ExchangerView? {
        
        let nib = UINib(nibName: "ExchangerView", bundle: .main)
        let instances = nib.instantiate(withOwner: nil, options: nil)
        guard let view = instances.first as? ExchangerView else {
            return nil
        }
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepare()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.layer.cornerRadius = iconView.frame.size.height / 2
    }
    
    func prepare() {
        
        backgroundColor = .white
        
        iconView.clipsToBounds = true
        titleLbl.text = ""
        
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
        let tool = UIToolbar(frame: rect)
        tool.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ExchangerView.done))]
        
        inputTF.inputAccessoryView = tool
        inputTF.text = "0"
        inputTF.keyboardType = .numberPad
        
    }
    
    @objc func done() {
        
        endEditing(true)
        
        delegate?.exchangerView(view: self, didChangeRate: inputTF.text ?? "0", andCurrency: currencyLbl.text ?? "")
    }
    
    // MARK: - Helper
    
    func set(_ icon: UIImage?, iconBGColor: UIColor = .white, title: String) {
        
        iconView.image = icon
        iconView.backgroundColor = iconBGColor
        titleLbl.text = title
    }
    
    var currency: String {
        set (c) {
            currencyLbl.text = c
        }
        get {
            return currencyLbl.text ?? ""
        }
    }
    
    var rate: String {
        get {
            return currencyLbl.text ?? ""
        }
    }
    
}
