//
//  ReservationsViewController.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 01/02/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit

class ReservationsViewController: UIViewController {
    
    
    @IBOutlet weak var timeTextField: UILabel!
    @IBOutlet weak var locationTextField: UILabel!
    @IBOutlet weak var bikeTypeTextField: UILabel!
    @IBOutlet weak var costPerMinuteTextField: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        getReservation()
    }
    
    /// Checks server for any reservations made by user.
    func getReservation()
    {
        timeTextField.text = ReserveDetails.details.start
        locationTextField.text = ReserveDetails.details.location
        bikeTypeTextField.text = ReserveDetails.details.bikeType
        costPerMinuteTextField.text = "£\(NSDecimalNumber(decimal: ReserveDetails.details.costPM).stringValue)"
    }
    
    
    /// Allows user to cancel reservation.
    ///
    /// - Parameter sender: Any.
    @IBAction func cancelReservationTapped(_ sender: Any)
    {
        let alert = UIAlertController(title: "Confirm Cancellation", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler:
        { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.cancelReservation()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler:
        { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    
    
    /// Cancels the uers' reservation.
    func cancelReservation()
    {
        // Access web service url.
        let serviceURL = "https://hinabikeshare.ddns.net/app/cancelBooking?token=\(AccountDetails.userDetails.token)&resvid=\(ReserveDetails.details.resvid)"
        // Download JSON data.
        let url = URL(string: serviceURL)
        if let url = url
        {
            // Create a URL Session
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler:
            {
                (data, response, error) in
                if error == nil
                {
                    // Succeeded.
                    self.parseCancelReservation(data: data!)
                }
                else
                {
                    self.createAlert(title: "Error", message: "Couldn't connect to server.")
                }
            })
            task.resume()
        }
    }
    
    // Parse JSON object into user struct.
    func parseCancelReservation(data: Data)
    {
        do
        {
            let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            print(jsonDictionary)
            print("++++++++++++++++++++++++++ Cancel Booking +++++++++++++++++++++++++++++")
            let status = jsonDictionary["status"] as! Int
            if status == 1
            {
                DispatchQueue.main.async
                { [weak self] in
                    ReserveDetails.wipeDetails()
                    RentDetails.wipeDetails()
                    let alert = UIAlertController(title: "Reservation Cancelled", message: "Your reservation has been cancelled.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:
                    { (action) in
                        alert.dismiss(animated: true, completion: nil)
                        self?.performSegue(withIdentifier: "rentalsToMain", sender: self)
                    }))
                    self?.present(alert, animated: true)
                }
                return
            }
            else
            {
                let reason = jsonDictionary["reason"] as! String
                DispatchQueue.main.async
                { [weak self] in
                    self?.createAlert(title: "Couldn't Cancel", message: "Reason: \(reason)")
                }
            }
        }
        catch
        {
            print("Error: Error retrieving JSON Data.")
            DispatchQueue.main.async
                { [weak self] in
                    self?.createAlert(title: "Error", message: "Couldn't contact server.")
            }
        }
    }
    
    /// Creates an alert to be displayed on the screen.
    ///
    /// - Parameters:
    ///   - title: Title of the alert.
    ///   - message: Message of the alert.
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
