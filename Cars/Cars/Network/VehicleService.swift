//
//  vehicleService.swift
//  Cars
//
//  Created by Sasi M on 25/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

import Foundation
import CoreLocation

let defaultNECoordinate = CLLocationCoordinate2D.init(latitude: 13.196152, longitude: 80.248415)
let defaultSWCoordinate = CLLocationCoordinate2D.init(latitude: 12.848956, longitude: 80.067058)

public enum Result: Equatable {
    case success(Vehicles)
    case failure(String)
}

public func ==(lhs: Result, rhs: Result) -> Bool {
    switch (lhs, rhs) {
    case let (.success(a),   .success(b)):
         return a == b
        
    case let (.failure(a), .failure(b)):
        return a == b
    default:
        return false
    }
}

protocol VehicleServiceProtocol {
    func getVehicles(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D, complete: @escaping (_ result: Result)->() )
}

extension VehicleServiceProtocol {
    func getVehicles(neCoordinate: CLLocationCoordinate2D = defaultNECoordinate,
                     swCoordinate: CLLocationCoordinate2D = defaultSWCoordinate,
                     complete: @escaping (_ result: Result)->() ) {
        return getVehicles(neCoordinate: neCoordinate, swCoordinate: swCoordinate, complete: complete)
    }
}

open class VehicleService: VehicleServiceProtocol {
    
    private var apiEndPoint = ""
    
    public init() {}
    
    func getVehicles(neCoordinate: CLLocationCoordinate2D = defaultNECoordinate,
                     swCoordinate: CLLocationCoordinate2D = defaultSWCoordinate,
                     complete: @escaping (_ result: Result)->() ) {
        
        
        if let path = Bundle.main.path(forResource: "response", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let vehicles = try! JSONDecoder().decode(Vehicles.self, from: data)
                complete(Result.success(vehicles))
            } catch {
                complete(Result.failure("Unable to parse JSON response"))
            }
        }
        
        // Below code will connect with actual apiEndPoint and retrieve data
        /*
        if (CLLocationCoordinate2DIsValid(neCoordinate) == false ||
            CLLocationCoordinate2DIsValid(neCoordinate) == false) {
            complete(Result.failure("Invalid coordinates"))
            return
        }
        
        var urlString = apiEndPoint
        urlString += "p1Lat=\(neCoordinate.latitude)"
        urlString += "&p1Lon=\(neCoordinate.longitude)"
        urlString += "&p2Lat=\(swCoordinate.latitude)"
        urlString += "&p2Lon=\(swCoordinate.longitude)"
        
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            DispatchQueue.main.async(execute: {
                if error != nil {
                    complete(Result.failure("Communication error. \(error!.localizedDescription)"))
                    return
                }
                if data != nil {
                    do {
                        let resultObject = try JSONSerialization.jsonObject(with: data!, options: [])
                        print("Results from GET \(url) :\n\(resultObject)")
                        let vehicles = try! JSONDecoder().decode(Vehicles.self, from: data!)
                        complete(Result.success(vehicles))
                        
                    } catch {
                        complete(Result.failure("Unable to parse JSON response"))
                    }
                } else {
                    complete(Result.failure("Received empty response"))
                }
            })
        }).resume()
 */
    }
}
