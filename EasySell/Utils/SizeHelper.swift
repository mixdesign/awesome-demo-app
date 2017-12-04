//
// Created by Almas Adilbek on 12/4/17.
// Copyright (c) 2017 Good App. All rights reserved.
//

import Foundation
import CoreGraphics

struct SizeHelper {

    static func value(i5:CGFloat, i6:CGFloat, i6p:CGFloat, ipad:CGFloat) -> CGFloat {
        if DeviceType.IS_IPHONE_5 {
            return i5
        } else if DeviceType.IS_IPHONE_6 {
            return i6
        } else if DeviceType.IS_IPHONE_6P {
            return i6p
        } else if DeviceType.IS_IPAD {
            return ipad
        }
        return i5
    }

}