//
//  HFTimeLineManager.swift
//  Runner
//
//  Created by HF on 2019/12/2.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import LocoKit
import CoreLocation

@objc public class HFTimeLineManager:NSObject {

    typealias editorBlock = (_ t:CLLocation?) -> Void
    @objc  var myEidtorBlock:editorBlock?
    @objc  var timeCycleNum:Double = 30;//second
    @objc let  manager: TimelineManager()

    var lastDate:Date?
    var lastLocation:CLLocation?
    
    

}
