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
        
        getLocation()
    }
    
    func configureLocation(location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
        mapView.camera = camera
        mapView.clear()
        showMarker(position: camera.target)
        mapView.settings.myLocationButton = true
    }
        
    func showMarker(position: CLLocationCoordinate2D){
        let marker = GMSMarker()
        marker.position = position
        marker.title = "Palo Alto"
        marker.snippet = "San Francisco"
        marker.map = mapView
    }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()

        geocoder.reverseGeocodeCoordinate(coordinate) {[weak self] response, error in
            guard let address = response?.firstResult(),
                  let lines = address.lines else {
                return
            }
            
            self?.showMarker(position: coordinate)
            self?.nextLocation = coordinate
//            print(lines.joined(separator: "\n"))
        }
    }
    
    func route(position: GMSCameraPosition){
        let origin = "\(locationManager.location?.coordinate.latitude ?? 0),\(locationManager.location?.coordinate.longitude ?? 0)"
        let destination = "\(position.target.latitude),\(position.target.longitude)"

        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(kGoogleMapsAPI)"

        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if(error != nil){
                print("error")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
//                            self.mapView.clear()
                        

                    OperationQueue.main.addOperation({
                        for route in routes {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3

                            let bounds = GMSCoordinateBounds(path: path!)
                            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))

                            polyline.map = self.mapView

                        }
                    })
                } catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocode(coordinate: position.target)
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
        
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let destinationLocation = CLLocation(latitude: nextLocation.latitude, longitude: nextLocation.longitude)
        let distance = userLocation.distance(from: destinationLocation)
        
        if Utilities.roundDistance(x: distance) > 30 {
            print("Distancia: \(Utilities.roundDistance(x: distance))")
            nextLocation = location
            locationManager.stopUpdatingLocation()
            
        }
    }
}
