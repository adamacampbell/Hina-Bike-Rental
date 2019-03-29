//
//  Racks.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 17/03/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit

class Racks: NSObject
{
    static var list = [Rack]()
    
    /// Returns the ID of a given rack name.
    ///
    /// - Parameter name: The name of the rack.
    /// - Returns: The ID of the rack.
    static func getRackID(name: String) -> String
    {
        for rack in Racks.list
        {
            if rack.name == name
            {
                return rack.id
            }
        }
        return "-1"
    }
    
    
    /// Checks if a given piece of gear is in a given rack.
    ///
    /// - Parameters:
    ///   - rackName: The name of the rack being searched.
    ///   - gearName: The name of the gear being searched for.
    /// - Returns: True or False.
    static func checkForGear(rackName: String, gearName: String) -> Int
    {
        for rack in Racks.list
        {
            if rackName == rack.name
            {
                for gear in rack.gear
                {
                    if gearName == gear.type
                    {
                        return gear.id
                    }
                }
            }
        }
        return -1
    }
    
    /// Removes all racks from list.
    static func clearList()
    {
        list.removeAll()
    }
}
