//
//  RentViewController.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 01/02/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit
import AVFoundation

class RentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{
    @IBOutlet weak var mainLabel: UILabel!
    //For Selecting the mode.
    @IBOutlet weak var modeSelect: UISegmentedControl!
    //Outlets for rent now mode.
    @IBOutlet weak var rentNowModeView: UIView!
    @IBOutlet weak var cameraDisplayView: UIView!
    @IBOutlet weak var rentNowStackView: UIStackView!
    @IBOutlet weak var qrTargetBox: UIImageView!
    //Outlets for book for later mode.
    @IBOutlet weak var bookForLaterModeView: UIView!
    @IBOutlet weak var inputFieldStack: UIStackView!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var bikeTypeTextField: UITextField!
    @IBOutlet weak var pickupLocationTextField: UITextField!
    //Creating UI Pickers
    let startTimePicker = UIDatePicker()
    let bikeTypePicker = UIPickerView()
    let locationPicker = UIPickerView()
    // Creating Lists for Picker's Data.
    var locationPickerData = [String]()
    var bikeTypesData = [String]()
    //Buttons for additional gear.
    @IBOutlet weak var gearButton1: UIButton!
    @IBOutlet weak var gearButton2: UIButton!
    @IBOutlet weak var gearButton3: UIButton!
    //Variables for sttoring gear states.
    var gear1: Bool = false
    var gear2: Bool = false
    var gear3: Bool = false
    //Variable to store selected gear.
    //var gearArray = [0, 0, 0]
    //Int to store mode between rental or booking.
    var mode: Int = 0
    var video = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        checkMode()
        initialiseFields()
    }
    
    func initialiseFields()
    {
        locationPicker.delegate = self
        bikeTypePicker.delegate = self
        self.startTimePicker.datePickerMode = .time
        startTimeTextField.inputView = startTimePicker
        pickupLocationTextField.inputView = locationPicker
        bikeTypeTextField.inputView = bikeTypePicker
        makeToolbarButtons()
        getLocationPickerData()
    }
    
    /// Make tool bar buttons for picker views.
    func makeToolbarButtons()
    {
        // Create toolbar for start time picker.
        let startTimeToolBar = UIToolbar()
        startTimeToolBar.sizeToFit()
        // Add done button to start time toolbar.
        let startTimeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector  (startTimeDoneButtonTapped))
        startTimeToolBar.setItems([startTimeDoneButton], animated: true)
        startTimeTextField.inputAccessoryView = startTimeToolBar
        startTimePicker.minimumDate = Date().addingTimeInterval(30)
        startTimePicker.minuteInterval = 15
        // Create toolbar for pickup location picker.
        let pickUpLocationToolBar = UIToolbar()
        pickUpLocationToolBar.sizeToFit()
        // Add done button to pickup location toolbar.
        let pickUpLocationDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (pickUpLocationDoneButtonTapped))
        pickUpLocationToolBar.setItems([pickUpLocationDoneButton], animated: true)
        pickupLocationTextField.inputAccessoryView = pickUpLocationToolBar
        // Create toolbar for bike type picker.
        let bikeTypeToolBar = UIToolbar()
        bikeTypeToolBar.sizeToFit()
        // Add done button to bike type toolbar.
        let bikeTypeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (bikeTypeDoneButtonTapped))
        bikeTypeToolBar.setItems([bikeTypeDoneButton], animated: true)
        bikeTypeTextField.inputAccessoryView = bikeTypeToolBar
    }
    
    func getLocationPickerData()
    {
        for rack in Racks.list
        {
            locationPickerData.append(rack.name)
        }
    }
    
    /// Struct to hold bike details within class scope.
    struct bikeDetails
    {
        static var id = "-1"
        static var type = "-1"
        static var price: Decimal = -1
    }
    
    //Allow user to switch between renting now or booking for later.
    @IBAction func modeSelectChanged(_ sender: Any)
    {
        mode = modeSelect.selectedSegmentIndex
        checkMode()
    }
    
    /// Allows user to select gear 1
    ///
    /// - Parameter sender: any
    @IBAction func gearButton1Pressed(_ sender: Any)
    {
        if pickupLocationTextField.text == ""
        {
            createAlert(title: "Select Location First", message: "Please pick a pickup location first.")
        }
        else
        {
            let gearID = Racks.checkForGear(rackName: pickupLocationTextField.text!, gearName: "Helmet")
            if gearID != -1
            {
                gearSelected(gear: 1, gearID: gearID)
            }
            else
            {
                createAlert(title: "Gear Not Available", message: "The rack at \(pickupLocationTextField.text!) doesn't have any Helmets.")
            }
        }
    }
    
    /// Allows user to select gear 2
    ///
    /// - Parameter sender: any
    @IBAction func gearButton2Pressed(_ sender: Any)
    {
        if pickupLocationTextField.text == ""
        {
            createAlert(title: "Select Location First", message: "Please pick a pickup location first.")
        }
        else
        {
            let gearID = Racks.checkForGear(rackName: pickupLocationTextField.text!, gearName: "Air pump")
            if gearID != -1
            {
                gearSelected(gear: 2, gearID: gearID)
            }
            else
            {
                createAlert(title: "Gear Not Available", message: "The rack at \(pickupLocationTextField.text!) doesn't have any Air Pumps.")
            }
        }
    }
    
    /// Allows user to select gear 3
    ///
    /// - Parameter sender: any
    @IBAction func gearButton3Pressed(_ sender: Any)
    {
        if pickupLocationTextField.text == ""
        {
            createAlert(title: "Select Location First", message: "Please pick a pickup location first.")
        }
        else
        {
            let gearID = Racks.checkForGear(rackName: pickupLocationTextField.text!, gearName: "Repair kit")
            if gearID != -1
            {
                gearSelected(gear: 3, gearID: gearID)
            }
            else
            {
                createAlert(title: "Gear Not Available", message: "The rack at \(pickupLocationTextField.text!) doesn't have any Repair Kits.")
            }
        }
    }
    
    /// Check what gear button was pressed and change value accordingly.
    ///
    /// - Parameter gear: The gear being selected.
    func gearSelected(gear: Int, gearID: Int)
    {
        switch gear
        {
        case 1:
            gear1 = !gear1
            if gear1 == false
            {
                gearButton1.setImage(UIImage(named: "tickBoxEmpty"), for: .normal)
                //gearArray[0] = 1
            }
            else
            {
                gearButton1.setImage(UIImage(named: "tickBoxFilled"), for: .normal)
                //gearArray[0] = 0
            }
            break
            
        case 2:
            gear2 = !gear2
            if gear2 == false
            {
                gearButton2.setImage(UIImage(named: "tickBoxEmpty"), for: .normal)
                //gearArray[1] = 1
            }
            else
            {
                gearButton2.setImage(UIImage(named: "tickBoxFilled"), for: .normal)
                //gearArray[1] = 0
            }
            break
        
        case 3:
            gear3 = !gear3
            if gear3 == false
            {
                gearButton3.setImage(UIImage(named: "tickBoxEmpty"), for: .normal)
                //gearArray[2] = 1
            }
            else
            {
                gearButton3.setImage(UIImage(named: "tickBoxFilled"), for: .normal)
                //gearArray[2] = 0
            }
            break
            
        default:
            break
        }
    }
    
    /// Clears all other fields when user changes pickup location.
    ///
    /// - Parameter sender: Any
    @IBAction func pickUpLocationTapped(_ sender: Any)
    {
        startTimeTextField.text = ""
        bikeTypeTextField.text = ""
        bikeTypesData.removeAll()
        gear1 = false
        gearButton1.setImage(UIImage(named: "tickBoxEmpty"), for: .normal)
        gear2 = false
        gearButton2.setImage(UIImage(named: "tickBoxEmpty"), for: .normal)
        gear3 = false
        gearButton3.setImage(UIImage(named: "tickBoxEmpty"), for: .normal)
    }
    
    /// Checks that the user has first entered the pickup location
    ///
    /// - Parameter sender: Any
    @IBAction func bikeTypeTapped(_ sender: Any)
    {
        if pickupLocationTextField.text == ""
        {
            createAlert(title: "Select Location First", message: "Please pick a pickup location first.")
        }
        else
        {
            retrieveBikesFromLocation()
            //Wait on bikes being retrieved.
            sleep(1)
            if bikeTypesData.count < 1
            {
                createAlert(title: "Bike Not Available", message: "Rack at \(pickupLocationTextField.text!) doesn't have any available Bikes.")
            }
        }
    }
    
    /// Retrieves the bikes for a given rack.
    func retrieveBikesFromLocation()
    {
        let rackID = Racks.getRackID(name: pickupLocationTextField.text!)
        // Access web service url.
        let serviceURL = "https://hinabikeshare.ddns.net/app/getBikesInRack?rackid=\(rackID)&token=\(AccountDetails.userDetails.token)"
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
                    self.retrieveBikesFromLocationParse(data: data!)
                }
                else
                {
                    // Error ocurred.
                    let alert = UIAlertController(title: "Error", message: "Couldn't retrieve bikes.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "rentingToMain", sender: self)
                    }))
                    self.present(alert, animated: true)
                }
            })
            task.resume()
        }
    }
    
    /// Parses the data sent from retrieveBikesFromLocation.
    ///
    /// - Parameter data: the data being parsed.
    func retrieveBikesFromLocationParse(data: Data)
    {
        do
        {
            let jsonMainArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
            print("++++++++++++++++++++ Retrieve Bikes ++++++++++++++++++++")
            print(jsonMainArray)
            for gearDictionary in jsonMainArray
            {
                if let gear = gearDictionary as? NSDictionary
                {
                    let bikeType = gear["bike_type"] as! String
                    if !bikeTypesData.contains(bikeType)
                    {
                        bikeTypesData.append(bikeType)
                    }
                }
            }
        }
        catch
        {
            print("Error: Couldn't parse bike types at \(pickupLocationTextField.text!)")
            createAlert(title: "Error", message: "Couldn't parse bike types at \(pickupLocationTextField.text!)")
        }
    }
    
    //Checking if user would like to rent now or book for later.
    func checkMode()
    {
        switch mode
        {
        case 0:
            //Rent Now Mode
            showRentNowUI()
            rentNow()
        case 1:
            //Book for later mode
            showBookLaterUI()
        default:
            break
        }
    }
    
    /// Displays UI for renting on the spot.
    func showRentNowUI()
    {
        bookForLaterModeView.isHidden = true
        modeSelect.isHidden = false
        rentNowModeView.isHidden = false
        mainLabel.text = "Rent a Bike"
        self.view.endEditing(true)
    }
    
    /// Displays UI for booking for later.
    func showBookLaterUI()
    {
        rentNowModeView.isHidden = true
        modeSelect.isHidden = false
        bookForLaterModeView.isHidden = false
        mainLabel.text = "Rent a Bike"
    }
    
    //Set up for user booking now.
    func rentNow()
    {
        //Creating Session
        let session = AVCaptureSession()
        
        //Define capture device
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do
        {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        }
        catch
        {
            createAlert(title: "Error", message: "Unable to access camera")
            return
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        video = AVCaptureVideoPreviewLayer(session: session)
        video.videoGravity = AVLayerVideoGravity.resizeAspectFill
        video.frame = cameraDisplayView.bounds
        cameraDisplayView.layer.addSublayer(video)
        
        self.cameraDisplayView.bringSubviewToFront(qrTargetBox)
        
        session.startRunning()
    }
    //Checking if the camera has scanned a QR Code.
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        if metadataObjects != nil && metadataObjects.count != nil
        {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                if object.type == AVMetadataObject.ObjectType.qr
                {
                    bikeDetails.id = object.stringValue!
                    bikeDetails.type = findBikeType()
                    video.session?.stopRunning()
                    startRental()
                }
            }
        }
    }
    
    /// Called when user taps Enter Code Manually
    ///
    /// - Parameter sender: Any
    @IBAction func enterCodeManuallyButton(_ sender: Any)
    {
        let alert = UIAlertController(title: "Enter Bike's Code", message: "The Code should be located below the QR Code", preferredStyle: .alert)
        alert.addTextField{ (textField) in textField.placeholder = "Enter Code" }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            let texfField = alert.textFields![0]
            self.mode = 2
            DispatchQueue.main.async
            {
                alert.dismiss(animated: true, completion: nil)
                bikeDetails.id = texfField.text!
                //print("Bike ID Before: \(bikeDetails.id)")
                self.checkValidID()
                //print("Bike ID: \(bikeDetails.id)")
                /*
                if bikeDetails.id != "-1"
                {
                    self.startRental()
                }
                else
                {
                    self.createAlert(title: "Invalid ID", message: "The ID entered is invalid, please try again.")
                }
                */
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// Retrieves all valid bike ID's from server.
    func checkValidID()
    {
        // Access web service url.
        let serviceURL = "https://hinabikeshare.ddns.net/app/getBikeIDs?token=\(AccountDetails.userDetails.token)"
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
                    self.checkValidIDParse(data: data!)
                }
                else
                {
                    // Error ocurred.
                    let alert = UIAlertController(title: "Error", message: "Couldn't connect to server.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "rentingToMain", sender: self)
                    }))
                    self.present(alert, animated: true)
                }
            })
            task.resume()
        }
    }
    
    /// Parses data from checkValidID
    ///
    /// - Parameter data: The data from checkValidID
    func checkValidIDParse(data: Data)
    {
        do
        {
            let jsonMainArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
            print(jsonMainArray)
            print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            var valid = false
            for id in jsonMainArray
            {
                if let intID = id as? Int
                {
                    print("ID: \(intID) vs BikeID: \(bikeDetails.id)")
                    if bikeDetails.id == String(intID)
                    {
                        valid = true
                    }
                }
            }
            if valid == false
            {
                bikeDetails.id = "-1"
                DispatchQueue.main.async
                    { [weak self] in
                        self?.createAlert(title: "Invalid ID", message: "Please enter a valid ID.")
                }
            }
            else
            {
                startRental()
            }
        }
        catch
        {
            print("Error: Error retrieving Price.")
            DispatchQueue.main.async
            { [weak self] in
                let alert = UIAlertController(title: "Error", message: "Couldn't retrieve ID.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    self?.performSegue(withIdentifier: "rentingToMain", sender: self)
                }))
                self?.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func bookButtonPressed(_ sender: Any)
    {
        checkForEmptyFields()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CurrentlyRentingViewController
        {
            RentDetails.details.bikeID = Int(bikeDetails.id)!
            RentDetails.details.bikeType = bikeDetails.type
            RentDetails.details.costPM = bikeDetails.price
            RentDetails.details.totalCost = 0
            RentDetails.storeData()
        }
    }
    
    /// Finds the type of a given bike
    ///
    /// - Returns: returns the bikes type
    func findBikeType() -> String
    {
        print("Finding Bike Type")
        for bike in ViewController.bikeList.bikes
        {
            let bikeID = String(bike.id)
            if bikeID == bikeDetails.id
            {
                return bike.type as String
            }
        }
        return "-1"
    }
    
    /// Asks the user if the would like to confirm the rental, if so then starts it.
    func startRental()
    {
        bikeDetails.type = findBikeType()
        findBikePrice(type: bikeDetails.type)
        //bikeDetails.price = 0.1
        //Bike cost must be retrieved before rental is validated.
        while bikeDetails.price == -1
        {
            print("Waiting for price.")
            sleep(1)
        }
        validateRental()
    }
    
    /// Finds the current price per minute of a given type of bike.
    ///
    /// - Parameter type: The type of bike being searched for.
    /// - Returns: The price of the given type of bike in Decimal form.
    func findBikePrice(type: String)
    {
        print("Finding Bike Price")
        // Access web service url.
        let serviceURL = "https://hinabikeshare.ddns.net/app/getCostPM?biketype=\(type)"
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
                    self.getBikeCost(data: data!)
                }
                else
                {
                    // Error ocurred.
                    let alert = UIAlertController(title: "Error", message: "Couldn't connect to server.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                            { (action) in
                                alert.dismiss(animated: true, completion: nil)
                                self.performSegue(withIdentifier: "rentingToMain", sender: self)
                        }))
                        self.present(alert, animated: true)
                }
            })
            task.resume()
        }
    }
    
    /// Parses a url data and sets the bike's price.
    ///
    /// - Parameter data: the url data being parsed.
    func getBikeCost(data: Data)
    {
        print("Get Bike Cost")
        do
        {
            let jsonMainDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            print(jsonMainDictionary)
            print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            if let price = jsonMainDictionary["price"] as? Double
            {
                if mode == 1
                {
                    ReserveDetails.details.costPM = Decimal(price)
                }
                else
                {
                    bikeDetails.price = Decimal(price)
                }
            }
        }
        catch
        {
            print("Error: Error retrieving Price.")
            DispatchQueue.main.async
                { [weak self] in
                    let alert = UIAlertController(title: "Error", message: "Couldn't retrieve price.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self?.performSegue(withIdentifier: "rentingToMain", sender: self)
                    }))
                    self?.present(alert, animated: true)
            }
        }
    }
    
    func validateRental()
    {
        print("Validating Rental")
        if bikeDetails.price != -1
        {
            let alert = UIAlertController(title: "Rent Bike", message: "Would you like to rent this bike?\nBike Type: \(bikeDetails.type)\nPrice per Minute: £\(bikeDetails.price)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                self.video.session?.startRunning()
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (nil) in
                self.mode = 2
                self.performSegue(withIdentifier: "showCurrentlyRentingView", sender: self)
            }))
            present(alert, animated: true, completion: nil)
        }
        else
        {
            createAlert(title: "Couln't validate Rental", message: "Please try again.")
        }
    }
    
    // Move to next text field when user presses return.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag)
        {
            nextResponder.becomeFirstResponder()
        }
        else
        {
            self.view.endEditing(true)
            checkForEmptyFields()
        }
        return true
    }
    
    @objc func startTimeDoneButtonTapped()
    {
        // format date for textfield.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        startTimeTextField.text = dateFormatter.string(from: startTimePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func pickUpLocationDoneButtonTapped()
    {
        pickupLocationTextField.text = locationPickerData[locationPicker.selectedRow(inComponent: 0)]
        self.view.endEditing(true)
    }
 
    @objc func bikeTypeDoneButtonTapped()
    {
        bikeTypeTextField.text = bikeTypesData[bikeTypePicker.selectedRow(inComponent: 0)]
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView
        {
        case locationPicker:
            return locationPickerData.count
        
        case bikeTypePicker:
            return bikeTypesData.count
            
        default:
            return 0
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView
        {
        case locationPicker:
            return locationPickerData[row]
        
        case bikeTypePicker:
            return bikeTypesData[row]
            
        default:
            return nil
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView
        {
        case locationPicker:
            pickupLocationTextField.text = locationPickerData[row]
            
        case bikeTypePicker:
            bikeTypeTextField.text = bikeTypesData[row]
            
        default:
            break
        }
    }
    
    /// Checks if user has missed out any entry fields
    func checkForEmptyFields()
    {
        if startTimeTextField.text == ""
        || pickupLocationTextField.text == ""
        || bikeTypeTextField.text == ""
        {
            createAlert(title: "Missing Information", message: "Please fill in all details.")
        }
        else
        {
            let gear = gatherGearDetails()
            bookForLater(start: startTimeTextField.text!, pickUp: pickupLocationTextField.text!, gear: gear)
        }
    }
    
    /// Checks if the user has selected any gear.
    func gatherGearDetails() -> String
    {
        var gear = ""
        if gear1 == true
        {
            gear += "1,"
        }
        if gear2 == true
        {
            gear += "2,"
        }
        if gear3 == true
        {
            gear += "3,"
        }
        return gear
    }
    
    /// Books a rental for later.
    func bookForLater(start: String, pickUp: String, gear: String)
    {
        getAvailableBikeID()
        // get available ID first.
        while ReserveDetails.details.bikeID == -1
        {
            print("Waiting for ID...")
            sleep(1)
        }
        print("Bike ID: \(ReserveDetails.details.bikeID)")
        findBikePrice(type: bikeTypeTextField.text!)
        // Wait until bike price has been retrieved.
        while ReserveDetails.details.costPM == -1
        {
            print("Waiting for Price...")
            sleep(1)
        }
        print("Cost: \(ReserveDetails.details.costPM)")
        let alert = UIAlertController(title: "Confirm Reservation", message: "\nLocation: \(pickUp)\nTime: \(start)\nBike Type: \(bikeTypeTextField.text!)\nCost Per Minute: £\(ReserveDetails.details.costPM)\n\nPlease note that reserved gear, such as helmets, are charged at a base fee of £2.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler:
        { (acion) in
            alert.dismiss(animated: true, completion: nil)
            self.makeBooking(start: start, pickUp: pickUp, gear: gear)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:
        { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    
    /// Gets an available bike's ID.
    func getAvailableBikeID()
    {
        // Get rack ID.
        let rackID = Racks.getRackID(name: pickupLocationTextField.text!)
        // Access web service url.
        let serviceURL = "https://hinabikeshare.ddns.net/app/getBikesInRack?rackid=\(rackID)&biketypes=\(bikeTypeTextField.text!)&token=\(AccountDetails.userDetails.token)"
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
                    self.getIDDetails(data: data!)
                }
                else
                {
                    // Error ocurred.
                    let alert = UIAlertController(title: "Error", message: "Couldn't load Booking reference.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "rentingToMain", sender: self)
                    }))
                    self.present(alert, animated: true)
                }
            })
            task.resume()
        }
    }
    
    /// Parses the url Data passed from getAvailableBikeID
    ///
    /// - Parameter data: The Data from getAvailableBikeID
    func getIDDetails(data: Data)
    {
        do
        {
            let jsonMainArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
            print("++++++++++++++++++++++++++++++++++ Bike ID +++++++++++++++++++++++++++++++++++++++")
            print(jsonMainArray)
            let jsonMainDictionary = jsonMainArray[0] as! NSDictionary
            let bikeID = jsonMainDictionary["bike_id"] as? Int
            ReserveDetails.details.bikeID = bikeID!
        }
        catch
        {
            print("Error: Error retrieving Price.")
            DispatchQueue.main.sync
                { [weak self] in
                    let alert = UIAlertController(title: "Error", message: "Couldn't retrieve Bike ID.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self?.performSegue(withIdentifier: "rentingToMain", sender: self)
                    }))
                    self?.present(alert, animated: true)
            }
        }
    }
    
    /// Makes a Booking for later.
    ///
    /// - Parameters:
    ///   - date: Date of Booking.
    ///   - start: Start time of Booking.
    ///   - end: End time of Booking.
    ///   - pickUp: Pickup location of Booking.
    func makeBooking(start: String, pickUp: String, gear: String)
    {
        print("Make Booking")
        // Access web service url.
        var serviceURL = "https://hinabikeshare.ddns.net/app/makeReservation?token=\(AccountDetails.userDetails.token)&bikeID=\(ReserveDetails.details.bikeID)&time=\(start)"
        if gear != ""
        {
            serviceURL += "&gear=\(gear)"
        }
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
                    self.getBookingDetails(data: data!, start: start, pickUp: pickUp)
                }
                else
                {
                    // Error ocurred.
                    let alert = UIAlertController(title: "Error", message: "Couldn't connect to booking server.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "rentingToMain", sender: self)
                    }))
                    self.present(alert, animated: true)
                }
            })
            task.resume()
        }
    }
    
    /// Parses the url Data from makeBooking.
    ///
    /// - Parameters:
    ///   - data: The Data being parsed.
    ///   - start: The start time of the booking.
    func getBookingDetails(data: Data, start: String, pickUp: String)
    {
        do
        {
            let jsonMainDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            print("+++++++++++++++++++++++++++++++++++ Booking Details ++++++++++++++++++++++++++++++++++++++")
            print(jsonMainDictionary)
            let status = jsonMainDictionary["status"] as? Int
            let resvid = jsonMainDictionary["resvid"] as? Int
            if status == 1
            {
                DispatchQueue.main.sync
                    { [weak self] in
                        let alert = UIAlertController(title: "Booking Made", message: "Your bike will be available at \(pickUp) for \(start)", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self?.storeReservationDetails(resvid: resvid!,pickUp: pickUp,start: start);
                            self?.performSegue(withIdentifier: "rentingToMain", sender: self)
                    }))
                    self?.present(alert, animated: true)
                }
            }
            else
            {
                let reason = jsonMainDictionary["reason"] as! String
                DispatchQueue.main.async
                    { [weak self] in
                        let alert = UIAlertController(title: "Problem Occured", message: "Reason: \(reason)\nBike ID: \(RentDetails.details.bikeID)", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self?.performSegue(withIdentifier: "rentingToMain", sender: self)
                        }))
                    self?.present(alert, animated: true)
                }
            }
        }
        catch
        {
            print("Error: Error retrieving Booking.")
            DispatchQueue.main.async
                { [weak self] in
                    let alert = UIAlertController(title: "Error", message: "Couldn't retrieve booking details.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self?.performSegue(withIdentifier: "rentingToMain", sender: self)
                    }))
                    self?.present(alert, animated: true)
            }
        }
    }
    
    /// Stores the booking details locally to user's device.
    ///
    /// - Parameters:
    ///   - resvid: The resevation ID.
    ///   - pickUp: The pickup lovation.
    ///   - start: The starting time.
    func storeReservationDetails(resvid: Int, pickUp: String, start: String)
    {
        RentDetails.wipeDetails()
        ReserveDetails.details.resvid = resvid
        ReserveDetails.details.bikeType = bikeTypeTextField.text!
        ReserveDetails.details.totalCost = 0
        ReserveDetails.details.location = pickUp
        ReserveDetails.details.start = start
        ReserveDetails.storeData()
    }
    
    /**
     *createAlert
     *Function for displaying an alert to the user (Only has OK button).
     *@param title - Used to set the title of the Alert.
     *@param message - Used to sett the message of the Alert.
    **/
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension RentViewController: AVCaptureMetadataOutputObjectsDelegate
{
    
}
