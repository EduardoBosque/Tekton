//
//  ProgressViewController.swift
//  XBike
//
//  Created by Eduardo Vasquez on 14/08/22.
//

import UIKit

class ProgressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let employeeData = UserDefaults.standard.data(forKey: "routes") {
            do {
                let employeeObject = try JSONDecoder().decode(Routes.self, from: employeeData)

                print(employeeObject.time)
                print(employeeObject.distance)

            } catch {
                print(error.localizedDescription)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
