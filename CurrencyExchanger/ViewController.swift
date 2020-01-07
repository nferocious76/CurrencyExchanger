//
//  ViewController.swift
//  CurrencyExchanger
//
//  Created by Neil Francis Hipona on 1/7/20.
//  Copyright © 2020 Neil Francis Hipona. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ExchangerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var sellView: UIView!
    @IBOutlet weak var receiveiew: UIView!
    
    lazy var sell: ExchangerView! = {
        return ExchangerView.instance()
    }()
    
    lazy var receive: ExchangerView! = {
        return ExchangerView.instance()
    }()
    
    fileprivate var activeExchange: ExchangerView?
    
    var balance: [String: Float] = ["EUR": 1000]
    var base: String = "EUR"
    var rates: [String: NSNumber] = [:]
    var currencies: [String] = ["EUR"]
    var exchangeCount: Int = 0 // commission fee: 0.7%
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCurrency()

//        test
//        balance = ["EUR": 1000, "USD": 0, "CAD": 0, "AUD": 0]
//        rates = ["EUR": 1.4525, "USD": 137.3, "CAD": 0.85215, "AUD": 1.6119]
//        currencies = ["EUR", "USD", "CAD", "AUD"]
        
        collectionView.reloadData()
    }

    func prepareUI() {
        
        sellView.backgroundColor = .white
        receiveiew.backgroundColor = .white

        sell.delegate = self
        sell.pinToSuperView(view: sellView)
        sell.set(#imageLiteral(resourceName: "arrow-up"), iconBGColor: .red, title: "Sell", currency: base)
        sell.setDisabled(input: false, currency: true)
        
        receive.delegate = self
        receive.pinToSuperView(view: receiveiew)
        receive.set(#imageLiteral(resourceName: "arrow-down"), iconBGColor: .green, title: "Receive", currency: base)
        receive.setDisabled(currency: false)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.clipsToBounds = true
        submitButton.layer.cornerRadius = submitButton.frame.size.height / 2
        submitButton.backgroundColor = .blue
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        pickerView.isHidden = true
    }
    
    @IBAction func submit(_ sender: UIButton) {
        view.endEditing(true)
        
        // check and convert
        if sell.currency == receive.currency {
            return showAlert(title: "Error", message: "Can't convert to same currency")
        }
        else if let balance = balance[sell.currency], Float(sell.rate) ?? 0 > balance {
            return showAlert(title: "Error", message: "You don't have enough money")
        }
        else{
            if let r = rates[receive.currency]?.floatValue {
                exchangeCount += 1 // update exchange count
                
                guard let f = Float(sell.rate) else {
                    return showAlert(title: "Error", message: "Convertion failed")
                }
                
                let converted = f * r
                let message = exchangeCount > 5 ? "You have converted \(sell.rate) \(sell.currency) to \(converted) \(receive.currency). Commission Fee - 0.70 EUR." : "You have converted \(sell.rate) \(sell.currency) to \(converted) \(receive.currency)"
                
                // update balance
                let b = balance[sell.currency]!
                let newBal = exchangeCount > 5 ? b - (f + f * 0.7) : b - f
                balance[sell.currency] = newBal
                
                if let bal = balance[receive.currency] {
                    balance[receive.currency] = bal + converted
                }
                
                sell.rate = ""
                receive.rate = ""
                
                collectionView.reloadData()

                return showAlert(title: "Currency Converted", message: message)
            }
        }
    }
    
    // MARK: - ExchangerViewDelegate
    
    func exchangerView(view: ExchangerView, didChangeRate rate: String, andCurrency currency: String) {
        
        // convert rate to receive
        if let f = Float(rate) {
            if let r = rates[receive.currency]?.floatValue {
                receive.rate = "\(f * r)"
            }
        }
    }
    
    func exchangerViewDidTapCurrency(view: ExchangerView) {
        self.view.endEditing(true)
        activeExchange = view
        pickerView.isHidden = false
    }

    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return currencies.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        if let exchange = activeExchange {
            let currency = currencies[row]
            exchange.currency = currency
            
            // convert
            if let r = rates[currency]?.floatValue, let f = Float(sell.rate) {
                exchange.rate = "\(f * r)"
            }
        }
        
        pickerView.isHidden = true
    }
}

