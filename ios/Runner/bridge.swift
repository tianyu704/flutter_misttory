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
    
    let store = TimelineStore()
    var recorder: TimelineRecorder
    
    var lastDate:Date?
    var lastLocation:CLLocation?
    public override init() {
       //init
        self.recorder = TimelineRecorder(store: store)
   }
    
    @objc public func arcOnce()-> CLLocation {
        return self.lastLocation!;
    }
    
   @objc public func arcStart() {
        
    self.recorder.startRecording()
    let timeline = self.recorder
    let loco = self.locoArc
    ///
      when(loco, does: .locomotionSampleUpdated) { _ in
         if ((self.myEidtorBlock) != nil){
            var location:CLLocation?
            if (loco.locomotionSample().location != nil) {
                location = (loco.locomotionSample().location)!
            } else {
                location = loco.filteredLocation
            }
            if (self.lastLocation == nil) {
                self.lastLocation = location
            }
            let item = timeline.currentItem!
            if (item.isValid == true && Double(location?.horizontalAccuracy ?? -1) > 2000.0)   {
                let sample = timeline.currentItem?.samples.first;
                location = sample?.location!
                self.myEidtorBlock!(location)
            } else {
                self.myEidtorBlock!(self.lastLocation)
            }
            self.lastLocation = location;
        }
      }
   }
    
   @objc public func arcStop() {
    self.recorder.stopRecording()
   }

}
