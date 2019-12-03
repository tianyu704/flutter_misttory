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
    
    var timer :Timer!
    var lastDate:Date?

    public override init() {
       //init
       self.recorder = TimelineRecorder(store: store)
   }
   
    @objc func timerAction(){
          self.calculateLocation(true)
    }
    
    @objc public func arcOnce() {
        self.isOnce = true;
        self.locoArc.locationManager.startUpdatingLocation();
        self.calculateLocation(true)
    }
    
   @objc public func arcStart() {
        
      self.recorder.startRecording()
      let loco = self.locoArc
    
      self.startTimer();
      when(loco, does: .locomotionSampleUpdated) { _ in
        print("过滤后定位")
        self.calculateLocation();
      }
   }
    func calculateLocation() {
        calculateLocation(false);
    }
    func calculateLocation(_ isUseTimer:Bool) {
        let timeline = self.recorder
        let loco = self.locoArc
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
                self.myEidtorBlock!(location,isUseTimer)
                if (self.isOnce) {
                    self.myOnceBlock!(location,isUseTimer)
                    self.isOnce = false;
                }
            }
        }
    }
    
   @objc public func arcStop() {
    self.endTimer();
    self.recorder.stopRecording()
   }
   
    func startTimer () {
        timer = Timer.scheduledTimer(timeInterval: timeCycleNum, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    func endTimer () {
        timer?.invalidate();
    }
}
