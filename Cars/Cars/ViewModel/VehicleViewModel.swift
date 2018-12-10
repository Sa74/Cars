//
//  VehicleViewModel.swift
//  Cars
//
//  Created by Sasi M on 25/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

public enum VehicleType: Int {
    case All = 1,
    Pool,
    Taxi
}

protocol VehicleViewModelObserver: AnyObject {
    func reloadVehicleData()
    func displayBookingTab(forVehicle vehicle: Vehicle)
    func displayWarning(message: String)
    func hideBookingTab()
}

extension VehicleViewModelObserver {
    func reloadVehicleData() {}
    func displayBookingTab(forVehicle vehicle: Vehicle) {}
    func displayWarning(message: String) {}
    func hideBookingTab() {}
}

@objc open class VehicleViewModel: NSObject {
    
    let vehicleService: VehicleServiceProtocol!
    private var observations = [ObjectIdentifier : Observation]()
    private var vehicleCellModels: [VehicleCellModel] = [VehicleCellModel]()
    private var vehicleMapModels: [VehicleMapModel] = [VehicleMapModel]()
    private var vehicles: Vehicles? {
        didSet{
            reloadVehicleData()
        }
    }
    private var alertMessage: String? {
        didSet{
            for (id, observation) in observations {
                guard let observer = observation.observer else {
                    observations.removeValue(forKey: id)
                    continue
                }
                observer.displayWarning(message: alertMessage!)
            }
        }
    }
    var selectedVehicle: Vehicle? {
        didSet {
            for (id, observation) in observations {
                guard let observer = observation.observer else {
                    observations.removeValue(forKey: id)
                    continue
                }
                if (selectedVehicle == nil) {
                    observer.hideBookingTab()
                } else {
                    observer.displayBookingTab(forVehicle: selectedVehicle!)
                }
            }
        }
    }
    var vehicleType: VehicleType = .All {
        didSet {
            if (vehicles != nil) {
                vehicleMapModels.removeAll()
                vehicleCellModels.removeAll()
                createVehicleModels(vehicles!.vehicles)
                reloadVehicleData()
            }
        }
    }
    @objc var canSelectVehicle: Bool = false
    
    init(_ vehicleService: VehicleServiceProtocol = VehicleService()) {
        self.vehicleService = vehicleService
    }
    
    func fetchVehicles() {
        vehicleService.getVehicles{ [weak self] (result) in
            self?.handleVehicleResponse(result)
        }
    }
    
    func fetchVehicles(_ neCoordinate: CLLocationCoordinate2D, swCoordinate: CLLocationCoordinate2D) {
        vehicleService.getVehicles(neCoordinate: neCoordinate, swCoordinate: swCoordinate) { [weak self] (result) in
            self?.handleVehicleResponse(result)
        }
    }
    
    func handleVehicleResponse(_ result: Result) {
        vehicleCellModels.removeAll()
        vehicleMapModels.removeAll()
        switch result {
        case .success(let vehiclesResult):
            createVehicleModels(vehiclesResult.vehicles)
            vehicles = vehiclesResult
            canSelectVehicle = true
            break
            
        case .failure(let message):
            vehicles = nil
            alertMessage = message
            canSelectVehicle = false
            break
        }
    }
    
    func createVehicleModels(_ vehicleList: [Vehicle]) {
        for vehicle in vehicleList {
            switch vehicleType {
            case .Pool:
                if (vehicle.carType == "POOLING") {
                    createPoolVehicleModels(vehicle)
                }
                
            case .Taxi:
                if (vehicle.carType == "TAXI") {
                    createTaxiVehicleModels(vehicle)
                }
                
            default:
                if (vehicle.carType == "POOLING") {
                    createPoolVehicleModels(vehicle)
                    break
                }
                
                if (vehicle.carType == "TAXI") {
                    createTaxiVehicleModels(vehicle)
                }
            }
        }
    }
    
    func createPoolVehicleModels(_ vehicle: Vehicle) {
        let poolImage = UIImage.init(named: "Pool")!
        createVehicleCellModel(vehicle: vehicle, description: "Eco friendly rides", image: poolImage)
        createVehicleMapModel(vehicle: vehicle, annotationImage: UIImage.init(named: "PoolPin")!, image: poolImage)
    }
    
    func createTaxiVehicleModels(_ vehicle: Vehicle) {
        let taxiImage = UIImage.init(named: "Taxi")!
        createVehicleCellModel(vehicle: vehicle, description: "Get your own cab", image: taxiImage)
        createVehicleMapModel(vehicle: vehicle, annotationImage: UIImage.init(named: "TaxiPin")!, image: taxiImage)
    }
    
    func createVehicleCellModel(vehicle: Vehicle, description: String, image: UIImage) {
        let vehicleCellModel: VehicleCellModel = VehicleCellModel.init(id: vehicle.id,
                                                                       title: vehicle.carType,
                                                                       description: description,
                                                                       image: image)
        vehicleCellModels.append(vehicleCellModel)
    }
    
    func createVehicleMapModel(vehicle: Vehicle, annotationImage: UIImage, image: UIImage) {
        let vehicleMapModel: VehicleMapModel = VehicleMapModel.init(id: vehicle.id,
                                                                    title: vehicle.carType,
                                                                    coordinate: CLLocationCoordinate2D.init(latitude: vehicle.coordinate.latitude,
                                                                                                            longitude: vehicle.coordinate.longitude),
                                                                    heading: vehicle.movingTowards,
                                                                    annotationImage: annotationImage,
                                                                    vehicleImage: image)
        vehicleMapModels.append(vehicleMapModel)
    }
    
    func reloadVehicleData() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.reloadVehicleData()
        }
    }
    
    @objc func getNumberOfVehicles() -> Int {
        switch vehicleType {
        case .All:
            return vehicles?.vehicles.count ?? 0
            
        default:
            return vehicleCellModels.count
        }
    }
    
    @objc func getVehicleCellModel(at indexPath: IndexPath ) -> VehicleCellModel {
        return vehicleCellModels[indexPath.row]
    }
    
    func getVehicleMapModel(at index: Int ) -> VehicleMapModel {
        return vehicleMapModels[index]
    }
    
    @objc func selectVehicle(withId vehicleId: Int64) {
        for vehicle in vehicles!.vehicles {
            if (vehicle.id == vehicleId) {
                selectedVehicle = vehicle
                return
            }
        }
        if (selectedVehicle != nil) {
            selectedVehicle = nil
        }
    }
}

private extension VehicleViewModel {
    struct Observation {
        weak var observer: VehicleViewModelObserver?
    }
}

extension VehicleViewModel {
    func addObserver(_ observer: VehicleViewModelObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }
    
    func removeObserver(_ observer: VehicleViewModelObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

@objc class VehicleCellModel: NSObject {
    @objc let vehicleId: Int64
    @objc let titleText: String
    @objc let descText: String
    @objc let vehicleImage: UIImage
    
    convenience override init() {
        self.init()
    }
    
    init( id: Int64, title: String, description: String, image: UIImage) {
        vehicleId = id
        titleText = title
        descText = description
        vehicleImage = image
        super.init()
    }
}

struct VehicleMapModel {
    let id: Int64
    let title: String
    let coordinate: CLLocationCoordinate2D
    let heading: Double
    let annotationImage: UIImage
    let vehicleImage: UIImage
}


