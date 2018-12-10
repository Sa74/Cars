//
//  Vehicle.swift
//  Cars
//
//  Created by Sasi M on 25/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

import Foundation

public struct Vehicles: Codable, Equatable {
    var vehicles: [Vehicle]
    
    enum CodingKeys: String, CodingKey {
        case vehicles = "carsList"
    }
    
    public static func == (lhs: Vehicles, rhs: Vehicles) -> Bool {
        return lhs.vehicles == rhs.vehicles
    }
}

struct Vehicle: Codable, Equatable {
    let id: Int64
    let carType: String
    let coordinate: Coordinate
    let movingTowards: Double
    
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}

