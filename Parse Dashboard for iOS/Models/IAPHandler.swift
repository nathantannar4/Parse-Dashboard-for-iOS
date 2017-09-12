//
//  IAPHandler.swift
//  Parse Dashboard for iOS
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 9/9/17.
//
//  Credits to https://medium.com/theappspace/swift-how-to-add-in-app-purchases-in-your-ios-app-c1dc2fc82319
//

import UIKit
import StoreKit

class IAPHandler: NSObject {
    
    enum IAPHandlerAlertType {
        case disabled
        case restored
        case purchased
        
        func message() -> String {
            switch self {
            case .disabled: return "Purchases are disabled in your device!"
            case .restored: return "You've successfully restored your purchase!"
            case .purchased: return "You've successfully bought this purchase!"
            }
        }
    }
    
    enum IAPProductId: String  {
        case tier1 = "tier_one_tip"
        case tier2 = "tier_two_tip"
        case tier3 = "tier_three_tip"
    }
    
    static let shared = IAPHandler()
    
    fileprivate var productIDs = [IAPProductId.tier1.rawValue, IAPProductId.tier2.rawValue, IAPProductId.tier3.rawValue]
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    fileprivate var iapPrices = [String]()
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    
    func canMakePurchases() -> Bool {
        
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchase(_ id: IAPProductId) {
        
        if canMakePurchases(), let index = productIDs.index(of: id.rawValue) {
            
            let product = iapProducts[index]
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)

            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }
    
    // MARK: - RESTORE PURCHASE
    
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    
    func fetchAvailableProducts(){
        
        // Put here your IAP Products ID's
        let identifiers = NSSet(array: productIDs) as! Set<String>
        productsRequest = SKProductsRequest(productIdentifiers: identifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // MARK: - REQUEST IAP PRODUCTS
    
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        iapProducts = response.products
        iapPrices = []
        print(iapProducts)
        for product in iapProducts {
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = product.priceLocale
            if let price1Str = numberFormatter.string(from: product.price) {
                iapPrices.append(price1Str)
                print(product.localizedDescription + "\nfor just \(price1Str)")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }
    
    // MARK: - IAP PAYMENT QUEUE
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased)
                case .failed:
                    print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default:
                    break
                }
            }
        }
    }
}

