//
//  VehicleTests.swift
//  CarsTests
//
//  Created by Sasi M on 28/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

import XCTest

class VehicleTests: XCTestCase {
    
    var vehicleData: Dictionary<String, Any>?
    
    override func setUp() {
        super.setUp()
        vehicleData = ["poiList": [
            [
                "id": 405818,
                "coordinate": [
                    "latitude": 53.52044570791916,
                    "longitude": 9.768903676082997
                ],
                "fleetType": "POOLING",
                "heading": 92.99695057285226
            ],
            [
                "id": 383726,
                "coordinate": [
                    "latitude": 53.41829355848949,
                    "longitude": 9.948689445944431
                ],
                "fleetType": "TAXI",
                "heading": 271.8756871348822
            ],
            [
                "id": 552194,
                "coordinate": [
                    "latitude": 53.49700728625262,
                    "longitude": 10.07602175190052
                ],
                "fleetType": "POOLING",
                "heading": 104.31606854256393
            ],
            [
                "id": 345393,
                "coordinate": [
                    "latitude": 53.4900098884734,
                    "longitude": 9.912344771427113
                ],
                "fleetType": "POOLING",
                "heading": 308.478106210829
            ],
            [
                "id": 205187,
                "coordinate": [
                    "latitude": 53.46350921081882,
                    "longitude": 9.859141502291575
                ],
                "fleetType": "POOLING",
                "heading": 30.780401916923303
            ]]]
    }
    
    override func tearDown() {
        vehicleData = nil
        super.tearDown()
    }
    
    func testVehicle() {
        let vehiclesJSONData = try! JSONSerialization.data(withJSONObject: vehicleData!, options: .prettyPrinted)
        let vehicles = try! JSONDecoder().decode(Vehicles.self, from: vehiclesJSONData)
        XCTAssertEqual(vehicles.vehicles.count, 5)
        var i = 0
        for vehicleDetails in vehicleData!["poiList"] as! [[String : Any]] {
            let vehicle = vehicles.vehicles[i]
            let coordinate = vehicleDetails["coordinate"] as! [String : Double]
            XCTAssertEqual(vehicle.id, Int64(vehicleDetails["id"] as! Int))
            XCTAssertEqual(vehicle.coordinate.latitude,  coordinate["latitude"])
            XCTAssertEqual(vehicle.coordinate.longitude, coordinate["longitude"])
            XCTAssertEqual(vehicle.fleetType, vehicleDetails["fleetType"] as! String)
            XCTAssertEqual(vehicle.heading, vehicleDetails["heading"] as! Double)
            i += 1
        }
    }
    
}
