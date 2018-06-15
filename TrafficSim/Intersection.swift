//
//  Intersection.swift
//  TrafficSim
//
//  Created by Student2018 on 2018-05-26.
//  Copyright © 2018 Big_Dump_11. All rights reserved.
//

import Foundation
import SpriteKit

class Intersection {
    
    //keeps track of ALL the roads in the intersection
    var roads:[Road] = []
    
    var bottomLeftCorner:CGPoint
    var topRightCorner:CGPoint
    
    init (_ offsetPoint:CGPoint,  masterRoadNetwork: inout [Road]) {
        
        //for scaling the intersection
        let distanceBetweenRoads:CGFloat = 50 * GLOBALSCALE
        
        self.bottomLeftCorner = offsetPoint
        self.topRightCorner = CGPoint(x: offsetPoint.x + 250*GLOBALSCALE, y: offsetPoint.y + 250*GLOBALSCALE)
        
        //these are just temporary
        var incomingRoadPoints:[[CGPoint]] = []
        var outgoingRoadPoints:[[CGPoint]] = []
        
        //each element in the array is a pair of points: the start and end of a line
        //these are the points describing the straight roads going into/from the intersection
        
        incomingRoadPoints.append([CGPoint(x:0 + offsetPoint.x,
                                           y:2 * distanceBetweenRoads + offsetPoint.y),
                                        CGPoint(x:distanceBetweenRoads + offsetPoint.x,y:2 * distanceBetweenRoads + offsetPoint.y)])   //westEastbound
        outgoingRoadPoints.append([CGPoint(x:distanceBetweenRoads + offsetPoint.x,y:3 * distanceBetweenRoads + offsetPoint.y),
                                        CGPoint(x:0 + offsetPoint.x,y:3 * distanceBetweenRoads + offsetPoint.y)])    //westWestbound
        incomingRoadPoints.append([CGPoint(x:2 * distanceBetweenRoads + offsetPoint.x,y:5 * distanceBetweenRoads + offsetPoint.y),
                                        CGPoint(x:2 * distanceBetweenRoads + offsetPoint.x,y:4 * distanceBetweenRoads + offsetPoint.y)])  //northSouthbound
        outgoingRoadPoints.append([CGPoint(x:3 * distanceBetweenRoads + offsetPoint.x,y:4 * distanceBetweenRoads + offsetPoint.y),
                                        CGPoint(x:3 * distanceBetweenRoads + offsetPoint.x,y:5 * distanceBetweenRoads + offsetPoint.y)])  //northNorthbound
        incomingRoadPoints.append([CGPoint(x:5 * distanceBetweenRoads + offsetPoint.x,y:3 * distanceBetweenRoads + offsetPoint.y),
                                        CGPoint(x:4 * distanceBetweenRoads + offsetPoint.x,y:3 * distanceBetweenRoads + offsetPoint.y)])  //eastWestbound
        outgoingRoadPoints.append([CGPoint(x:4 * distanceBetweenRoads + offsetPoint.x,y:2 * distanceBetweenRoads + offsetPoint.y),
                                        CGPoint(x:5 * distanceBetweenRoads + offsetPoint.x,y:2 * distanceBetweenRoads + offsetPoint.y)])  //eastEastbound
        incomingRoadPoints.append([CGPoint(x:3 * distanceBetweenRoads + offsetPoint.x,y:0 + offsetPoint.y),
                                        CGPoint(x:3 * distanceBetweenRoads + offsetPoint.x,y:distanceBetweenRoads + offsetPoint.y)])   //southNorthbound
        outgoingRoadPoints.append([CGPoint(x:2 * distanceBetweenRoads + offsetPoint.x,y:distanceBetweenRoads + offsetPoint.y),
                                        CGPoint(x:2 * distanceBetweenRoads + offsetPoint.x,y:0 + offsetPoint.y)])    //southSouthbound
        
        //temp road storage for increased orginization
        var incomingRoads:[Road] = []
        var outgoingRoads:[Road] = []
        
        //actually making the roads now
        //starting to orginzie the roads into one great array (elements 0, 1, 2, 3 are incoming roads)
        for i in 0...3 {
            self.roads.append(Road(startPoint: incomingRoadPoints[i][0], endPoint: incomingRoadPoints[i][1], roadType: "intersectionIn", associatedIntersection: self))
            incomingRoads.append(Road(startPoint: incomingRoadPoints[i][0], endPoint: incomingRoadPoints[i][1], associatedIntersection: self))
        }
        
        //(elements 4, 5, 6, 7 are outgoing roads)
        for i in 0...3 {
            self.roads.append(Road(startPoint: outgoingRoadPoints[i][0], endPoint: outgoingRoadPoints[i][1], roadType: "intersectionOut", associatedIntersection: self))
            outgoingRoads.append(Road(startPoint: outgoingRoadPoints[i][0], endPoint: outgoingRoadPoints[i][1], associatedIntersection: self))
        }
        
        //connecting roads:
        //for straight connecting roads (elements 8, 9, 10, 11 will be these straight connectors)
        self.roads.append(Road(startPoint: incomingRoads[0].endPoint, endPoint: outgoingRoads[2].startPoint, roadType: "intersectionStraight", associatedIntersection: self))
        self.roads.append(Road(startPoint: incomingRoads[1].endPoint, endPoint: outgoingRoads[3].startPoint, roadType: "intersectionStraight", associatedIntersection: self))
        self.roads.append(Road(startPoint: incomingRoads[2].endPoint, endPoint: outgoingRoads[0].startPoint, roadType: "intersectionStraight", associatedIntersection: self))
        self.roads.append(Road(startPoint: incomingRoads[3].endPoint, endPoint: outgoingRoads[1].startPoint, roadType: "intersectionStraight", associatedIntersection: self))

            
        var circleMidpoint = CGPoint.zero
                
        //right turning conection roads (12, 13, 14, 15)
        circleMidpoint = CGPoint(x: incomingRoads[0].endPoint.x, y:outgoingRoads[3].startPoint.y)
        self.roads.append(Road(startPoint: incomingRoads[0].endPoint,
                               endPoint: outgoingRoads[3].startPoint,
                               roadType: "intersectionRight",
                               circleCenter: circleMidpoint,
                               isCircle: true,
                               clockwiseDirection: true))
        circleMidpoint = CGPoint(x: outgoingRoads[0].startPoint.x, y: incomingRoads[1].endPoint.y)
        self.roads.append(Road(startPoint: incomingRoads[1].endPoint,
                               endPoint: outgoingRoads[0].startPoint,
                               roadType: "intersectionRight",
                               circleCenter: circleMidpoint,
                               isCircle: true,
                               clockwiseDirection: true,
                               associatedIntersection: self))
        circleMidpoint = CGPoint(x: incomingRoads[2].endPoint.x, y:outgoingRoads[1].startPoint.y)
        self.roads.append(Road(startPoint: incomingRoads[2].endPoint,
                               endPoint: outgoingRoads[1].startPoint,
                               roadType: "intersectionRight",
                               circleCenter: circleMidpoint,
                               isCircle: true,
                               clockwiseDirection: true,
                               associatedIntersection: self))
        circleMidpoint = CGPoint(x: outgoingRoads[2].startPoint.x, y: incomingRoads[3].endPoint.y)
        self.roads.append(Road(startPoint: incomingRoads[3].endPoint,
                               endPoint: outgoingRoads[2].startPoint,
                               roadType: "intersectionRight",
                               circleCenter: circleMidpoint,
                               isCircle: true,
                               clockwiseDirection: true,
                               associatedIntersection: self))
                
        //left truning roads (16, 17, 18, 19)
        circleMidpoint = CGPoint(x: incomingRoads[0].endPoint.x, y: outgoingRoads[1].startPoint.y)
        self.roads.append(Road(startPoint: incomingRoads[0].endPoint,
                               endPoint: outgoingRoads[1].startPoint,
                               roadType: "intersectionLeft",
                               circleCenter: circleMidpoint,
                               isCircle: true,
                               clockwiseDirection: false,
                               associatedIntersection: self))
        circleMidpoint = CGPoint(x: outgoingRoads[2].startPoint.x, y: incomingRoads[1].endPoint.y)
        self.roads.append(Road(startPoint: incomingRoads[1].endPoint,
                               endPoint: outgoingRoads[2].startPoint,
                               roadType: "intersectionLeft",
                               circleCenter: circleMidpoint,
                               isCircle: true,
                               clockwiseDirection: false,
                               associatedIntersection: self))
        circleMidpoint = CGPoint(x: incomingRoads[2].endPoint.x, y: outgoingRoads[3].startPoint.y)
        self.roads.append(Road(startPoint: incomingRoads[2].endPoint,
                               endPoint: outgoingRoads[3].startPoint,
                               roadType: "intersectionLeft",
                               circleCenter: circleMidpoint,
                               isCircle: true,
                               clockwiseDirection: false,
                               associatedIntersection: self))
        circleMidpoint = CGPoint(x: outgoingRoads[0].startPoint.x, y: incomingRoads[3].endPoint.y)
        self.roads.append(Road(startPoint: incomingRoads[3].endPoint,
                               endPoint: outgoingRoads[0].startPoint,
                               roadType: "intersectionLeft",
                               circleCenter: circleMidpoint,
                               isCircle: true,
                               clockwiseDirection: false,
                               associatedIntersection: self))
    
        //adding these roads to the master road network
        for i in 0...roads.count-1 {
            masterRoadNetwork.append(roads[i])
        }

    }
}
