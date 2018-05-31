//
//  aaaaaa.swift
//  heartRate
//
//  Created by Arash K. on 2017-08-18.
//  Copyright © 2017 Arash K. All rights reserved.
//

import Foundation
import HealthKit





class HealthKitManager {
    
    var healthStore: HKHealthStore = {
        
        var result =  HKHealthStore()
        return result
    }()
    
    var query: HKAnchoredObjectQuery? = nil
    var anchor: HKQueryAnchor? = nil
    
    static var shared: HealthKitManager = {
       
        return HealthKitManager()
    }()
    
    private init() {
        
        self.askPermission()
    }
    
    var callback: ((Bool) -> Void)? = nil
    
    func askPermission() {
        
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in }
    }
    
    
    func initiateQuery() {
        
        self.performQuery()
        
        self.query?.updateHandler = {(query, samplesOpt, deleteObjects, newAnchor, error) -> Void in
            
            DispatchQueue.main.async {
                self.anchor = newAnchor
                
                guard let samples = samplesOpt as? [HKQuantitySample] else { return }
                
                self.onSamplesUpdated(samples: samples)
                
//                self.performQuery()
//                self.healthStore.execute(self.query!)
            }
        }
        
        self.healthStore.execute(self.query!)
    }
    
    
    func performQuery() {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate)
        
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: HKQueryOptions.strictEndDate)
        
        self.query = HKAnchoredObjectQuery(type: quantityType!
            , predicate: predicate
            , anchor: self.anchor
        , limit: Int(HKObjectQueryNoLimit)) { (anchorObjectQuery, samplesOpt, deletedObjsOpt, newAnchor, errorOpt) in
            
            DispatchQueue.main.async {
                self.anchor = newAnchor
                
                guard let samples = samplesOpt as? [HKQuantitySample] else { return }
                
                self.onSamplesUpdated(samples: samples)
            }
        }
    }
    
    var lastValue: HKQuantitySample? = nil
    
    func onSamplesUpdated(samples: [HKQuantitySample]) {
        
        if let lastSample = samples.last?.quantity.doubleValue(for: HKUnit(from: "count/min")),
            let lastValidValue = lastValue?.quantity.doubleValue(for: HKUnit(from: "count/min")), lastSample >  lastValidValue  {
            
            DispatchQueue.main.async {
                
                self.callback?(true) }
        } else {
            
            
            DispatchQueue.main.async {
                
            self.callback?(false)
            }
        }
        
        lastValue = samples.last
        
        for sample in samples {
            
            print(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
        }
    }
}



