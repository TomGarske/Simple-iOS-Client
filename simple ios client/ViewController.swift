//
//  ViewController.swift
//  simple ios client
//
//  Created by Thomas Garske on 12/9/16.
//  Copyright © 2016 csci4211. All rights reserved.
//

import CoreMotion
import UIKit

class ViewController: UIViewController {

    let serverPath="http://192.168.0.23:5000/dev/api/motiondata"
    let motionManager = CMMotionManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(serverPath)
        recordAccelerometer()
    }
}

// Extension for recording from accelerometer
extension ViewController {
    func recordAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            let sampling = 1.0//0.05
            motionManager.accelerometerUpdateInterval = sampling
            var lastTime = TimeInterval()
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
                (data: CMAccelerometerData?, error: Error?) in
                //print(data!.acceleration)
                let x = data!.acceleration.x
                let y = data!.acceleration.y
                let z = data!.acceleration.z
                let time = (data!.timestamp - lastTime)*1000
                lastTime = data!.timestamp

                if(time<1000){
                    //print(x,y,z,time)
                    let json = [ "x":x,"y":y,"z":z,"t":time]
                    self.postRequest(path: self.serverPath,data:json)
                }
            }
        }
    }
}

// Extension for sending post requests
extension ViewController {
    func postRequest(path : String, data : Dictionary<String, Double>) {
        print(data)
        let url = URL(string: path)!
        let session = URLSession.shared

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.cachePolicy = .reloadIgnoringCacheData
            request.httpBody = jsonData
            print(jsonData)

            let task = session.dataTask(with: request){ data,response,error in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                print(response!)
            }
            task.resume()
        }catch {
            print(error)
        }
    }
}
