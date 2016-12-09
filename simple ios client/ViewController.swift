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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {

    func recordAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
                (data: CMAccelerometerData?, error: Error?) in
                print(data!.acceleration)
                let x = String(format: "%.2f", data!.acceleration.x)
                let y = String(format: "%.2f", data!.acceleration.y)
                let z = String(format: "%.2f", data!.acceleration.z)
                let time =
                print(x,y,z)
            }
        }
    }

    func getCurrentTimestamp(){
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle

        let dateString = formatter.stringFromDate(morningOfChristmas)
    }
}


//"yyyy_MM_dd_HH_mm_ss"
