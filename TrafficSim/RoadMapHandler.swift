//the following will take the file that the c++ program makes, prosseses it, and turns it into an array of roads

import Foundation


//couldn't make this work :(. It would excecute the c++ program that would process the road map
func executeCommand(_ command: String) {
    let task = Process()
    
    task.launchPath = command
    
    task.standardOutput = pipe
    task.launch()
}

//so I can go though a LIST of pixels as if it were a GRID of pixels
//the
func cartesianToListVal(_ x:Int, _ y:Int) -> Int {
    //the pixels are saved into the array like this:
    //pixels left/right of a space is a difference of 1 pixel (1 space in list). Left side is the lowest in the list
    //pixels top/bottom of a space is a difference of 100 pixels. Bottom is lowest in list
    
    //this way, the origin is the center of the bmp
    return 100*(y+50)+(x+50) - 1
}

func makeRoads (_ fileName:String) {
    
    //file input
    let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var inString = ""
    // If the directory was found, we write a file to it and read it back
    if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
        do {
            inString = try String(contentsOf: fileURL)
        } catch {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        print("Read from the file: \(inString)")
    }
    
    //time to turn the string of values into an array of ints
    var arrayOfStringNumbers:[String] = inString.components(separatedBy: " ")
    arrayOfStringNumbers.removeLast()
    
    var processedPixels = [[Int]]()
    for pixel in 0..<arrayOfStringNumbers.count/3 {
        var tempPixelData = [Int]()
        for RGB in 0...2 {
            tempPixelData.append(Int(arrayOfStringNumbers[3*pixel + RGB])!)
        }
        processedPixels.append(tempPixelData)
    }
    
    //for ease of use
    let black = [0, 0, 0]           //straight roads
    let white = [255, 255, 255]     //nothingness
    let red = [255, 0, 0]           //intersections
    let green = [0, 255, 0]         //turning roads
    
    //the bottom left should be -49, -49, so that the center of the pic is 0,0
    for y in -49...49 {
        for x in -49...49 {
            
            //roads that turn (green pixels):
            if processedPixels[cartesianToListVal(x, y)] == green {
                //from west to north
                if processedPixels[cartesianToListVal(x-1, y)] == black && processedPixels[cartesianToListVal(x, y+1)] == black {
                    _ = RoadSegment(CGPoint(x: CGFloat(x)*50*GLOBALSCALE - 75*GLOBALSCALE,
                                            y: CGFloat(y)*50*GLOBALSCALE + 75*GLOBALSCALE),
                                    50*GLOBALSCALE, false, corner: "bottomRight", masterRoadNetwork: &allRoads)
                }
                
                //from east to north
                if processedPixels[cartesianToListVal(x+1, y)] == black && processedPixels[cartesianToListVal(x, y+1)] == black {
                    _ = RoadSegment(CGPoint(x: CGFloat(x)*50*GLOBALSCALE + 25*GLOBALSCALE,
                                            y: CGFloat(y)*50*GLOBALSCALE + 25*GLOBALSCALE),
                                    50*GLOBALSCALE, false, corner: "bottomLeft", masterRoadNetwork: &allRoads)
                }
                
                //from west to south
                if processedPixels[cartesianToListVal(x-1, y)] == black && processedPixels[cartesianToListVal(x, y-1)] == black {
                    _ = RoadSegment(CGPoint(x: CGFloat(x)*50*GLOBALSCALE - 125*GLOBALSCALE,
                                            y: CGFloat(y)*50*GLOBALSCALE - 25*GLOBALSCALE),
                                    50*GLOBALSCALE, false, corner: "topRight", masterRoadNetwork: &allRoads)
                }
                
                //from east to south
                if processedPixels[cartesianToListVal(x+1, y)] == black && processedPixels[cartesianToListVal(x, y-1)] == black {
                    _ = RoadSegment(CGPoint(x: CGFloat(x)*50*GLOBALSCALE - 25*GLOBALSCALE,
                                            y: CGFloat(y)*50*GLOBALSCALE - 75*GLOBALSCALE),
                                    50*GLOBALSCALE, false, corner: "topLeft", masterRoadNetwork: &allRoads)
                }
            }
            
            
            
            //if the pixel is black, then we found a straight road!
            if processedPixels[cartesianToListVal(x, y)] == black {
                //can we test the pixels up/down/left/right? (this means that I cant really make roads on the very edge of the map, but I'm too lazy to really care, and I dont think that I'm ever going to create a city that big)
                
                
                if y != -49 && y != 49 && x != -49 && x != 49 {
                    //is it a vertical road?
                    if processedPixels[cartesianToListVal(x, y+1)] == black && processedPixels[cartesianToListVal(x, y-1)] == black {
                        //this is the road, we offset it so the center of the pixel is the coordinate it corresponts to
                        _ = RoadSegment(CGPoint(x: CGFloat(x)*GLOBALSCALE*50 - GLOBALSCALE*25,
                                                y: CGFloat(y)*GLOBALSCALE*50 - GLOBALSCALE*25),
                                        50*GLOBALSCALE, true, masterRoadNetwork:&allRoads)
                    }
                    //is it a horizantal road?
                    if processedPixels[cartesianToListVal(x-1, y)] == black && processedPixels[cartesianToListVal(x+1, y)] == black {
                        _ = RoadSegment(CGPoint(x: CGFloat(x)*GLOBALSCALE*50 - GLOBALSCALE*25,
                                                y: CGFloat(y)*GLOBALSCALE*50 + GLOBALSCALE*25),
                                        50*GLOBALSCALE, false, masterRoadNetwork:&allRoads)
                    }
                    
                    
                }
            }
            
            //is it a intersection?
            if processedPixels[cartesianToListVal(x, y)] == red {
                _ = Intersection(CGPoint(x:CGFloat(x)*GLOBALSCALE*50 - GLOBALSCALE*175,
                                         y:CGFloat(y)*GLOBALSCALE*50 - GLOBALSCALE*125),
                                 masterRoadNetwork:&allRoads)
                
            }
        }
    }
    
}
