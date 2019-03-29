//
//  HomeModel.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 05/02/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit

protocol HomeModelDelegate
{
    func bikesDownloaded(bikes: [Bike])
    func racksDownloaded(racks: [Rack])
}

class HomeModel: NSObject
{
    var delegate:HomeModelDelegate?
    
    func getBikes(latitude: Double, longitude: Double, radius: Int)
    {
        // Access web service url.
        let serviceURL = "https://hinabikeshare.ddns.net/app/getAvailableBikes?posx=\(latitude)&posy=\(longitude)&radius=\(radius)&token=\(AccountDetails.userDetails.token)"
        // Download e JSON data.
        let url = URL(string: serviceURL)
        
        if let url = url
        {
            // Create a URL Session
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler:
            {
                (data, response, error ) in
                if error == nil
                {
                    // Succeeded.
                    self.parseData(data: data!)
                }
                else {
                    // Error occurred.
                    
                }
            })
            task.resume()
            
        }
        
        // Notify View controller and pass data back.
    }
    
    // Parse the JSON object into Bike structs.
    func parseData(data: Data)
    {
        var bikeArray = [Bike]()
        var rackArray = [Rack]()
        do
        {
            let jsonMainDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            print(jsonMainDictionary)
            print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            if let jsonBikeDictionaryArray = jsonMainDictionary["bikes"] as? NSArray
            {
                for bikeDictionary in jsonBikeDictionaryArray
                {
                    if let bike = bikeDictionary as? NSDictionary
                    {
                        let bikeID = bike["id"]
                        let bikeLat = bike["lat"]
                        let bikeLong = bike["long"]
                        let bikeType = bike["type"]
                        if bikeID == nil || bikeLat == nil || bikeLong == nil
                        {
                            print("Error: Couldn't gather bike data.")
                        }
                        else
                        {
                            let newBike = Bike(
                                id: bikeID as! Int,
                                latitude: bikeLat as! Double,
                                longitude: bikeLong as! Double,
                                type: bikeType as! String)
                            bikeArray.append(newBike)
                            print("bike added")
                            print(newBike)
                        }
                    }
                }
            }
            if let jsonRackDictionaryArray = jsonMainDictionary["racks"] as? NSArray
            {
                for rackDictionary in jsonRackDictionaryArray
                {
                    if let rack = rackDictionary as? NSDictionary
                    {
                        let rackIDInt = rack["id"] as! Int
                        let rackID = String(rackIDInt)
                        let name = rack["name"]
                        let latitude = rack["lat"]
                        let longitude = rack["long"]
                        var bikes = [Int]()
                        if let jsonBikeDictionaryArray = rack["bikes"] as? NSArray
                        {
                            for bikeDictionary in jsonBikeDictionaryArray
                            {
                                if let bike = bikeDictionary as? NSDictionary
                                {
                                    if let bikeID = bike["id"] as? Int
                                    {
                                        print("bike ID")
                                        bikes.append(bikeID)
                                    }
                                }
                            }
                        }
                        var gearList = [Gear]()
                        if let jsonGearArray = rack["gear"] as? NSArray
                        {
                            for gearDictionary in jsonGearArray
                            {
                                if let gear = gearDictionary as? NSDictionary
                                {
                                    if let gearID = gear["id"] as? Int
                                    {
                                        if let gearType = gear["type"] as? String
                                        {
                                            let newGear = Gear(id: gearID, type: gearType)
                                            gearList.append(newGear)
                                        }
                                    }
                                }
                            }
                        }
                        let capacity = 20
                        if rackID == nil || name == nil || latitude == nil || longitude == nil || capacity == nil
                        {
                            print("Error: Couldn't gather rack data.")
                        }
                        else
                        {
                            let newRack = Rack(
                                name: name as! String,
                                id: rackID,
                                latitude: latitude as! Double,
                                longitude: longitude as! Double,
                                bikes: bikes,
                                capacity: capacity,
                                gear: gearList)
                            rackArray.append(newRack)
                            print("rack added")
                            print(newRack)
                        }
                    }
                }
            }
            delegate?.bikesDownloaded(bikes: bikeArray)
            delegate?.racksDownloaded(racks: rackArray)
        }
        catch
        {
            print("Error: Error retrieving JSON Data.")
        }
    }
}
