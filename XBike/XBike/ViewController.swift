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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        pin.isHidden = true
        
        getLocation()
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
            
            self?.showMarker(position: coordinate, addressInformation: address)
            self?.nextLocation = coordinate
        }
    }
    
    func route(position: CLLocationCoordinate2D){
        let origin = "\(locationManager.location?.coordinate.latitude ?? 0),\(locationManager.location?.coordinate.longitude ?? 0)"
        let destination = "\(position.latitude),\(position.longitude)"

        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(kGoogleMapsAPI)"

        let url = URL(string: urlString)
            URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                if(error != nil){
                    print("error")
                }else{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                        let routes = json["routes"] as! NSArray

                        for route in routes
                        {
                            let routeOverviewPolyline: NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3


                            let legs: Array = (route as! NSDictionary).value(forKey: "legs") as! Array<Any>
                            let distance = (legs.first as AnyObject).value(forKey: "distance") as! Dictionary<String,Any>
                            print(distance["text"] ?? "")
                            
                            polyline.map = self.mapView

                        }
                    } catch let error as NSError{
                        print("error:\(error)")
                    }
                }
            }).resume()
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
            
            let alert = AlertViewController()
            alert.view.frame = self.view.bounds
            self.view.addSubview(alert.view)
            self.addChild(alert)
            alert.didMove(toParent: self)
            
            
//            alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//            self.present(alert, animated: true)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        self.locationManager.requestAlwaysAuthorization()

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
