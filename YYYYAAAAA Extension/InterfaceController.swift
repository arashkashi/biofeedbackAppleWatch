//
//  InterfaceController.swift
//  YYYYAAAAA Extension
//
//  Created by Arash K. on 2017-08-18.
//  Copyright © 2017 Arash K. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var label: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let healthStore = HKHealthStore()
        
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in }
        
         HealthKitManager.shared.initiateQuery()
        
        if HealthKitManager.shared.callback == nil {
            
            HealthKitManager.shared.callback = { increased in
                
                DispatchQueue.main.async {
                    
                
                if increased {
                    WKInterfaceDevice.current().play(WKHapticType.directionUp)
                } else {
                    
                    WKInterfaceDevice.current().play(WKHapticType.directionDown)
                }
                
                let empty = "\( HealthKitManager.shared.lastValue?.quantity.doubleValue(for: HKUnit(from:"count/min")) ?? 0)"
                
                self.label.setText(empty)
                }
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
