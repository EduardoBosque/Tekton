//
//  AlertViewController.swift
//  XBike
//
//  Created by Eduardo Vasquez on 14/08/22.
//

import UIKit

protocol SaveInformation: AnyObject {
    func save(time: String)
}

class AlertViewController: UIViewController {

    @IBOutlet weak var initialAlert: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    
    private weak var delegate: SaveInformation?
    var count = 10
    var countUpClock: Timer?
    
    private var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setDelegateTo(delegate: SaveInformation?) {
        self.delegate = delegate
    }

    @IBAction func startTapped(_ sender: Any) {
        let startTime = Date()
        let countTime = Date()
        
        if startTime <= countTime {
            countUpClock = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.timeLbl.text = self?.formatter.string(from: startTime, to: Date())
            }
        }
    }
    
    @IBAction func stopTapped(_ sender: Any) {        
        countUpClock?.invalidate()
        self.initialAlert.removeFromSuperview()
        self.delegate?.save(time: self.timeLbl.text ?? "")
    }
}
