//
//  bridge.swift
//  Runner
//
//  Created by HF on 2019/10/18.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import LocoKit
import CoreLocation

 
@objc public class HFArcManager:NSObject {
    typealias editorBlock = (_ t:CLLocation?,_ isNeedDateChange:Bool) -> Void
    typealias onceBlock = (_ t:CLLocation?,_ isNeedDateChange:Bool) -> Void
    @objc  var myEidtorBlock:editorBlock?
    @objc  var myOnceBlock:onceBlock?
    @objc  var timeCycleNum:Double = 30;//second
    @objc let locoArc = LocomotionManager.highlander;
    var isOnce:Bool = false;
    let store = TimelineStore()
    var recorder: TimelineRecorder
    
    var lastDate:Date?
   // var lastLocation:CLLocation?
    public override init() {
       //init
        self.recorder = TimelineRecorder(store: store)
   }
    
    @objc public func arcOnce() {
        self.isOnce = true;
        self.locoArc.locationManager .startUpdatingLocation();
    }
    
   @objc public func arcStart() {
        
    self.recorder.startRecording()
    let timeline = self.recorder
    let loco = self.locoArc
    ///didUpdateLocations
//    when(loco, does: .locomotionSampleUpdated) { _ in
//    
//        
//        
//    }
      when(loco, does: .locomotionSampleUpdated) { _ in
         if ((self.myEidtorBlock) != nil){
            var location:CLLocation?
            location = loco.filteredLocation
            
            let isFar = Double(location?.horizontalAccuracy ?? -1) > 2000.0
            let item = timeline.currentItem!
            if (item.isDataGap && isFar) {
                return ;
            }
            if (item is Visit == true && isFar)   {
                let sample = timeline.currentItem?.samples.first;
                location = sample?.location!
                self.myEidtorBlock!(location,true)
                if (self.isOnce) {
                     self.myOnceBlock!(location,true)
                    self.isOnce = false;
                }
            } else {
                self.myEidtorBlock!(location,false)
                if (self.isOnce) {
                    self.myOnceBlock!(location,false)
                    self.isOnce = false;
                }
            }
        }
      }
   }
    
   @objc public func arcStop() {
    self.recorder.stopRecording()
   }

}
