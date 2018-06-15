//
//  NiceFunctions.swift
//  TrafficSim
//
//  Created by Student2018 on 2018-05-14.
//  Copyright © 2018 Big_Dump_11. All rights reserved.
//

import Foundation
import SpriteKit

func distanceBetweenPoints (_ point1:CGPoint, _ point2:CGPoint) -> CGFloat {
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
}

func slopeBetweenPoints(_ point1:CGPoint, _ point2:CGPoint) -> CGFloat {
    return (point1.y-point2.y)/(point1.x-point2.x)
}

func findYIntercept (_ point:CGPoint, _ slope:CGFloat) -> CGFloat {
    return point.y - (slope*point.x)
}

func contains(_ array:[Road], _ possibleElement:Road) -> Bool {
    
    for i in array {
        if i === possibleElement {
            return true
        }
    }
    
    return false
}
