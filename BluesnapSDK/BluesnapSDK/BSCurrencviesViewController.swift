//
//  BSCurrencviesViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 13/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSCurrenciesViewController: UITableViewController {
    
    // MARK: puclic properties
    
    // BS token for API call to load currency rates
    internal var bsToken: BSToken?
    // The currently selected currency code
    internal var selectedCurrencyCode : String = ""
    // the callback function that gets called when a currency is selected;
    // this ids just a default
    internal var updateFunc : (BSCurrency?, BSCurrency?)->Void = {
        oldCurrency, newCurrency in
        print("Currency \(newCurrency?.getCode()) was selected")
    }


    // MARK: private properties
    
    fileprivate var bsCurrencies : BSCurrencies?
    fileprivate var selectedCurrencyIndexPath : IndexPath?

    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get currencies data
        if let bsToken = bsToken {
            if (bsCurrencies == nil) {
                bsCurrencies = BSApiManager.getCurrencyRates(bsToken: bsToken)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = false
    }
    
    
    // MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    // return #rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let bsCurrencies = bsCurrencies {
            return bsCurrencies.currencies.count
        } else {
            return 0
        }
    }
    
    // "draw" a cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell", for: indexPath)
        guard let cell = reusableCell as? BSCurrencyTableViewCell else {
            fatalError("The cell item is not an instancre of the right class")
        }
        if let bsCurrency = bsCurrencies?.currencies[indexPath.row] {
            cell.CurrencyUILabel.text = bsCurrency.getName() + " " + bsCurrency.getCode()
            if (bsCurrency.getCode() == selectedCurrencyCode) {
                cell.CurrentUILabel.text = "V"
                selectedCurrencyIndexPath = indexPath
            } else {
                cell.CurrentUILabel.text = ""
            }
        }
        return cell
    }
    
    // When a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let bsCurrencies = bsCurrencies {
            var oldBsCurrency : BSCurrency?
            if let selectedCurrencyIndexPath = self.selectedCurrencyIndexPath {
                oldBsCurrency = bsCurrencies.currencies[selectedCurrencyIndexPath.row]
            }
            let newBsCurrency : BSCurrency = bsCurrencies.currencies[indexPath.row]
        
            selectedCurrencyCode = newBsCurrency.getCode()
        
            // deselect previous option
            if let selectedCurrencyIndexPath = self.selectedCurrencyIndexPath {
                self.tableView.reloadRows(at: [selectedCurrencyIndexPath], with: .none)
            }
        
            // select current option
            selectedCurrencyIndexPath = indexPath
            if let selectedCurrencyIndexPath = selectedCurrencyIndexPath {
                self.tableView.reloadRows(at: [selectedCurrencyIndexPath], with: .none)
            }
        
            // call updateFunc
            updateFunc(oldBsCurrency, newBsCurrency)
        }
    }
    
}
