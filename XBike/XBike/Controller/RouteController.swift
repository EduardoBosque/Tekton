//
//  RouteController.swift
//  XBike
//
//  Created by Eduardo Vasquez on 29/08/22.
//

import UIKit
import GoogleMaps

class RouteController {
    
    func route(origin: CLLocationCoordinate2D, position: CLLocationCoordinate2D, mapView: GMSMapView, responseHandler: @escaping (String) -> Void) {
        
        let urlString = Utilities.urlRoute(origin: origin, destination: position)
        let url = URL(string: urlString)
        var distanceText = kEmptyString
        
        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if(error != nil){
                print("error getting line")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json[kRoutes] as! NSArray

                    OperationQueue.main.addOperation({

                        for route in routes
                        {
                            let routeOverviewPolyline: NSDictionary = (route as! NSDictionary).value(forKey: kPolyline) as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: kPoints)
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3

                            let legs: Array = (route as! NSDictionary).value(forKey: kLegs) as! Array<Any>
                            let distance = (legs.first as AnyObject).value(forKey: kDistance) as! Dictionary<String,Any>
                            distanceText = distance[kText] as! String
                            
                            responseHandler(distanceText)
                            
                            polyline.map = mapView

                        }
                        
                    })
                } catch let error as NSError{
                    print("error: \(error)")
                }
            }
        }).resume()
    }
}
