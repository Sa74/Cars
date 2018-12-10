//
//  VehicleServiceTests.swift
//  CarsTests
//
//  Created by Sasi M on 28/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

import XCTest
import CoreLocation

class VehicleServiceTests: XCTestCase {
    
    var vehicleService: VehicleService?
    
    override func setUp() {
        super.setUp()
        vehicleService = VehicleService()
    }
    
    override func tearDown() {
        vehicleService = nil
        super.tearDown()
    }
    
    func testDeafultVehicleFetch() {
        
        let apiService = vehicleService
        
        let expect = XCTestExpectation(description: "callback")
        apiService?.getVehicles(complete: { (result) in
            expect.fulfill()
            if case .success(let vehicles) = result {
                XCTAssertTrue(vehicles.vehicles.count > 0)
            } else {
                XCTFail("Invalid response")
            }
        })
        wait(for: [expect], timeout: 3.1)
    }
    
    func testInvalidRegionFetch() {
        
        let apiService = vehicleService
        
        let expect = XCTestExpectation(description: "callback")
        apiService?.getVehicles(neCoordinate: kCLLocationCoordinate2DInvalid, swCoordinate: kCLLocationCoordinate2DInvalid, complete: { (result) in
            
            expect.fulfill()
            if case .failure(let message) = result {
                XCTAssertTrue(message == "Invalid coordinates")
            } else {
                XCTFail("Invalid response")
            }
        })
        wait(for: [expect], timeout: 3.1)
    }
    
}
