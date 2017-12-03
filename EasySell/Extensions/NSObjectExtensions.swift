//
// Created by Almas Adilbek on 12/3/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation

extension NSObject {
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}