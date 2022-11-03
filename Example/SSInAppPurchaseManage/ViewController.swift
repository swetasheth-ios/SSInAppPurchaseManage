//
//  ViewController.swift
//  SSInAppPurchaseManage
//
//  Created by Sweta Sheth on 11/03/2022.
//  Copyright (c) 2022 Sweta Sheth. All rights reserved.
//

import UIKit
import SSInAppPurchaseManage

class ViewController: UIViewController, InAppPurchaseProtocol {
    
    var sharedSecretKey: String = ""
    
    var inAppProducts: [String] = []
    var currentID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - InAppPurchaseProtocol Actions
    
    // TODO: - Purchase Product
    func purchaseProduct(productID: String) {
        //do something
    }
    
    // TODO: - Restore Product
    func restoreProduct() {
        //do something
    }
    
    // TODO: - Verify Each Product For Restore
    func verifyEachProductForRestore(productNo: Int) {
        //do something
    }
}

