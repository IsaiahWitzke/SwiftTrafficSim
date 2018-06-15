//
//  RoadClass.swift
//  TrafficSim
//
//  Created by Student2018 on 2018-05-16.
//  Copyright © 2018 Big_Dump_11. All rights reserved.
//

import Foundation
import SpriteKit

class Road {
    
    //what will be drawn on the screen
    var roadLine:SKShapeNode
    
    var startPoint:CGPoint
    var endPoint:CGPoint
    var length:CGFloat
    
    //so we can navigate the road structure/network
    var nextRoads:[Road?] = []
    var previousRoads:[Road?] = []
    
    //circular road specific stuff
    var circleCenter:CGPoint = CGPoint.zero
    var radius:CGFloat
    var clockwiseDirection:Bool
    
    var roadType:String
    
    //sometimes the road is part of an intersection:
    var associatedIntersection:Intersection? = nil
    
    //the init function will make the road
    init(startPoint:CGPoint, endPoint:CGPoint, roadType:String = "basic", circleCenter:CGPoint = CGPoint(x:0,y:0), isCircle:Bool = false, clockwiseDirection:Bool = true, associatedIntersection:Intersection? = nil) {
        
        //for different types of roads, they will be represented with different colors
        self.roadType = roadType
        
        //only for some roads
        self.associatedIntersection = associatedIntersection
        
        //stuff that isnt dependant on the circle or not
        self.startPoint = startPoint
        self.endPoint = endPoint
        
        //2 kinds of roads, one is a partial-circle, the other is a line
        if isCircle {
            
            self.circleCenter = circleCenter
            
            self.radius = distanceBetweenPoints(startPoint, circleCenter)
            self.clockwiseDirection = clockwiseDirection    //is the car trying to go clockwise or counterclockwise?
            
            //to figure out the arclength of the circle segment we need to take the change in angle and multiply by the radius
            //to figure out the change in angle, find the difference of the slopes of the 2 points and centers, translate that difference into rads afterwards
            var theta1:CGFloat
            var theta2:CGFloat
            
            theta1 = atan(slopeBetweenPoints(startPoint, circleCenter))
            theta2 = atan(slopeBetweenPoints(endPoint, circleCenter))
            
            //the slope of a line going straight up is the same with the one down. Same with horizantal lines
            if endPoint.x < circleCenter.x && theta2 == 0 {
                theta2 += CGFloat.pi
            }
            
            if endPoint.y > circleCenter.y && theta2 == 0 {
                theta1 += CGFloat.pi
            }
            
            if startPoint.x < circleCenter.x && theta1 == 0 {
                theta1 += CGFloat.pi
            }
            
            if startPoint.y > circleCenter.y && theta1 == 0 {
                theta2 += CGFloat.pi
            }
            
            //all angles should be positive
            if theta1 < 0 {
                theta1 = (2 * CGFloat.pi) + theta1
            }
            if theta2 < 0 {
                theta2 = (2 * CGFloat.pi) + theta2
            }

            //delta theta is the differance (in rads) between startPoint and endPoint
            var deltaTheta:CGFloat = 0
            
            deltaTheta = theta2 - theta1
            
            if deltaTheta < 0 && clockwiseDirection {
                deltaTheta = abs(deltaTheta)
            } else if deltaTheta > 0 && clockwiseDirection {
                deltaTheta = 2 * CGFloat.pi - deltaTheta
            }
            
            if deltaTheta < 0 && !clockwiseDirection {
                deltaTheta = 2 * CGFloat.pi - abs(deltaTheta)
            } else if deltaTheta > 0 && clockwiseDirection {
                
            }
            
            self.length = deltaTheta * radius
        
            //drawing the road line:
            let roadPath = CGMutablePath()
            roadPath.addArc(center: circleCenter,
                            radius: self.radius,
                            startAngle: theta1,
                            endAngle: theta2,
                            clockwise: clockwiseDirection)
            let tempRoad = SKShapeNode(path: roadPath)
            tempRoad.lineWidth = 1
            self.roadLine = tempRoad
            
            //different kinds of roads need to be different colours:
            if roadType == "intersectionRight" {
                self.roadLine.strokeColor = NSColor(deviceRed: 0, green: 1, blue: 1, alpha: 100)
            }
            if roadType == "intersectionLeft" {
                self.roadLine.strokeColor = NSColor(deviceRed: 0, green: 0, blue: 1, alpha: 100)
            }
            
        } else {
            //a straight line
            self.length = distanceBetweenPoints(startPoint, endPoint)
            var points = [startPoint, endPoint]
            self.roadLine = SKShapeNode(points: &points, count: 2)
            
            //all staright kinds of intersections:
            if roadType == "basic" {
                self.roadLine.strokeColor = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 100)    //white
            }
            
            if roadType == "intersectionIn" {
                self.roadLine.strokeColor = NSColor(deviceRed: 1, green: 0, blue: 0, alpha: 100)
            }
            
            if roadType == "intersectionOut" {
                self.roadLine.strokeColor = NSColor(deviceRed: 1, green: 1, blue: 0, alpha: 100)
            }
            if roadType == "intersectionStraight" {
                self.roadLine.strokeColor = NSColor(deviceRed: 0, green: 1, blue: 0, alpha: 100)
            }
            
            //initializing irrelivant circle info:
            self.radius = 0
            self.clockwiseDirection = clockwiseDirection
        }
    }
    
    //you plug in how far the car is down the road, and the function outputs the new location of the car
    func moveDownRoad(_ distanceDownRoad:CGFloat, currentPos:CGPoint = CGPoint(x: 0, y: 0)) -> CGPoint {
        //if there is no circle, the radius is 0
        if self.radius == 0 {
            
            //moving in a line
            let slope = slopeBetweenPoints(startPoint, endPoint)
            
            //there are some special cases:
            //a line in left direction
            if slope == 0 && startPoint.x > endPoint.x {
                let newYPos = startPoint.y - sin(atan(slope)) * distanceDownRoad
                let newXPos = startPoint.x - cos(atan(slope)) * distanceDownRoad
                return CGPoint(x: newXPos, y: newYPos)
            }
            //a line going directly up
            if startPoint.x == endPoint.x && endPoint.y > startPoint.y {
                let newYPos = startPoint.y + distanceDownRoad
                let newXPos = startPoint.x
                return CGPoint(x: newXPos, y: newYPos)
            }
            //a line going directly down
            if startPoint.x == endPoint.x && endPoint.y < startPoint.y {
                let newYPos = startPoint.y - distanceDownRoad
                let newXPos = startPoint.x
                return CGPoint(x: newXPos, y: newYPos)
            }
            
            //basic case
            let newYPos = startPoint.y + sin(atan(slope)) * distanceDownRoad
            let newXPos = startPoint.x + cos(atan(slope)) * distanceDownRoad
            return CGPoint(x: newXPos, y: newYPos)
            
            
        } else {
            //this section is for circles
            //the new position on the circle the car will be based off a new theta
            var newTheta:CGFloat = 0
            
            if clockwiseDirection {
                newTheta = atan(slopeBetweenPoints(startPoint, circleCenter)) - distanceDownRoad/radius
                //special cases
                if startPoint.y == circleCenter.y && startPoint.x < circleCenter.x {
                    newTheta += CGFloat.pi
                }
            } else {
                newTheta = atan(slopeBetweenPoints(startPoint, circleCenter)) + distanceDownRoad/radius
                if startPoint.y == circleCenter.y && startPoint.x < circleCenter.x {
                    newTheta += CGFloat.pi
                }
            }
            //then return the point on the newTheta
            return CGPoint(x: cos(newTheta) * radius + circleCenter.x, y: sin(newTheta) * radius + circleCenter.y)
        }
    }
    
    //returns the angle of the tangent at a certaint distace down the Road
    func angleOfRoad(_ distace:CGFloat, _ position:CGPoint = CGPoint(x:0,y:0)) -> CGFloat {
        //if there is no circle, the radius is 0
        if radius == 0 {
            //vertical lines
            if startPoint.x == endPoint.x {
                if startPoint.y > endPoint.y {
                    return -CGFloat.pi/2
                } else {
                    return CGFloat.pi/2
                }
            }
            //horizatal lines
            if startPoint.y == endPoint.y {
                if startPoint.x < endPoint.x {
                    return 0
                } else {
                    return CGFloat.pi
                }
            }
            
            //non horizantal/vertical lines
            return atan(slopeBetweenPoints(startPoint, endPoint))
        } else {
            //returns perpedicular slope to the radius (slope of tangent)
            var angleOfTangent:CGFloat = atan(-1 * (1/slopeBetweenPoints(position, circleCenter)))
            
            if clockwiseDirection && position.y < circleCenter.y {
                angleOfTangent = atan(-1 * (1/slopeBetweenPoints(position, circleCenter))) + CGFloat.pi
            }
            
            if !clockwiseDirection && position.y > circleCenter.y {
                angleOfTangent = atan(-1 * (1/slopeBetweenPoints(position, circleCenter))) + CGFloat.pi
            }
            
            return angleOfTangent
        }
    }
}
