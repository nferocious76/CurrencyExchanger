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
    var exchangeRule: Int = 0 // default to 5: The first five currency exchanges are free of charge but afterwards they're charged 0.7% of the currency being traded.
    var exchangeMin: Float = 0.0
    var exchangeCount: Int = 0 // commission fee: 0.7%
    var isFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addNavButton()
        prepareUI()
        loadCurrency()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // create polling every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.loadCurrency()
        }

//        test
//        balance = ["EUR": 1000, "USD": 0, "CAD": 0, "AUD": 0]
//        rates = ["EUR": 1.4525, "USD": 137.3, "CAD": 0.85215, "AUD": 1.6119]
//        currencies = ["EUR", "USD", "CAD", "AUD"]
//
//        collectionView.reloadData()
    }

    // provide for the possibility of expanding the calculation of a more flexible commission. It is possible to come up with various new rules, for example - every tenth conversion is free, conversion of up to 200 Euros is free of charge etc.
    func addNavButton() {
        
        // 
        let addRule = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.addRule))
        navigationItem.rightBarButtonItem = addRule
        navigationItem.title = "Currency Converter"
    }
    
    @objc func addRule() {
        

        let alert = alertWithActions(title: "Add new rule", message: "Select rule to add", actions: [], style: .actionSheet)
        let addLimit = UIAlertAction(title: "Add Limit", style: .default) { (action) in
            // add exchange count for a free conversion
            
            let alert = self.alertWithActions(title: "Add Rule", message: "Set conversion count for a free of commission", actions: [], style: .alert)
            alert.addTextField { (tf) in
                tf.placeholder = "Add Limit"
                tf.keyboardType = .numberPad
            }
            
            let limit = UIAlertAction(title: "Add Limit", style: .default) { (a) in
                
                guard let tf = alert.textFields?[0], let l = tf.text else { return }
                self.exchangeRule = Int(l) ?? 0
            }
            alert.addAction(limit)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
        alert.addAction(addLimit)
        
        let addMin = UIAlertAction(title: "Add Minimum", style: .default) { (action) in
            // add exchange minimum amount for a free conversion
            
            let alert = self.alertWithActions(title: "Add Minimum", message: "Set minimum conversion for a free of commission", actions: [], style: .alert)
            alert.addTextField { (tf) in
                tf.placeholder = "Add Minimum"
                tf.keyboardType = .numberPad
            }
            
            let min = UIAlertAction(title: "Add Minimum", style: .default) { (a) in
                
                guard let tf = alert.textFields?[0], let m = tf.text else { return }
                self.exchangeMin = Float(m) ?? 0
            }
            alert.addAction(min)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)

        }
        alert.addAction(addMin)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func alertWithActions(title: String?, message: String?, actions: [UIAlertAction], style: UIAlertController.Style = .alert) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        for a in actions {
            alert.addAction(a)
        }
        
        return alert
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
        receive.set(#imageLiteral(resourceName: "arrow-down"), iconBGColor: .green, title: "Receive", inputPrefix: "+", inputColor: .green, currency: base)
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
        
        // refresh display
        collectionView.reloadData()
        pickerView.reloadAllComponents()
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
                
                // check if exchangeRule is hit for a free conversion rate -- or proceed to free for first 5 conversion
                var addCommission = true
                
                if exchangeMin > 0, f >= exchangeMin { // check if exchange min is hit for a free conversion
                    addCommission = false
                }
                else if exchangeRule > 0, exchangeCount % exchangeRule == 0 { // every exchange count hit -- free of conversion
                    addCommission = false
                }
                else{ // set default conversion fee
                     addCommission = exchangeCount > 5
                }
                
                let converted = f * r
                let conversionFee = f * 0.7
                let message = addCommission ? "You have converted \(sell.rate) \(sell.currency) to \(converted) \(receive.currency). Commission Fee - \(conversionFee) EUR." : "You have converted \(sell.rate) \(sell.currency) to \(converted) \(receive.currency)"
                
                // update balance
                let b = balance[sell.currency]!
                let newBal = addCommission ? b - (f + conversionFee) : b - f
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
        }else{
            receive.rate = ""
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

