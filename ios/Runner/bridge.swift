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
    typealias editorBlock = (_ t:CLLocation?) -> Void
    @objc  var myEidtorBlock:editorBlock?
    @objc  var timeCycleNum:Double = 30;//second
    @objc let locoArc = LocomotionManager.highlander;
    var lastDate:Date?
    public override init() {
       //init
       // decide whether to use "sleep mode" to allow for all day recording
       self.locoArc.useLowPowerSleepModeWhileStationary = true
       //重大位置变化需要记录设置
       self.locoArc.locationManager.startMonitoringVisits()
       self.locoArc.locationManager.startMonitoringSignificantLocationChanges()
   }
    
    @objc public func arcOnce()-> CLLocation {
        return self.locoArc.locomotionSample().location!;
    }
    
   @objc public func arcStart() {
        
    self.locoArc.startRecording()
    let loco = self.locoArc
      when(loco, does: .locomotionSampleUpdated) { _ in
         if ((self.myEidtorBlock) != nil){
             if (loco.locomotionSample().location != nil) {
                 self.myEidtorBlock!((loco.locomotionSample().location)!)
             } else {
                 self.myEidtorBlock!(loco.filteredLocation!)
             }
          }
      }
   }
    
   @objc public func arcStop() {
    self.locoArc.stopRecording()
   }

}
