//
//  ViewController.swift
//  XBike
//
//  Created by Eduardo Vasquez on 12/08/22.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var mapView: GMSMapView!
    @IBOutlet weak var pin: UIImageView!
        
    let locationManager = CLLocationManager()
    var nextLocation = CLLocationCoordinate2D()
    var distance = kEmptyString
    var origin = kEmptyString
    var destination = kEmptyString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        pin.isHidden = true
        
        getLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let showed = defaults.bool(forKey: kOnboarding)

        if !showed {
            let onboarding = OnboardingViewController()
            onboarding.modalPresentationStyle = .fullScreen
            self.present(onboarding, animated: true)
            
            defaults.set(true, forKey: kOnboarding)
        }
    }
    
    func configureLocation(location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
        mapView.camera = camera
        mapView.clear()
        mapView.settings.myLocationButton = true
        reverseGeocode(coordinate: location)
    }
        
    func showMarker(position: CLLocationCoordinate2D, addressInformation: GMSAddress){
        let marker = GMSMarker()
        marker.position = position
        marker.title = addressInformation.lines?.last
        marker.snippet = addressInformation.locality
        marker.map = mapView
    }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()

        geocoder.reverseGeocodeCoordinate(coordinate) {[weak self] response, error in
            guard let address = response?.firstResult() else {
                return
            }
            
            self?.destination = address.lines?.last ?? kEmptyString
            self?.showMarker(position: coordinate, addressInformation: address)
            self?.nextLocation = coordinate
        }
    }
    
    func route(position: CLLocationCoordinate2D){
        
        guard let origin = locationManager.location?.coordinate else {
            return
        }
            
        let line = RouteController()
        line.route(origin: origin, position: position, mapView: self.mapView) { distance in
            self.distance = distance
        }
    }
    
    @IBAction func addTapped(_ sender: Any) {
        pin.isHidden = false
        
    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        guard let location: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        nextLocation = position.target
        
        if Utilities.distanceBetween(startPosition: location, destinationPosition: nextLocation) > 30 && pin.isHidden == false {
            reverseGeocode(coordinate: position.target)
            route(position: position.target)
            pin.isHidden = true
            
            let alert = CounterViewController()
            addChild(alert)
            alert.view.frame = .zero
            self.view.addSubview(alert.initialAlert)
            alert.didMove(toParent: self)
        
            willMove(toParent: nil)
            alert.view.removeFromSuperview()
            removeFromParent()
                        
            alert.initialAlert.translatesAutoresizingMaskIntoConstraints = false
            let bottom = alert.initialAlert.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
            let center = alert.initialAlert.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            bottom.isActive = true
            center.isActive = true
            
            alert.setDelegateTo(delegate: self)

        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        self.locationManager.requestAlwaysAuthorization()
        let geocoder = GMSGeocoder()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            guard let latitude = locationManager.location?.coordinate.latitude,
                  let longitude = locationManager.location?.coordinate.longitude else {
                return
            }
            
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            configureLocation(location: location)
                        
            geocoder.reverseGeocodeCoordinate(location) {[weak self] response, error in
                guard let address = response?.firstResult() else {
                    return
                }
                self?.origin = address.lines?.last ?? kEmptyString
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        if Utilities.distanceBetween(startPosition: location, destinationPosition: nextLocation) > 30 {
            nextLocation = location
        }
        
        locationManager.stopUpdatingLocation()
    }
}

extension ViewController: SaveInformation {
    func save(time: String) {
        let route = Routes(time: time, distance: distance, origin: origin, destination: destination)
        let routes = [route]

        saveRoutes(route: routes)
        
        let alert = CounterViewController()
        addChild(alert)
        alert.view.frame = .zero
        self.view.addSubview(alert.messageView)
        alert.didMove(toParent: self)
    
        willMove(toParent: nil)
        alert.view.removeFromSuperview()
        removeFromParent()
        
        alert.messageView.translatesAutoresizingMaskIntoConstraints = false
        let centerX = alert.messageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let centerY = alert.messageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerX.isActive = true
        centerY.isActive = true
    }
}

extension ViewController {
    
    func saveRoutes(route: [Routes]) {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()

        if let data = UserDefaults.standard.data(forKey: kRoutes) {
            do {
                var routes = try decoder.decode([Routes].self, from: data)
                routes.append(route.first!)
                let data = try encoder.encode(routes)
                UserDefaults.standard.set(data, forKey: kRoutes)

            } catch {
                print("Unable to Decode (\(error))")
            }
        } else {
            do {
                let data = try encoder.encode(route)
                UserDefaults.standard.set(data, forKey: kRoutes)
                
            } catch {
                print("Unable to Encode Array (\(error))")
            }

        }
    }
}
