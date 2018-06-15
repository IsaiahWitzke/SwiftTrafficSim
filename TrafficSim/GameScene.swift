//
//  GameScene.swift
//  TrafficSim
//
//  Created by Student2018 on 2018-04-19.
//  Copyright © 2018 Big_Dump_11. All rights reserved.
//

import SpriteKit

//set to true if we want extra info output
var DEBUG = true


//"global" that keeps track of the time inbetween frames
var DELTATIME = 0.0

//all objects used
var allRoads:[Road] = []
var allCars:[CarClass] = []

// a variable that will affect the size and relative position of EVERYTHING
var GLOBALSCALE:CGFloat = 0.5

class GameScene: SKScene {
    
    //to do with the deltatime variable
    var lastTime = CFAbsoluteTimeGetCurrent()
    
    
    override func didMove(to view: SKView) {
        
        //this is in preeeeee-alpha, doesn't seem to be able to run the c++ program within swift though
        //executeCommand("/Users/student2018/Desktop/SwiftProjects/TrafficSim/RoadMapProcessing/RoadmapProcessingApp")
        
        makeRoads("ProcessedRoadMap")
        
        backgroundColor = SKColor.brown
        
        //making the network of raods (the roads are made in the RoadMapHandler, but here is where we link the roads together)
        purgeDeadEnds(&allRoads)    //so there are no dead ends (important for 3-way intersections)
        connnectAllRoads(&allRoads) //very important to connect all roads and actually "network" the network of roads
        
        
        //adding children to the scene
        
        //as long as we have roads to render we will add them to the screen
        if allRoads.count != 0 {
            for i in 0...allRoads.count-1 {
                addChild(allRoads[i].roadLine)
            }
        }
        
        
        
        //initializing cars (at random positions)
        allCars.append(CarClass(imageName: "Car1", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        
        allCars.append(CarClass(imageName: "Car2", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car3", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car4", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car5", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car6", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car7", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car1", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car2", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car3", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car4", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car5", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car6", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        allCars.append(CarClass(imageName: "Car7", startRoad: Int(arc4random_uniform(UInt32(allRoads.count))), initialSpeed: 2))
        
        
        //adding cars to screen
        if allCars.count != 0 {
            for i in 0...allCars.count-1 {
                addChild(allCars[i].carSprite)
            }
        }
        
        if DEBUG {
            print("number of cars in scene: ", allCars.count)
            print("number of roads in scene: ", allRoads.count)
        }
    }
    
    //temporary variable to keep track of the number of frames that have past
    var numberOfFrames = 0
    
    override func update(_ currentTime: TimeInterval) {
        
        //updating deltaTime
        DELTATIME = CFAbsoluteTimeGetCurrent() - lastTime
        lastTime = CFAbsoluteTimeGetCurrent()
        
        if DEBUG {
            print()
            print("Delta Time:", DELTATIME)
        }
        
        //cars' update function needs to be called once per frame
        for i in 0..<allCars.count {
            allCars[i].updateCar(destination: i*10)
        }
        
        
        //keeping track of the number of frames that have passed
        numberOfFrames += 1
    }
}
