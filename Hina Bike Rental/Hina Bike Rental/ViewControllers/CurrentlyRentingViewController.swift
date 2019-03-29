//
//  CurrentlyRentingViewController.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 07/02/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CurrentlyRentingViewController: UIViewController, HomeModelDelegate
{
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var priceValueLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var toggleCurrentLocationButton: UIButton!
    
    var bikeID = -1
    var bikeType = ""
    var bikePrice: Decimal = -1.0
    var timer = Timer()
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 2000
    var previousLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    var trackLocation: Bool = true
    
    var homeModel = HomeModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        checkLocationServices()
        generateHubs()
        showAvailableBikes()
    }
    
    func initiateValues()
    {
        // Check if user has a reservation.
        if ReserveDetails.details.resvid != -1
        {
            AccountDetails.userDetails.resID = ReserveDetails.details.resvid
            RentDetails.details.bikeID = ReserveDetails.details.bikeID
            RentDetails.details.bikeType = ReserveDetails.details.bikeType
            RentDetails.details.costPM = ReserveDetails.details.costPM
            RentDetails.details.totalCost = 0
            // Add on price of any reserved gear.
            if ReserveDetails.details.gear != "-1"
            {
                let gearAmount:Decimal = (Decimal(ReserveDetails.details.gear.count) / 2.0) * 2.0
                RentDetails.details.totalCost = gearAmount
            }
        }
        bikeID = RentDetails.details.bikeID
        bikeType = RentDetails.details.bikeType
        bikePrice = RentDetails.details.costPM
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        initiateValues()
        print(AccountDetails.userDetails.token)
        print(bikeID)
        // Check if user has a Reservation.
        if ReserveDetails.details.resvid != -1
        {
            takeReservation()
        }
        else
        {
            // Access web service url.
            let serviceURL = "https://hinabikeshare.ddns.net/app/makeReservation?token=\(AccountDetails.userDetails.token)&bikeID=\(bikeID)&time=now"
            // Download JSON data.
            let url = URL(string: serviceURL)
            if let url = url
            {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url, completionHandler:
                {
                    (data, response, error) in
                    if error == nil
                    {
                        // Succeeded.
                        self.parseData(data: data!)
                    }
                    else
                    {
                        //error occ
                        let alert = UIAlertController(title: "Error", message: "Couldn't connect to server", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                            { (action) in
                                alert.dismiss(animated: true, completion: nil)
                                self.performSegue(withIdentifier: "fromCurrentlyRentingToMain", sender: self)
                        }))
                        self.present(alert, animated: true)
                    }
                })
                task.resume()
            }
        }
    }

    func takeReservation()
    {
        // Access web service url.
        let serviceURL = "http://3.94.4.167:8080/takeReservation?token=\(AccountDetails.userDetails.token)&resvid=\(ReserveDetails.details.resvid)"
        // Download JSON data.
        let url = URL(string: serviceURL)
        if let url = url
        {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler:
            {
                (data, response, error) in
                if error == nil
                {
                    // Succeeded.
                    self.parseTakeReservation(data: data!)
                }
                else
                {
                    //error occ
                    let alert = UIAlertController(title: "Error", message: "Couldn't connect to server", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                        { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "fromCurrentlyRentingToMain", sender: self)
                    }))
                    self.present(alert, animated: true)
                }
            })
            task.resume()
        }
        scheduleTimerWithInterval(interval: 60)
    }
    
    func parseTakeReservation(data: Data)
    {
        do
        {
            let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            print(jsonDictionary)
            print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            let status = jsonDictionary["status"] as! Int
            if status == 1
            {
                // Succeeded.
                DispatchQueue.main.async
                { [weak self] in
                        self?.scheduleTimerWithInterval(interval: 60)
                }
            }
            else
            {
                let reason = jsonDictionary["reason"] as! String
                DispatchQueue.main.async
                    { [weak self] in
                        let alert = UIAlertController(title: "Problem Occurred", message: "Reason: \(reason)", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                            { (action) in
                                alert.dismiss(animated: true, completion: nil)
                                self?.performSegue(withIdentifier: "fromCurrentlyRentingToMain", sender: self)
                        }))
                        self?.present(alert, animated: true)
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

    /*
     *parseData
     *parses the data recieved from database.
     *@param data - passes data from database.
     */
    func parseData(data: Data)
    {
        do
        {
            let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            print(jsonDictionary)
            print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            let status = jsonDictionary["status"] as! Int
            if status == 1
            {
                // Succeeded.
                DispatchQueue.main.async
                { [weak self] in
                    AccountDetails.userDetails.resID = jsonDictionary["resvid"] as! Int
                    AccountDetails.storeDetails()
                    self?.scheduleTimerWithInterval(interval: 60)
                }
            }
            else
            {
                DispatchQueue.main.async
                { [weak self] in
                    let alert = UIAlertController(title: "Error", message: "Couldn't make reservation.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:
                    { (action) in
                        alert.dismiss(animated: true, completion: nil)
                        self?.performSegue(withIdentifier: "fromCurrentlyRentingToMain", sender: self)
                    }))
                    self?.present(alert, animated: true)
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

    func setupLocationManager()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /*
     *checkLocationServices
     *used to check if user has enabled location services.
     */
    func checkLocationServices()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            checkLocationAuthorization()
            setupLocationManager()
        }
        else
        {
            createAlert(title: "Error", message: "Location Permissions required for use, please change permissions in app settings")
        }
    }
    
    /*
     *centerViewOnUserLocation
     *used to centre the map on the user's location.
     */
    func centerViewOnUserLocation()
    {
        if let location = locationManager.location?.coordinate
        {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            map.setRegion(region, animated: true)
        }
    }
    
    /*
     *startTrackingUserLocation
     *used to set the map to follow the user's location.
     */
    func startTrackingUserLocation()
    {
        map.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
    }
    
    /*
     *showClosestHub
     *used to display the closest bike or rack on the users map.
     *@param type - used to pass whether user requests bike or rack.
     */
    func showClosestHub()
    {
        guard let location = locationManager.location?.coordinate else
        {
            createAlert(title: "Error", message: "Location Permissions required for use, please change permissions in app settings")
            return
        }
        trackLocation = false
        updateLocationButton()
        do
        {
            let request = try createDirectionsRequest(from: location)
            
            let directions = MKDirections(request: request)
            resetMap(withNew: directions)
            
            directions.calculate { [unowned self] (response, error) in
                guard let response = response else { return }
                
                for route in response.routes
                {
                    self.map.addOverlay(route.polyline)
                    self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
        catch DirectionError.bikeNotFound
        {
            createAlert(title: "No Bikes Available", message: "Please try again later.")
        }
        catch DirectionError.rackNotFound
        {
            createAlert(title: "No Racks Available", message: "Please try again later.")
        }
        catch
        {
            createAlert(title: "Error", message: "Unknown error.")
        }
    }
    
    /*
     *createDirectionsRequest
     *used to create a request for directions from one point to another.
     *@param from - the start location.
     *@param type - either bike or hub.
     *returns an MKDirections request.
     */
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) throws -> MKDirections.Request
    {
        do
        {
            let closestHubCords: CLLocation = try findClosestHub(locations: hubs.locations)
            let currentLocation = MKPlacemark(coordinate: coordinate)
            let destination = MKPlacemark(coordinate: closestHubCords.coordinate)
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: currentLocation)
            request.destination = MKMapItem(placemark: destination)
            request.transportType = .walking
            request.requestsAlternateRoutes = false
            
            return request
        }
        catch DirectionError.rackNotFound
        {
            throw DirectionError.rackNotFound
        }
        catch DirectionError.bikeNotFound
        {
            throw DirectionError.bikeNotFound
        }
    }
    
    /*
     *findClosestHuborBike
     *used to find the closest hub or bike to the user's location.
     *@param locations - list of all current locations stored.
     *@param type - either bike or rack.
     *returns a CLLocation.
     */
    func findClosestHub(locations: [CLLocation]) throws -> CLLocation
    {
        let currentLocation = locationManager.location!
        if hubs.locations.count < 1
        {
            throw DirectionError.rackNotFound
        }
        var closestHub = hubs.locations[0]
        for i in 0...hubs.locations.count-1
        {
            if currentLocation.distance(from: hubs.locations[i]) < currentLocation.distance(from: closestHub)
            {
                closestHub = hubs.locations[i]
            }
        }
        return closestHub
    }
    
    /*
     *resetMap
     *used to remove any current overlays from the map and display a new one.
     *@param withNew - new directions to be displayed.
     */
    func resetMap(withNew directions: MKDirections)
    {
        map.removeOverlays(map.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    
    /*
     *checkLocationAuthorization
     *check the user's current location permissions.
     */
    func checkLocationAuthorization()
    {
        switch CLLocationManager.authorizationStatus()
        {
        case .authorizedWhenInUse:
            //Goal path.
            startTrackingUserLocation()
        case .denied:
            //Alert user that location permission is required.
            createAlert(title: "Error", message: "Location Permissions required for use, please change permissions in app settings")
            break
        case .notDetermined:
            //Ask user for permission to use their location when app is open.
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //Alert user that location permission is required.
            createAlert(title: "Error", message: "Location Permissions required for use, please change permissions in app settings")
            break
        case .authorizedAlways:
            break
        }
    }
    
    // A structure to store all of the hubs and their locations.
    struct hubs
    {
        static var racks = [Rack]()
        static var locations = [CLLocation]()
    }
    
    enum DirectionError: Error {
        case bikeNotFound
        case rackNotFound
    }
    
    /*
     * For hard coding hubs onto map.
     */
    func generateHubs() {
        
    }
    
    /*
     *addAnnotations
     *annotates a desired location onto the map and titles it.
     *@param locationName - The desired title for the annotation.
     *@param lat - The desired latitude for the annotation.
     *@param long - The desired longitude for the annotation.
     *@param type = the desired type of the annotation (bike or hub)
     *returns a CLLocation of the Annotation.
     */
    func addAnnotations(locationName: String, lat: Double, long: Double, type: String) -> CLLocation
    {
        let location = CLLocation.init(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = locationName
        annotation.subtitle = type
        map.addAnnotation(annotation)
        return location
    }
    
    /*
     *showAvailableBikes
     *pulls all available bikes from the database.
     */
    func showAvailableBikes()
    {
        homeModel.getBikes(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, radius: 2000)
        homeModel.delegate = self
    }
    
    /*
     *currentLocationButton
     *button for user to toggle whether or not to track their location.
     */
    @IBAction func currentLocationButton(_ sender: Any)
    {
        trackLocation = !trackLocation
        updateLocationButton()
    }
    
    /*
     *updateLocationButton
     *check whether or not the user's location should be tracked.
     */
    func updateLocationButton()
    {
        if trackLocation == true
        {
            toggleCurrentLocationButton.setImage(UIImage(named: "trackLocationOn.png"), for: .normal)
            locationManager.startUpdatingLocation()
        }
        else if trackLocation == false
        {
            toggleCurrentLocationButton.setImage(UIImage(named: "trackLocationOff.png"), for: .normal)
            locationManager.stopUpdatingLocation()
        }
    }
    /*
     *showClosestHub
     *allows user to find the closest hub.
     */    
    @IBAction func showClosestHub(_ sender: Any)
    {
        showClosestHub()
    }
    
    func racksDownloaded(racks: [Rack])
    {
        for rack in racks
        {
            let newRack = Rack(name: rack.name, id: rack.id, latitude: rack.latitude, longitude: rack.longitude, bikes: rack.bikes, capacity: rack.capacity, gear: rack.gear)
            hubs.racks.append(newRack)
            hubs.locations.append(addAnnotations(locationName: "\(rack.name)", lat: rack.latitude, long: rack.longitude, type: "rack"))
        }
    }
    
    func bikesDownloaded(bikes: [Bike]) {
        // Leave empty for now.
    }
    
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     *scheduleTimerWithInterval
     *creates a timer which executes code every x seconds.
     *@param interval - sets the interval at which the code should tun.
     */
    func scheduleTimerWithInterval(interval: Double)
    {
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.renting), userInfo: nil, repeats: true)
    }
    
    /*
     *renting
     *updates all of the details for the rental.
     */
    @objc func renting()
    {
        RentDetails.updatePrice()
        priceValueLabel.text = "£\(RentDetails.details.totalCost)"
    }
    
    /*
     *finishRentalTapped
     *allows the user to finish the rental.
     */
    @IBAction func finishRentalTapped(_ sender: Any)
    {
        let rackID = checkIfUserAtRack()
        if rackID == "-1"
        {
            let alert = UIAlertController(title: "Finish Rental", message: "Are you sure you would like to finish?\nTotal Cost: £\(RentDetails.details.totalCost)\n\nTo receive a 20% discount, return the bike to the closest rack.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in return }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in self.finishRental(rack: "-1", pos: "-1") }))
            present(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Finish Rental", message: "Thank you for dropping of at a rack, please enter the rack position (located at the base of the rack).\nTotal Cost: £\(RentDetails.details.totalCost * 0.8)", preferredStyle: UIAlertController.Style.alert)
            alert.addTextField{ (textField) in textField.placeholder = "Enter Rack Number" }
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                let textField = alert.textFields![0]
                let rackPos = textField.text!
                self.finishRental(rack: rackID, pos: rackPos)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in return }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    /*
     *finishRental
     *ends the users current rental.
     */
    func finishRental(rack: String, pos: String)
    {
        timer.invalidate()
        let dropOffLocation = locationManager.location!
        var serviceURL: String = ""
        if checkIfUserAtRack() == "-1"
        {
            // Access web service url.
            serviceURL = "https://hinabikeshare.ddns.net/app/dropOffBike?resvid=\(AccountDetails.userDetails.resID)&token=\(AccountDetails.userDetails.token)&posx=\(dropOffLocation.coordinate.latitude)&posy=\(dropOffLocation.coordinate.longitude)"
        }
        else
        {
            serviceURL = "https://hinabikeshare.ddns.net/app/dropOffBike?resvid=\(AccountDetails.userDetails.resID)&token=\(AccountDetails.userDetails.token)&rackid=\(rack)&rackpos=\(pos)"
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
                    self.parseDataTwo(data: data!)
                }
                else
                {
                    // Error ocurred.
                }
            })
            task.resume()
        }
    }
    
    func checkIfUserAtRack() -> String
    {
        let currentLocation = locationManager.location!
        for i in 0...hubs.locations.count-1
        {
            if currentLocation.distance(from: hubs.locations[i]) < 50
            {
                return hubs.racks[i].id
            }
        }
        return "-1"
    }
    
    func parseDataTwo(data: Data)
    {
        do
        {
            let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            print(jsonDictionary)
            print("+++++++++++++++++++++++++++++++++++++++++++++++++++")
            let status = jsonDictionary["status"] as! Int
            if status == 1
            {
                DispatchQueue.main.async
                { [weak self] in
                    AccountDetails.userDetails.resID = -1
                    AccountDetails.storeDetails()
                    RentDetails.wipeDetails()
                    ReserveDetails.wipeDetails()
                    let alert = UIAlertController(title: "How was your ride?", message: "Did you encounter any problems?\n\n(Please leave the bike standing upright.)", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:
                    { (action) in
                        alert.dismiss(animated: true, completion: nil)
                        self?.timer.invalidate()
                        self?.performSegue(withIdentifier: "rentingToProblem", sender: self)
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:
                    { (action) in
                        alert.dismiss(animated: true, completion: nil)
                        self?.timer.invalidate()
                        self?.performSegue(withIdentifier: "fromCurrentlyRentingToMain", sender: self)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            else if status == 0
            {
                if let reason = jsonDictionary["reason"] as? String
                {
                    DispatchQueue.main.async
                        { [weak self] in
                            self?.createAlert(title: "Problem Coccured.", message: reason)
                    }
                }
            }
            else
            {
                DispatchQueue.main.async
                { [weak self] in
                    self?.createAlert(title: "Error", message: "Please try again.")
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
}

extension CurrentlyRentingViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        map.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        checkLocationAuthorization()
    }
}

extension CurrentlyRentingViewController: MKMapViewDelegate
{
    func mapView(_ map: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        let colour = UIColor(red:0.72, green:0.99, blue:0.65, alpha:1.0)
        renderer.strokeColor = colour
        
        return renderer
    }
}
