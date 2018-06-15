//
//  CarClass.swift
//  TrafficSim
//
//  Created by Student2018 on 2018-05-07.
//  Copyright © 2018 Big_Dump_11. All rights reserved.
//


import Foundation
import SpriteKit

class CarClass {
    
    var angle:CGFloat = 0
    var position:CGPoint = CGPoint(x: 0, y: 0)
    var speed:CGFloat = 0
    var acceleration:CGFloat = 0
    
    var distanceDownCurrentRoad:CGFloat = 0
    var currentRoad:Road?
    
    let carSprite:SKSpriteNode
    
    let carName:String
    
    init (imageName:String = "Car4", startRoad:Int, initialSpeed:CGFloat = 0) {
        
        //sprite stuff
        self.carSprite = SKSpriteNode(imageNamed: imageName)
        
        self.speed = initialSpeed
        
        //stuff that will never change about the car
        self.carSprite.size = CGSize(width: (GLOBALSCALE*carSprite.size.width/6), height: (GLOBALSCALE*carSprite.size.height/6))
        self.carSprite.anchorPoint = CGPoint(x: 0.35, y: 0.5)
        
        self.carName = imageName
        
        //starting the car on the road
        self.currentRoad = allRoads[startRoad]
        self.distanceDownCurrentRoad = 0
    }
    
    //returns a new speed that the car should be going so that it will be travelling "final velocity" before it reaches the specified distace
    func brake (_ distanceLeft:CGFloat) {
        
        //if distance left is big, and we are already going slow, we doont wanna be slowing down more, that would just take forever to get places
        if distanceLeft > 20 * GLOBALSCALE && speed <= 0.1*GLOBALSCALE {
            self.acceleration = 1*GLOBALSCALE
            return
        }
        
        //if we are already stoped (or going backwards) we should just stop
        if self.speed <= 0.001*GLOBALSCALE {
            self.acceleration = 0
            self.speed = 0
            return
        }
        
        //if we are at the distacne specified we want to be stopped
        if distanceLeft <= 0 {
            self.acceleration = 0
            self.speed = 0
            return
        }
        
        //otherwise do suvat equation
        self.acceleration = -pow(self.speed, 2)/(2*distanceLeft)
        
    }
    
    
    //pathfinding
    //will return the next road that the car should go onto
    func pathFind (destination:Road) -> Road {
        
        //dynamic recursion array thing, keeps track of what every branch in the "tree" is
        var everyPath = [[currentRoad!]]
        
        while true {
            var newPaths = [[Road]]()
            
            for i in 0...everyPath.count-1 {
                for j in 0...(everyPath[i].last?.nextRoads.count)!-1 {
                    
                    //as long as the next roads arn't already used, then add them to the list of lists of roads
                    if !contains(everyPath[i], (everyPath[i].last?.nextRoads[j])!) {
                        newPaths.append(everyPath[i])
                        newPaths[newPaths.count-1].append((everyPath[i].last?.nextRoads[j])!)
                        
                        
                        //if we have found the correct path:
                        if newPaths.last?.last === destination {
                            return (newPaths.last?[1])!
                        }
                    }
                }
            }
            
            //if the newPaths is empty then we leave
            if newPaths.count == 0 {
                print("pathfinding error")
                return currentRoad!
            }
            
            //updating everyPath
            everyPath = newPaths
        }
    }
   
    
    func canGoAtStopSign () -> Bool {
        
        //the road segment that is 4 ahead of the list of the current incoming road into the intersection is the road traveling in the opposite direction of that of the car
        
        //if there is a car present on the the intersection's "IntersectionThroughRoads" then we will not go
        for tempCar in allCars {
            //see if the tempcar even is in AN intersection
            if tempCar.currentRoad?.associatedIntersection != nil {
                //test to see if the car is in THE intersection that the current car/self is in
                if tempCar.position.x <= (self.currentRoad?.associatedIntersection?.topRightCorner.x)!
                    && tempCar.position.x >= (self.currentRoad?.associatedIntersection?.bottomLeftCorner.x)!
                    && tempCar.position.y <= (self.currentRoad?.associatedIntersection?.topRightCorner.y)!
                    && tempCar.position.y >= (self.currentRoad?.associatedIntersection?.bottomLeftCorner.y)! {
                    
                    //check to see if it is traveling on a raod i the intersection
                    if (tempCar.currentRoad?.roadType == "intersectionRight"
                        || tempCar.currentRoad?.roadType == "intersectionLeft"
                        || tempCar.currentRoad?.roadType == "intersectionStraight") {
                        //also, if the car is on the road we want to be in after the intersection and stopped, we wont go
                        return false
                    }
                }
            }
        }
        
        //if weve gotten here it means it is safe to go through the intersection
        return true
    }
    
    func accelerateToSpeed (acceleration:CGFloat, maxSpeed:CGFloat) {
        if self.speed >= maxSpeed {
            self.speed = maxSpeed
            self.acceleration = 0
        } else {
            self.acceleration = acceleration
        }
    }
 
    //takes the car sprite, and updates it's position/rotation and which road it is on
    func updateCar (destination:Int = 1) {
        
        //debugging
        if DEBUG {
            print()
            print("car name: ", carName)
            print("angle:", angle * 180 / CGFloat.pi, "degrees")
            print("speed:", self.speed)
            print("acceleration: ", self.acceleration)
            print("position:", self.position)
            print()
        }
        
        
        
        //if there are no more roads, avoid crashing the program:
        if currentRoad == nil {
            return
        }
        
        //braking at stop signs
        if self.currentRoad?.roadType == "intersectionIn" {
            
            if speed == 0 && DEBUG {
                print("CAR", self.carName, "STOPPED")
            }
            
            //seeing if it is time to pass the current stop sign
            if speed == 0 && canGoAtStopSign() {
                self.acceleration = 0.1 * GLOBALSCALE
            }
            
            if speed != 0 {
                brake((self.currentRoad?.length)! - distanceDownCurrentRoad - (0.05 * GLOBALSCALE))
            }
            
        } else {
            //speeding back up
            accelerateToSpeed(acceleration: 0.1, maxSpeed: 2)
        }
        
        //avoid rear-ending
        for tempCar in allCars {
            //we dont want to avoid running into our own bumper
            if tempCar === self {
                continue
            }
            //looking 1 road segment ahead, if theres a car there, then slow down
            if tempCar.currentRoad === self.currentRoad?.nextRoads[0] {
                brake((self.currentRoad?.length)! - self.distanceDownCurrentRoad - 100*GLOBALSCALE)
                break
            }
        }
        
        //acceleration
        speed += acceleration
        
        //moving down the road
        //check if we are going to run off of the current road we are on
        if (abs((currentRoad?.length)!) - distanceDownCurrentRoad) < speed {
            
            //if there are no more roads to transfer onto, avoid crashing the program:
            if self.currentRoad?.nextRoads.count == 0 {
                return
            }
            
            //moving onto the next road
            //(PATHFINDING) if we are already at the destination, do nothing
            if self.currentRoad === allRoads[destination] {
                return
            }
            
            self.currentRoad = pathFind(destination: allRoads[destination])
            
            
            self.distanceDownCurrentRoad = 0
        } else {
            self.distanceDownCurrentRoad += speed
            self.position = (currentRoad?.moveDownRoad(distanceDownCurrentRoad, currentPos: position))!
            self.angle = (currentRoad?.angleOfRoad(distanceDownCurrentRoad, position))!
        }
        
        //updating the sprite stuff
        self.carSprite.position = position
        self.carSprite.zRotation = angle
    }
}
