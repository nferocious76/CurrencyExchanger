//
//  ViewController+Extension.swift
//  CurrencyExchanger
//
//  Created by Neil Francis Hipona on 1/7/20.
//  Copyright © 2020 Neil Francis Hipona. All rights reserved.
//

import Foundation
import Alamofire

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func loadCurrency() {
        
        Alamofire.request("https://api.exchangeratesapi.io/latest").responseJSON(completionHandler: { (data) in
            print(data)
            
            if data.result.isSuccess {
                if let obj = data.result.value as? [String: AnyObject] {
                    if let b = obj["base"] as? String {
                        self.base = b
                        
                        if self.isFirstLoad { // this is probably first load -- default value
                            self.balance = [b: 1000] // reset rate

                            self.sell.currency = b
                            self.receive.currency = b
                        }
                    }
                    
                    if let r = obj["rates"] as? [String: NSNumber] {
                        self.rates = r

                        for (key, _) in r {
                            self.currencies.append(key)
                            
                            if self.isFirstLoad {
                                self.balance[key] = 0
                            }
                        }
                    }
                }
                
                self.isFirstLoad = false // prevent data reset on success update
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.pickerView.reloadAllComponents()
            }
        })
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrencyCVCell", for: indexPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        let c = currencies[indexPath.row]
        let bal = balance[c]!
        
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 22)
        let attrib : [NSAttributedString.Key : Any] = [kCTFontAttributeName as NSAttributedString.Key: UIFont.systemFont(ofSize: 17)]
        let currencyLbl = "\(bal) \(c)"
        let boundingRect = currencyLbl.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attrib, context: nil)
        let maxWidth = boundingRect.size.width + 20
        
        return CGSize(width: maxWidth, height: 30)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
     
        let cur = currencies[indexPath.row]
        let bal = balance[cur]!
        
        let c = cell as! CurrencyCVCell
        c.balanceLbl.text = "\(bal) \(cur)"
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}
