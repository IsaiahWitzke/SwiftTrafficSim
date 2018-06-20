//
//  ConnectingRoadSegments.swift
//  TrafficSim
//
//  Created by Student2018 on 2018-05-29.
//  Copyright © 2018 Big_Dump_11. All rights reserved.
//

//all things related with "road segment" prefabs

import Foundation
import SpriteKit

class RoadSegment {
    
    var rightSideRoad:Road
    var leftSideRoad:Road
    var corner:String
    
    //the offset will be based of the start of the rightSideRoad
    init (_ offsetPoint:CGPoint, _ length:CGFloat, _ isVertical:Bool, corner:String = "", masterRoadNetwork: inout [Road]) {
        
        let distanceBetweenRoads = 50 * GLOBALSCALE
        
        self.corner = corner
        
        //for curved road segments. if the corner input is anything but one of the valid corner options, then the road will be straight
        //the length will be the radius of the inner curve
        //offset point will still be the start of the rightside road
        //rightside road will be the inside most road
        if corner == "topLeft" {
            self.rightSideRoad = Road(startPoint: offsetPoint, endPoint: CGPoint(x: offsetPoint.x+length, y: offsetPoint.y+length) , circleCenter: CGPoint(x: offsetPoint.x+length, y: offsetPoint.y), isCircle: true, clockwiseDirection: true)
            
            //difference of distanceBetweenRoads pts between roads
            self.leftSideRoad = Road(startPoint: CGPoint(x: offsetPoint.x+length, y: offsetPoint.y+length+distanceBetweenRoads), endPoint: CGPoint(x: offsetPoint.x-distanceBetweenRoads, y: offsetPoint.y) , circleCenter: CGPoint(x: offsetPoint.x+length, y: offsetPoint.y), isCircle: true, clockwiseDirection: false)
            
            //adding the roads to the master road network
            masterRoadNetwork.append(rightSideRoad)
            masterRoadNetwork.append(leftSideRoad)
            
            //leave init before straight road segments are made
            return
        }
        
        if corner == "topRight" {
            self.rightSideRoad = Road(startPoint: offsetPoint, endPoint: CGPoint(x: offsetPoint.x+length, y: offsetPoint.y-length) , circleCenter: CGPoint(x: offsetPoint.x, y: offsetPoint.y-length), isCircle: true, clockwiseDirection: true)
            
            self.leftSideRoad = Road(startPoint: CGPoint(x: offsetPoint.x+length+distanceBetweenRoads, y: offsetPoint.y-length) , endPoint: CGPoint(x: offsetPoint.x, y: offsetPoint.y+length)  , circleCenter: CGPoint(x: offsetPoint.x, y: offsetPoint.y-length), isCircle: true, clockwiseDirection: false)
            
            masterRoadNetwork.append(rightSideRoad)
            masterRoadNetwork.append(leftSideRoad)
            
            return
        }
        
        if corner == "bottomLeft" {
            self.rightSideRoad = Road(startPoint: offsetPoint, endPoint: CGPoint(x: offsetPoint.x-length, y: offsetPoint.y+length) , circleCenter: CGPoint(x: offsetPoint.x, y: offsetPoint.y + length), isCircle: true, clockwiseDirection: true)
             
            self.leftSideRoad = Road(startPoint: CGPoint(x: offsetPoint.x-distanceBetweenRoads-length, y: offsetPoint.y+length), endPoint: CGPoint(x: offsetPoint.x, y: offsetPoint.y-distanceBetweenRoads) , circleCenter: CGPoint(x: offsetPoint.x, y: offsetPoint.y + length), isCircle: true, clockwiseDirection: false)
            
            masterRoadNetwork.append(rightSideRoad)
            masterRoadNetwork.append(leftSideRoad)
            
            return
        }
        
        if corner == "bottomRight" {
            self.rightSideRoad = Road(startPoint: offsetPoint, endPoint: CGPoint(x: offsetPoint.x-length, y: offsetPoint.y-length) , circleCenter: CGPoint(x: offsetPoint.x-length, y: offsetPoint.y), isCircle: true, clockwiseDirection: true)
            
            self.leftSideRoad = Road(startPoint: CGPoint(x: offsetPoint.x-length, y: offsetPoint.y-length-distanceBetweenRoads), endPoint: CGPoint(x: offsetPoint.x+distanceBetweenRoads, y: offsetPoint.y) , circleCenter: CGPoint(x: offsetPoint.x-length, y: offsetPoint.y), isCircle: true, clockwiseDirection: false)
            
            masterRoadNetwork.append(rightSideRoad)
            masterRoadNetwork.append(leftSideRoad)
            
            return
        }
        
        //horizantal road segments
        if isVertical == false {
            //rightSideRoad = "top road"
            self.rightSideRoad = Road(startPoint: offsetPoint, endPoint: CGPoint(x: offsetPoint.x - length, y: offsetPoint.y))
            
            //roads are separated by distanceBetweenRoads pts.
            self.leftSideRoad = Road(startPoint: CGPoint(x:offsetPoint.x - length, y:offsetPoint.y-distanceBetweenRoads), endPoint: CGPoint(x: offsetPoint.x, y: offsetPoint.y-distanceBetweenRoads))
        } else {
            //vertical roads
            self.rightSideRoad = Road(startPoint: offsetPoint, endPoint: CGPoint(x: offsetPoint.x, y: offsetPoint.y + length))
            self.leftSideRoad = Road(startPoint: CGPoint(x:offsetPoint.x - distanceBetweenRoads, y:offsetPoint.y + length), endPoint: CGPoint(x: offsetPoint.x - distanceBetweenRoads, y: offsetPoint.y))
        }
        
        //adding the roads to the master road network
        masterRoadNetwork.append(rightSideRoad)
        masterRoadNetwork.append(leftSideRoad)
    }
}

