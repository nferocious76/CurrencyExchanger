//
//  ViewController.swift
//  CurrencyExchanger
//
//  Created by Neil Francis Hipona on 1/7/20.
//  Copyright © 2020 Neil Francis Hipona. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ExchangerViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var sellView: UIView!
    @IBOutlet weak var receiveiew: UIView!
    
    fileprivate lazy var sell: ExchangerView? = {
        return ExchangerView.instance()
    }()
    
    fileprivate lazy var receive: ExchangerView? = {
        return ExchangerView.instance()
    }()
    
    var currencies: [[String: Float]] = [["EUR": 1000]]
    var base: String = "EUR"
    var rates: [String: NSNumber] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        loadCurrency()
        
        currencies = [["EUR": 1000], ["EUR": 1001], ["EUR": 1020], ["EUR": 1030]]
        collectionView.reloadData()
    }

    func prepareUI() {
        
        sellView.backgroundColor = .white
        receiveiew.backgroundColor = .white
        
        if let s = sell {
            s.pinToSuperView(view: sellView)
            s.set(#imageLiteral(resourceName: "arrow-up"), iconBGColor: .red, title: "Sell")
        }
    
        if let r = receive {
            r.pinToSuperView(view: receiveiew)
            r.set(#imageLiteral(resourceName: "arrow-down"), iconBGColor: .green, title: "Receive")
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
    }
    
    // MARK: - ExchangerViewDelegate
    
    func exchangerView(view: ExchangerView, didChangeRate rate: String, andCurrency currency: String) {
        
        
    }
    
    func exchangerViewDidTapCurrency(view: ExchangerView) {
        
    }

}

