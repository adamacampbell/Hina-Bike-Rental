//
//  AccountDetails.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 12/03/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit
import CoreData

class AccountDetails: NSObject
{
    struct userDetails
    {
        static var username: String = "-1"
        static var password: String = "-1"
        static var token: String = "-1"
        static var resID: Int = -1
    }
    
    /// Used to reset Account Details.
    static func wipeDetails()
    {
        userDetails.username = "-1"
        userDetails.password = "-1"
        userDetails.token = "-1"
        userDetails.resID = -1
        storeDetails()
    }
    
    /// Used to store account details locally on user's device.
    static func storeDetails()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newLogin = NSEntityDescription.insertNewObject(forEntityName: "LoginDetails", into: context)
        newLogin.setValue(userDetails.username, forKey: "username")
        newLogin.setValue(userDetails.password, forKey: "password")
        newLogin.setValue(userDetails.token, forKey: "token")
        newLogin.setValue(userDetails.resID, forKey: "resvid")
        do
        {
            try context.save()
        }
        catch
        {
            fatalError("Error: Couldn't save Account Details.")
        }
    }
    
    /// Used to load account details from user's device storage.
    static func loadDetails()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LoginDetails")
        request.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let username = result.value(forKey: "username") as? String
                    {
                        if let password = result.value(forKey: "password") as? String
                        {
                            if let token = result.value(forKey: "token") as? String
                            {
                                userDetails.username = username
                                userDetails.password = password
                                userDetails.token = token
                            }
                        }
                    }
                }
            }
        }
        catch
        {
            print("Error loading Account Details.")
        }
    }
}
