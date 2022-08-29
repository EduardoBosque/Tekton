//
//  PageThreeViewController.swift
//  XBike
//
//  Created by Eduardo Vasquez on 29/08/22.
//

import UIKit

protocol Dismiss: AnyObject {
    func dismiss()
}

class PageThreeViewController: UIViewController {
    
    private weak var delegate: Dismiss?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func setDelegateTo(delegate: Dismiss?) {
        self.delegate = delegate
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        delegate?.dismiss()
    }

}