func purgeDeadEnds (_ roads: inout [Road]) {
    
    //to avoid breaking the program too hard
    if roads.count == 0 {
        return
    }
    
    //firstly, we want to go through all the roads and get rid of any dead-ends (this will allow for 3 way intersections)
    var purge = true
    while (purge) {
        if DEBUG {
            print("pruging roads, roads left:", roads.count)
        }
        
        purge = false
        
        for incomingRoadIndex in 0...roads.count-1 {
            //flag variable to see if there is actually a next road or not
            var isNextRoads = false
            
            for outgoingRoadIndex in 0...roads.count-1 {
                if roads[incomingRoadIndex].endPoint == roads[outgoingRoadIndex].startPoint {
                    isNextRoads = true
                }
            }
            
            //at this point if there are no "nextRoads", then we can delete the current road:
            if !isNextRoads {
                purge = true
                roads.remove(at: incomingRoadIndex)
                break   //allows the roads.count to reset so we dont run off the end of the list and remove roads we dont mean to
            }
        }
        
        //same thing as before, but only for incoming roads. Here we arn't testing for "dead ends", but roads that are never going to start
        for outgoingRoadIndex in 0...roads.count-1 {
            
            var isPreviousRoads = false
            for incomingRoadIndex in 0...roads.count-1 {
                if roads[incomingRoadIndex].endPoint == roads[outgoingRoadIndex].startPoint {
                    isPreviousRoads = true
                }
            }
            if !isPreviousRoads {
                purge = true
                roads.remove(at: outgoingRoadIndex)
                break
            }
        }
    }
}

func connnectAllRoads (_ roads: inout [Road]) {
    //to avoid breaking the program too hard
    if roads.count == 0 {
        return
    }
    //going through every road, if the end point of one road is the same as a startpoint of another road, then connect them
    for incomingRoadIndex in 0...roads.count-1 {
        for outgoingRoadIndex in 0...roads.count-1 {
            if roads[incomingRoadIndex].endPoint == roads[outgoingRoadIndex].startPoint {
                //connections means linking the parent node to the child AND child to parnet
                roads[incomingRoadIndex].nextRoads.append(roads[outgoingRoadIndex])
                roads[outgoingRoadIndex].previousRoads.append(roads[incomingRoadIndex])
            }
        }
        
    }
}
