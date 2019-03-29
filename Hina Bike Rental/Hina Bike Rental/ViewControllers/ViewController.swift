//
//  ViewController.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 31/01/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, HomeModelDelegate
{
    // Map view.
    @IBOutlet weak var map: MKMapView!
    // Current location button.
    @IBOutlet weak var toggleCurrentLocationButton: UIButton!
    // All related to user's location.
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 2000
    var previousLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    var trackLocation: Bool = true
    // For downloading bike/rack location data.
    var homeModel = HomeModel()
    // For updataing bike/rack location data.
    var mapTimer = Timer()
    // Create blacked out background.
    let blackView = UIView()
    // Create menu.
    let menu = UITableView()
    /// Labels for settings menu.
    let menuArray = ["Manage Rentals", "Report a Problem", "Logout", "Cancel"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        checkLocationServices()
        generateHubs()
        showAvailableBikes()
        startMapTimer()
        menu.isScrollEnabled = false
        menu.delegate = self
        menu.dataSource = self
        menu.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        RentDetails.loadDetails()
        ReserveDetails.loadDetails()
        if checkIfAlreadyRenting()
        {
            self.performSegue(withIdentifier: "mainToCurrentlyRenting", sender: self)
        }
        if checkIfHasBooking()
        {
            createAlert(title: "Reservation Reminder", message: "You have a bike reserved at \(ReserveDetails.details.location) for \(ReserveDetails.details.start)\n\nWhen you are ready to start the reservation, tap 'Rent a Bike'")
        }
    }
    
    /// Checks if the user is already mid rental.
    ///
    /// - Returns: True or False
    func checkIfAlreadyRenting() -> Bool
    {
        if AccountDetails.userDetails.resID != -1
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    /// Checks if the user has a booking.
    ///
    /// - Returns: True or False.
    func checkIfHasBooking() -> Bool
    {
        if ReserveDetails.details.resvid != -1
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    /*
     *startMapTimer
     *Used to start a timer which will update the locations of
     *bikes/racks.
     */
    func startMapTimer()
    {
        mapTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(showAvailableBikes), userInfo: nil, repeats: true)
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
     *showClosestHubOrBike
     *used to display the closest bike or rack on the users map.
     *@param type - used to pass whether user requests bike or rack.
     */
    func showClosestHubOrBike(type: String)
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
            let request = try createDirectionsRequest(from: location, type: type)
            
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
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, type: String) throws -> MKDirections.Request
    {
        do
        {
            let closestHubCords: CLLocation = try findClosestHubOrBike(locations: hubs.locations, type: type)
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
    func findClosestHubOrBike(locations: [CLLocation], type: String) throws -> CLLocation
    {
        let currentLocation = locationManager.location!
        if type == "rack"
        {
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
        else
        {
            if bikeList.locations.count < 1
            {
                throw DirectionError.bikeNotFound
            }
            var closestBike = bikeList.locations[0]
            for i in 0...bikeList.locations.count-1
            {
                if currentLocation.distance(from: bikeList.locations[i]) < currentLocation.distance(from: closestBike)
                {
                    closestBike = bikeList.locations[i]
                }
            }
            return closestBike
        }
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
    
    // A structure to store all of the bikes and their locations.
    struct bikeList
    {
        static var bikes = [Bike]()
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
    
    func showRacks()
    {
        
    }
    /*
     *showAvailableBikes
     *pulls all available bikes from the database.
     */
    @objc func showAvailableBikes()
    {
        do
        {
            homeModel.getBikes(latitude: (locationManager.location?.coordinate.latitude ?? 0.0), longitude: (locationManager.location?.coordinate.longitude ?? 0.0), radius: 2000)
            homeModel.delegate = self
        }
        //catch
        //{
        //    print("Error: Couldn't Connect to Map Server.")
        //}
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
    
    /// Allows user to rent a bike.
    ///
    /// - Parameter sender: Any.
    @IBAction func rentBikeButton(_ sender: Any)
    {
        if checkIfHasBooking()
        {
            // Get date.
            let date = Date()
            // Create date formatter for 24 hour time.
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            // Get 24 hour time from date as string.
            let dateString = dateFormatter.string(from: date)
            // Get dates from 24 hour time strings
            let startTime = dateFormatter.date(from: ReserveDetails.details.start)!
            let currentTime = dateFormatter.date(from: dateString)!
            // Remove to test bookings without time constraint.
            // =========================================== //
            //if currentTime < startTime
            //{
            //    createAlert(title: "Too Early", message: "Your reservation is at \(ReserveDetails.details.start)")
            //}
            //else
            //{
            //    self.performSegue(withIdentifier: "mainToCurrentlyRenting", sender: self)
            //}
            // Add to test bookings without time constraint.
             self.performSegue(withIdentifier: "mainToCurrentlyRenting", sender: self)
            // ============================================ //
        }
        else
        {
            self.performSegue(withIdentifier: "mainToRent", sender: self)
        }
    }
    
    /*
     *showClosestHub
     *allows user to find the closest hub.
     */
    @IBAction func showClosestHub(_ sender: Any)
    {
        showClosestHubOrBike(type: "rack")
    }
    /*
     *showClosestBikeTapped
     *allows user to find the closest bike.
     */
    @IBAction func showClosestBikeTapped(_ sender: Any)
    {
        showClosestHubOrBike(type: "bike")
    }
    
    
    /// Handles action when user taps settings button.
    ///
    /// - Parameter sender: Any.
    @IBAction func settingsButtonTapped(_ sender: Any)
    {
        showSettingsMenu()
    }
    
    func bikesDownloaded(bikes: [Bike])
    {
        bikeList.bikes.removeAll()
        for bike in bikes
        {
            let newBike = Bike(id: bike.id, latitude: bike.latitude, longitude: bike.longitude, type: bike.type)
            bikeList.bikes.append(newBike)
            bikeList.locations.append(addAnnotations(locationName: "\(bike.type) Bike", lat: bike.latitude, long: bike.longitude, type: "bike"))
        }
    }
    
    func racksDownloaded(racks: [Rack])
    {
        hubs.racks.removeAll()
        Racks.clearList()
        for rack in racks
        {
            let newRack = Rack(name: rack.name, id: rack.id, latitude: rack.latitude, longitude: rack.longitude, bikes: rack.bikes, capacity: rack.capacity, gear: rack.gear)
            hubs.racks.append(newRack)
            hubs.locations.append(addAnnotations(locationName: "\(rack.name)", lat: rack.latitude, long: rack.longitude, type: "rack"))
            Racks.list.append(rack)
        }
    }
    
    /// Diosplays a basic alert.
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
    
    /// Displays the settings menu.
    func showSettingsMenu()
    {
        if let window = UIApplication.shared.keyWindow
        {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.8)
            blackView.frame = window.frame
            blackView.alpha = 0
            // Recognize when user taps background.
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMenuDismiss)))
            window.addSubview(blackView)
            let height: CGFloat = 200
            let y = window.frame.height - height
            menu.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            menu.separatorStyle = .none
            menu.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
            window.addSubview(menu)
            // Animate blackout's appearance.
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.menu.frame = CGRect(x: 0, y: y, width: self.menu.frame.width, height: self.menu.frame.height)
            }, completion: nil)
        }
    }
    
    /// Dismisses the handle menu.
    @objc func handleMenuDismiss()
    {
        UIView.animate(withDuration: 0.5, animations: {
            if let window = UIApplication.shared.keyWindow
            {
                self.blackView.alpha = 0
                self.menu.frame = CGRect(x: 0, y: window.frame.height, width: self.menu.frame.width, height: self.menu.frame.height)
            }
        })
    }
}

extension ViewController: CLLocationManagerDelegate
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

extension ViewController: MKMapViewDelegate
{
    func mapView(_ map: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        let colour = UIColor(red:0.72, green:0.99, blue:0.65, alpha:1.0)
        renderer.strokeColor = colour
        
        return renderer
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableViewCell
            else
        {
            fatalError("Unable to deque cell")
        }
        cell.label.text = menuArray[indexPath.row]
        cell.settingImage.image = UIImage(named: menuArray[indexPath.row])!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.row
        {
        case 0:
            if checkIfHasBooking(){
                performSegue(withIdentifier: "mainToRentals",sender: self)
            }
            else
            {
                createAlert(title: "No Reservation", message: "You do not currently have a reservation made.")
            }
            break
            
        case 1:
            performSegue(withIdentifier: "mainToProblem", sender: self)
            break
            
        case 2:
            AccountDetails.wipeDetails()
            RentDetails.wipeDetails()
            ReserveDetails.wipeDetails()
            performSegue(withIdentifier: "mainToLogin", sender: self)
            break
            
        case 3:
            handleMenuDismiss()
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
