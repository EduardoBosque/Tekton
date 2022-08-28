//
//  ProgressViewController.swift
//  XBike
//
//  Created by Eduardo Vasquez on 14/08/22.
//

import UIKit

class ProgressViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var routes = [Routes]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
    }
    
    func configureVC() {
        
        if let data = UserDefaults.standard.data(forKey: kRoutes) {
            do {
                let decoder = JSONDecoder()
                routes = try decoder.decode([Routes].self, from: data)

                self.tableView.register(UINib(nibName: RoutesTableViewCell.name, bundle: nil), forCellReuseIdentifier: RoutesTableViewCell.name)
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
            } catch {
                print("Unable to Decode (\(error))")
            }
        }
    }
}

extension ProgressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Value: \(routes[indexPath.row])")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(RoutesTableViewCell.self)", for: indexPath) as! RoutesTableViewCell
        cell.timeLbl?.text = routes[indexPath.row].time
        cell.distanceLbl?.text = routes[indexPath.row].distance
        cell.origin?.text = routes[indexPath.row].origin
        cell.destination?.text = routes[indexPath.row].destination
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
