//
//  VehicleViewModelTests.swift
//  CarsTests
//
//  Created by Sasi M on 28/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

import XCTest
import CoreLocation

class VehicleViewModelTests: XCTestCase {
    
    var vehicleData: Dictionary<String, Any>!
    var vehicles: Vehicles!
    var mockVehicleService: MockVehicleService!
    var mockVehicleModelObserver: MockVehicleObserver!
    var vehicleViewModel: VehicleViewModel!
    
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
        let vehiclesJSONData = try! JSONSerialization.data(withJSONObject: vehicleData!, options: .prettyPrinted)
        vehicles = try! JSONDecoder().decode(Vehicles.self, from: vehiclesJSONData)
        mockVehicleService = MockVehicleService(vehicles)
        mockVehicleModelObserver = MockVehicleObserver()
        vehicleViewModel = VehicleViewModel(mockVehicleService!)
        vehicleViewModel!.addObserver(mockVehicleModelObserver!)
    }
    
    override func tearDown() {
        vehicleData = nil
        vehicles = nil
        mockVehicleService = nil
        vehicleViewModel = VehicleViewModel()
        super.tearDown()
    }
    
    func testInit() {
        XCTAssertEqual(vehicleViewModel.vehicleType, .All)
        XCTAssertEqual(vehicleViewModel.getNumberOfVehicles(), 0)
        XCTAssertEqual(vehicleViewModel.canSelectVehicle, false)
    }
    
    func testVehicleDataLoad() {
        mockVehicleService.vehicles = vehicles
        vehicleViewModel.fetchVehicles()
        mockVehicleService.fetchSuccess()
        XCTAssert(mockVehicleService.isVehicleFetchCalled)
        XCTAssert(mockVehicleModelObserver.isReloadCalled)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayBookingTabCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayWarningCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isHideBookingTabCalled == false)
        XCTAssertEqual(vehicleViewModel.getNumberOfVehicles(), 5)
        XCTAssertEqual(vehicleViewModel.canSelectVehicle, true)
        XCTAssertTrue(vehicleViewModel.selectedVehicle == nil)
        mockVehicleModelObserver.reset()
    }
    
    func testVehicleDataLoadFailure() {
        vehicleViewModel.fetchVehicles()
        mockVehicleService.fetchFail(error: Result.failure("Invalid coordinates"))
        XCTAssert(mockVehicleService.isVehicleFetchCalled)
        XCTAssertEqual(vehicleViewModel.canSelectVehicle, false)
        XCTAssertTrue(vehicleViewModel.selectedVehicle == nil)
        XCTAssert(mockVehicleModelObserver.isReloadCalled)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayWarningCalled)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayBookingTabCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isHideBookingTabCalled == false)
        mockVehicleModelObserver.reset()
    }
    
    func testVehicleCellModel() {
        vehicleViewModel.fetchVehicles()
        mockVehicleService.fetchSuccess()
        
        var i = 0
        for vehicle in vehicles.vehicles {
            let vehicleCellModel = vehicleViewModel.getVehicleCellModel(at: IndexPath.init(row: i, section: 0))
            XCTAssertEqual(vehicle.id, vehicleCellModel.vehicleId)
            XCTAssertEqual(vehicle.fleetType, vehicleCellModel.titleText)
            if (i == 1) {
                XCTAssertEqual(vehicleCellModel.descText, "Get your own cab")
                XCTAssertEqual(vehicleCellModel.vehicleImage, UIImage.init(named: "Taxi"))
            } else {
                XCTAssertEqual(vehicleCellModel.descText, "Eco friendly rides")
                XCTAssertEqual(vehicleCellModel.vehicleImage, UIImage.init(named: "Pool"))
            }
            i += 1
        }
    }
    
    func testVehicleMapModel() {
        vehicleViewModel.fetchVehicles()
        mockVehicleService.fetchSuccess()
        
        var i = 0
        for vehicle in vehicles.vehicles {
            let vehicleMapModel = vehicleViewModel.getVehicleMapModel(at: i)
            XCTAssertEqual(vehicleMapModel.id, vehicle.id)
            XCTAssertEqual(vehicleMapModel.title, vehicle.fleetType)
            XCTAssertEqual(vehicleMapModel.heading, vehicle.heading)
            XCTAssertEqual(vehicleMapModel.coordinate.latitude, vehicle.coordinate.latitude)
            XCTAssertEqual(vehicleMapModel.coordinate.longitude, vehicle.coordinate.longitude)
            if (i == 1) {
                XCTAssertEqual(vehicleMapModel.annotationImage, UIImage.init(named: "TaxiPin"))
                XCTAssertEqual(vehicleMapModel.vehicleImage, UIImage.init(named: "Taxi"))
            } else {
                XCTAssertEqual(vehicleMapModel.annotationImage, UIImage.init(named: "PoolPin"))
                XCTAssertEqual(vehicleMapModel.vehicleImage, UIImage.init(named: "Pool"))
            }
            i += 1
        }
    }
    
    func testVehicleSelection() {
        vehicleViewModel.fetchVehicles()
        mockVehicleService.fetchSuccess()
        mockVehicleModelObserver.reset()
        
        vehicleViewModel.selectVehicle(withId: 0)
        XCTAssertTrue(vehicleViewModel.selectedVehicle == nil)
        XCTAssertTrue(mockVehicleModelObserver.isReloadCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayWarningCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayBookingTabCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isHideBookingTabCalled == false)
        mockVehicleModelObserver.reset()
        
        vehicleViewModel.selectVehicle(withId: 405818)
        XCTAssertTrue(vehicleViewModel.selectedVehicle == vehicles.vehicles[0])
        XCTAssertTrue(mockVehicleModelObserver.isReloadCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayWarningCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayBookingTabCalled == true)
        XCTAssertTrue(mockVehicleModelObserver.isHideBookingTabCalled == false)
        mockVehicleModelObserver.reset()
        
        vehicleViewModel.selectVehicle(withId: 345393)
        XCTAssertTrue(vehicleViewModel.selectedVehicle == vehicles.vehicles[3])
        mockVehicleModelObserver.reset()
        
        vehicleViewModel.selectVehicle(withId: 0)
        XCTAssertTrue(vehicleViewModel.selectedVehicle == nil)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayBookingTabCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isHideBookingTabCalled == true)
        mockVehicleModelObserver.reset()
    }
    
    func testPoolTypeSelection() {
        vehicleViewModel.fetchVehicles()
        mockVehicleService.fetchSuccess()
        mockVehicleModelObserver.reset()
        
        vehicleViewModel.vehicleType = .Pool
        XCTAssert(mockVehicleModelObserver.isReloadCalled)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayWarningCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayBookingTabCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isHideBookingTabCalled == false)
        XCTAssertEqual(vehicleViewModel.getNumberOfVehicles(), 4)
        
        let vehicleCellModel = vehicleViewModel.getVehicleCellModel(at: IndexPath.init(row: 1, section: 0))
        XCTAssertEqual(vehicleCellModel.vehicleId, 552194)
        XCTAssertFalse(vehicleCellModel.vehicleId == 383726)
        
        let vehicleMapModel = vehicleViewModel.getVehicleMapModel(at: 2)
        XCTAssertEqual(vehicleMapModel.id, 345393)
        XCTAssertFalse(vehicleMapModel.id == 552194)
    }
    
    func testTaxiTypeSelection() {
        vehicleViewModel.fetchVehicles()
        mockVehicleService.fetchSuccess()
        mockVehicleModelObserver.reset()
        
        vehicleViewModel.vehicleType = .Taxi
        XCTAssert(mockVehicleModelObserver.isReloadCalled)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayWarningCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isDisplayBookingTabCalled == false)
        XCTAssertTrue(mockVehicleModelObserver.isHideBookingTabCalled == false)
        XCTAssertEqual(vehicleViewModel.getNumberOfVehicles(), 1)
        
        let vehicleCellModel = vehicleViewModel.getVehicleCellModel(at: IndexPath.init(row: 0, section: 0))
        XCTAssertEqual(vehicleCellModel.vehicleId, 383726)
        XCTAssertFalse(vehicleCellModel.vehicleId == 345393)
        
        let vehicleMapModel = vehicleViewModel.getVehicleMapModel(at: 0)
        XCTAssertEqual(vehicleMapModel.id, 383726)
        XCTAssertFalse(vehicleMapModel.id == 552194)
    }
}

