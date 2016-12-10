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

    let motionManager = CMMotionManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        recordAccelerometer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {

    func recordAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            let sampling = 0.05
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
                    print(x,y,z,time)
                }
            }
        }
    }
}
