//
//  SSInAppPurchaseManage.swift
//
//  Created by Sweta Sheth
//

import UIKit
import StoreKit
import SwiftyStoreKit

public enum PurchaseStatus {
    case purchased(isInTrialPeriod: Bool)
    case expired(isInTrialPeriod: Bool)
    case notPurchased
}

public typealias PurchaseSuccessBlock = (SKPaymentTransaction)
public typealias PurchaseErrorBlock = (errorCode: SKError.Code, errorMessage: String)

public typealias RestoreBlock = (isSuccess: Bool, message: String)

public typealias VerifyPurchaseSuccessBlock = (PurchaseStatus)
public typealias VerifyPurchaseErrorBlock = (String)

// MARK: - InAppPurchaseManageProtocol

public protocol InAppPurchaseManageProtocol: AnyObject {
    
    var sharedSecretKey: String { get set }
    
    var inAppProducts: [String] { get set }
    var currentID: String { get set }
    
    func getPriceInfo(completion : @escaping ([SKProduct]) -> Void)
    
    func purchase(atomically: Bool, completionBlock: @escaping (PurchaseSuccessBlock) -> Void, errorBlock: @escaping (PurchaseErrorBlock) -> Void)
    func restorePurchases(atomically: Bool, completionBlock: @escaping (RestoreBlock) -> Void)
    
    func verifyPurchase(completionBlock: @escaping (VerifyPurchaseSuccessBlock) -> Void, errorBlock: @escaping (VerifyPurchaseErrorBlock) -> Void)
}

extension InAppPurchaseManageProtocol {
    
    // TODO: - Get Price Info
    
    public func getPriceInfo(completion: @escaping ([SKProduct]) -> Void) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo(Set(self.inAppProducts)) { results in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            completion(Array(results.retrievedProducts))
        }
    }
    
    // TODO: - Product Purchase
    
    public func purchase(atomically: Bool = true, completionBlock: @escaping (PurchaseSuccessBlock) -> Void, errorBlock: @escaping (PurchaseErrorBlock) -> Void) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(self.currentID, atomically: atomically) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            
            switch result {
            case .success(let purchase):
                completionBlock(purchase.transaction as! SKPaymentTransaction)
                
            case .error(let error):
                errorBlock(self.purchaseErrorHandler(error))
            }
        }
    }
    
    // TODO: - Restore Purchase
    
    public func restorePurchases(atomically: Bool = true, completionBlock: @escaping (RestoreBlock) -> Void) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: atomically) { results in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            for purchase in results.restoredPurchases {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            
            completionBlock(self.restoreErrorHandler(results))
        }
    }
    
    // TODO: - Verify Purchase
    
    public func verifyPurchase(completionBlock: @escaping (VerifyPurchaseSuccessBlock) -> Void, errorBlock: @escaping (VerifyPurchaseErrorBlock) -> Void) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            switch result {
            case .success(let receipt):
                
                if self.isSubscriptionProduct {
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: self.currentID,
                        inReceipt: receipt)
                    
                    completionBlock(self.verifyPurchaseSuccessHandler(purchaseResult))
                }
                else {
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(
                        productId: self.currentID,
                        inReceipt: receipt)
                    
                    completionBlock(self.verifyPurchaseSuccessHandler(purchaseResult))
                }
                
            case .error(let error):
                errorBlock(self.verifyPurchaseErrorHandler(error))
            }
        }
    }
    
    // TODO: - Verify Receipt
    
    private func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.sharedSecretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }
}

extension InAppPurchaseManageProtocol {
    
    private var isSubscriptionProduct: Bool {
        return self.inAppProducts.contains(self.currentID)
    }
    
    private func purchaseErrorHandler(_ error: SKError) -> PurchaseErrorBlock {
        
        var errorMessage = ""
        
        switch error.code {
        case .unknown:
            errorMessage = error.localizedDescription
        case .clientInvalid:
            errorMessage = "Not allowed to make the payment"
        case .paymentCancelled:
            errorMessage = "You've cancelled request"
        case .paymentInvalid:
            errorMessage = "The purchase identifier was invalid"
        case .paymentNotAllowed:
            errorMessage = "The device is not allowed to make the payment"
        case .storeProductNotAvailable:
            errorMessage = "The product is not available in the current storefront"
        case .cloudServicePermissionDenied:
            errorMessage = "Access to cloud service information is not allowed"
        case .cloudServiceNetworkConnectionFailed:
            errorMessage = "Could not connect to the network"
        case .cloudServiceRevoked:
            errorMessage = "Cloud service was revoked"
        default:
            errorMessage = "Not allowed to make the payment"
        }
        
        return (error.code, errorMessage)
    }
    
    private func restoreErrorHandler(_ results: RestoreResults) -> RestoreBlock {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return(false, "Restore failed, Unknown error. Please contact support")
            
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return(true, "Purchases Restored, All purchases have been restored")
            
        } else {
            print("Nothing to Restore")
            return(false, "Nothing to restore, No previous purchases were found")
        }
    }
    
    private func verifyPurchaseSuccessHandler(_ purchaseResult: Any) -> VerifyPurchaseSuccessBlock {
        
        if let purchaseResult = purchaseResult as? VerifySubscriptionResult {
            
            switch purchaseResult {
            case .purchased(_, let items):
                return .purchased(isInTrialPeriod: items.first?.isTrialPeriod ?? true)
            case .expired(_, let items):
                return .expired(isInTrialPeriod: items.first?.isTrialPeriod ?? true)
            case .notPurchased:
                return .notPurchased
            }
        }
        else if let purchaseResult = purchaseResult as? VerifyPurchaseResult {
            
            switch purchaseResult {
            case .purchased(let item):
                return .purchased(isInTrialPeriod: item.isTrialPeriod)
            case .notPurchased:
                return .notPurchased
            }
        }
        return .notPurchased
    }
    
    private func verifyPurchaseErrorHandler(_ error: ReceiptError) -> VerifyPurchaseErrorBlock {
        
        switch error {
        case .noReceiptData:
            return "Receipt verification No receipt data. Try again."
        case .networkError(let error):
            return "Receipt verification Network error while verifying receipt: \(error)"
        default:
            return "Receipt verification Receipt verification failed: \(error)"
        }
    }
}

// MARK: - InAppPurchaseProtocol

public protocol InAppPurchaseProtocol: InAppPurchaseManageProtocol {
    
    func purchaseProduct(productID: String)
    func restoreProduct()
    func verifyEachProductForRestore(productNo: Int)
}