class MockVehicleService: VehicleServiceProtocol {
    
    var complete: ((Result) -> ())!
    var vehicles: Vehicles!
    var isVehicleFetchCalled: Bool = false
    
    init(_ vehicles: Vehicles) {
        self.vehicles = vehicles
    }
    
    func getVehicles(neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D, complete: @escaping (Result) -> ()) {
        isVehicleFetchCalled = true
        self.complete = complete
    }
    
    func fetchSuccess() {
        complete(Result.success(vehicles!))
    }
    
    func fetchFail(error: Result) {
        complete(error)
    }
    
}

class MockVehicleObserver: VehicleViewModelObserver {
    
    var isReloadCalled: Bool = false
    var isDisplayBookingTabCalled: Bool = false
    var isDisplayWarningCalled: Bool = false
    var isHideBookingTabCalled: Bool = false
    
    func reloadVehicleData() {
        isReloadCalled = true
    }
    
    func displayBookingTab(forVehicle vehicle: Vehicle) {
        isDisplayBookingTabCalled = true
    }
    
    func displayWarning(message: String) {
        isDisplayWarningCalled = true
    }
    
    func hideBookingTab() {
        isHideBookingTabCalled = true
    }
    
    func reset() {
        isReloadCalled = false
        isDisplayBookingTabCalled = false
        isDisplayWarningCalled = false
        isHideBookingTabCalled = false
    }
}

