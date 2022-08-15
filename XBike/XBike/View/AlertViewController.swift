//
//  AlertViewController.swift
//  XBike
//
//  Created by Eduardo Vasquez on 14/08/22.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet weak var initialAlert: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialAlert.
    }

    @IBAction func startTapped(_ sender: Any) {
        let timer2 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            print("Timer fired!")
        }
        
        print(timer2)
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
//    {
//        let touch = touches.first
//        if touch?.view != self.initialAlert {
//        }
//    }
}
