//
//  ReservationDetails.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 20/03/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit
import CoreData

/// Class for storing rental detials globally and in device storage.
class ReserveDetails: NSObject
{
    struct details
    {
        static var bikeID: Int = -1
        static var bikeType: String = "-1"
        static var costPM: Decimal = -1
        static var totalCost: Decimal = -1
        static var gear: String = "-1"
        static var resvid: Int = -1
        static var location: String = "-1"
        static var start: String = "-1"
    }
    
    /// Function for reseting reservation detials.
    static func wipeDetails()
    {
        details.bikeID = -1
        details.bikeType = "-1"
        details.costPM = -1
        details.totalCost = -1
        details.gear = "-1"
        details.resvid = -1
        details.location = "-1"
        details.start = "-1"
        storeData()
    }
    
    /// Function for storing details to device storage.
    static func storeData()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newRental = NSEntityDescription.insertNewObject(forEntityName: "ReservationDetails", into: context)
        newRental.setValue(details.bikeID, forKey: "bikeID")
        newRental.setValue(details.bikeType, forKey: "bikeType")
        newRental.setValue(details.costPM, forKey: "costPM")
        newRental.setValue(details.totalCost, forKey: "totalCost")
        newRental.setValue(details.gear, forKey: "resGear")
        newRental.setValue(details.resvid, forKey: "resvid")
        newRental.setValue(details.location, forKey: "location")
        newRental.setValue(details.start, forKey: "start")
        do
        {
            try context.save()
        }
        catch
        {
            fatalError("Error, couldn't save to local storage")
        }
    }
    
    /// Used to load reservation details from user's device storage.
    static func loadDetails()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ReservationDetails")
        request.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let bikeID = result.value(forKey: "bikeID") as? Int
                    {
                        if let bikeType = result.value(forKey: "bikeType") as? String
                        {
                            if let costPM = result.value(forKey: "costPM") as? Decimal
                            {
                                if let totalCost = result.value(forKey: "totalCost") as? Decimal
                                {
                                    if let gear = result.value(forKey: "resGear") as? String
                                    {
                                        if let resvid = result.value(forKey: "resvid") as? Int
                                        {
                                            if let location = result.value(forKey: "location") as? String
                                            {
                                                if let start = result.value(forKey: "start") as? String
                                                {
                                                    details.bikeID = bikeID
                                                    details.bikeType = bikeType
                                                    details.costPM = costPM
                                                    details.totalCost = totalCost
                                                    details.gear = gear
                                                    details.resvid = resvid
                                                    details.location = location
                                                    details.start = start
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch
        {
            print("Error loading reservation details.")
        }
    }
    
    /// Function for updating the current cost by adding the cost per minute.
    static func updatePrice()
    {
        details.totalCost += details.costPM
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPrice = NSEntityDescription.insertNewObject(forEntityName: "ReservationDetails", into: context)
        newPrice.setValue(details.totalCost, forKey: "totalCost")
        do
        {
            try context.save()
        }
        catch
        {
            fatalError("Error, couldn't save to local storage")
        }
    }
}
