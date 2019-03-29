//
//  Rack.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 06/02/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import Foundation

struct Rack
{
    var name: String
    var id: String
    var latitude: Double
    var longitude: Double
    var bikes = [Int]()
    var capacity: Int
    var gear = [Gear]()
    
    mutating func addBike(bikeID: Int, type: String)
    {
        if bikes.count < capacity
        {
            self.bikes.append(bikeID)
        }
        else
        {
            print("Error: Bike rack full")
        }
    }
    
    /// Checks if a given bike ID is in the Rack.
    ///
    /// - Parameter bikeID: The Bike being searched for.
    /// - Returns: True or False.
    func checkForBike(bikeID: Int) -> Bool
    {
        for bike in self.bikes
        {
            if bikeID == bike
            {
                return true
            }
        }
        return false
    }
    
    /// Returns the list of bikes at the rack.
    ///
    /// - Returns: The list of current Bikes at Rack.
    func getBikes() -> [Int]
    {
        return self.bikes
    }
}
