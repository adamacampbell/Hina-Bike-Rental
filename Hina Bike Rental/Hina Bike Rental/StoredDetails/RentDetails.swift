//
//  RentalDetails.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 16/03/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit
import CoreData

/// Class for storing rental detials globally and in device storage.
class RentDetails: NSObject
{
    struct details
    {
        static var bikeID: Int = -1
        static var bikeType: String = "-1"
        static var costPM: Decimal = -1
        static var totalCost: Decimal = -1
    }
    
    /// Function for reseting rental detials.
    static func wipeDetails()
    {
        details.bikeID = -1
        details.bikeType = "-1"
        details.costPM = -1
        details.totalCost = -1
        storeData()
    }
    
    /// Function for storing details to device storage.
    static func storeData()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newRental = NSEntityDescription.insertNewObject(forEntityName: "RentalDetails", into: context)
        newRental.setValue(details.bikeID, forKey: "bikeID")
        newRental.setValue(details.bikeType, forKey: "bikeType")
        newRental.setValue(details.costPM, forKey: "costPM")
        newRental.setValue(details.totalCost, forKey: "totalCost")
        do
        {
            try context.save()
        }
        catch
        {
            fatalError("Error, couldn't save to local storage")
        }
    }
    
    /// Function for updating the current cost by adding the cost per minute.
    static func updatePrice()
    {
        details.totalCost += details.costPM
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPrice = NSEntityDescription.insertNewObject(forEntityName: "RentalDetails", into: context)
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
    
    /// Used to load rental details from user's device storage.
    static func loadDetails()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RentalDetails")
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
                                    details.bikeID = bikeID
                                    details.bikeType = bikeType
                                    details.costPM = costPM
                                    details.totalCost = totalCost
                                }
                            }
                        }
                    }
                }
            }
        }
        catch
        {
            print("Error loading Rent Details.")
        }
    }
}
