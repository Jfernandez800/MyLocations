//
//  ViewController.swift
//  MyLocations
//
//  Created by James Fernandez on 9/12/23.
//

//--------------------------Chapter 22---------------------------------
import CoreLocation
import UIKit
import CoreData

class CurrentLocationViewController: UIViewController, /*Chapter 22*/ CLLocationManagerDelegate {
    
    //Chapter 22 - will give you GPS coordinates.
    let locationManager = CLLocationManager()
    
    //--------------------------Chapter 22---------------------------------
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    //Chapter 22 - You will store the user’s current location in this variable.
    var location: CLLocation?
    
    //Chapter 23 -
    var updatingLocation = false
    var lastLocationError: Error?
    
    //Chapter 23 - These mirror what you did for the location manager.
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    //Chapter 27 -
    var managedObjectContext: NSManagedObjectContext!
    
    //Chapter 23 -
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    // MARK: - Actions
    //Chapter 22 - This method is hooks up to "Get My Location" button. tells the location manager that the view controller is its delegate and that you want to receive locations with an accuracy of up to ten meters.
    @IBAction func getLocation() {
        
        //Chapter 22 - this checks the current authorization status. If it is .notDetermined — meaning that this app has not asked for permission yet — then the app will request “When In Use” authorization.
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        //Chapter 22 - This shows the alert if the authorization status is denied or restricted.
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        //If the button is pressed while the app is already doing the location fetching, you stop the location manager.
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
        updateLabels()
    }
    
    //Chapter 23 - this checks whether the location services are enabled and you set the variable updatingLocation to true if you did indeed start location updates.
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            //Chapter 23 - The new lines set up a timer object that sends a didTimeOut message to self after 60 seconds.
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    //Chapter 23 - Checks whether the boolean instance variable updatingLocation is true or false.
    func stopLocationManager() {
        //Chapter 23 - The reason for having this updatingLocation variable is that you are going to change the appearance of the Get My Location button and the status message label when the app is trying to obtain a location fix, to let the user know the app is working on it.
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            //Chapter 23 - cancel the timer in case the location manager is stopped before the time-out fires.
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("didFailWithError \(error.localizedDescription)")
        //Chapter 23 - The CLError.locationUnknown error means the location manager was unable to obtain a location right now.
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        /*Chapter 23 - In the case of a more serious error, you store the error object into the new instance variable, lastLocationError.
         That way, you can look up later what kind of error you were dealing with.*/
        lastLocationError = error
        //Chapter 23 - If obtaining a location appears to be impossible for wherever the user currently is on the globe, then you need to tell the location manager to stop.
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        //Chapter 23 - 1 - If the time at which the given location object was determined is too long ago — 5 seconds in this case —, then this is a cached result.
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        //Chapter 23 - 2 - To determine whether new readings are more accurate than previous ones, you’ll use the horizontalAccuracy property of the location object.
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        //Chapter 23 - This calculates the distance between the new reading and the previous reading.
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        //Chapter 23 - 3 - This is where you determine if the new reading is more useful than the previous one.
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            //Chapter 23 - 4 - clears out any previous error and stores the new CLLocation object into the location variable.
            lastLocationError = nil
            location = newLocation
            //Chapter 23 - 5 - If the new location’s accuracy is equal to or better than the desired accuracy, you can call it a day and stop asking the location manager for updates.
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                
                //Chapter 23 - forces a reverse geocoding for the final location.
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            updateLabels()
            //Chapter 23 - store the error object so you can refer to it later
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation) {placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let places = placemarks, !places.isEmpty {
                        self.placemark = places.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
                //Chapter 23 - If the coordinate from the reading is not different from the previous reading and its been more than 10 seconds since the original reading, then stop.
            } else if distance < 1 {
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                if timeInterval > 10 {
                    print("*** Force done!")
                    stopLocationManager()
                    updateLabels()
                }
            }
        }
    }
    // End of the new code
    
    
    
    // MARK: - Helper Methods
    //Chapter 22 - This pops up an alert with a helpful hint.
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    //Chapter 22 - If there is a valid location object, you convert the latitude and longitude, which are values with type Double, into strings and put them into the labels.
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            //Chapter 23 - If you’ve found an address, you show that to the user, otherwise you show a status message.
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true

            //Chapter 23 - This determines what to put in the messageLabel at the top of the screen.
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
            configureGetButton()
        }
    }
    
    //Chapter 23 - if the app is currently updating the location, then the button’s title becomes Stop, otherwise it is Get My Location.
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    //Chapter 23 -
    func string(from placemark: CLPlacemark) -> String {
        // 1 - create a new string variable for the first line of text.
        var line1 = ""
        // 2 - If the placemark has a subThoroughfare, add it to the string.
        if let tmp = placemark.subThoroughfare {
            line1 += tmp + " "
        }
        // 3 - Adding the thoroughfare, or street name, is done similarly.
        if let tmp = placemark.thoroughfare {
            line1 += tmp }
        // 4 - This adds the locality (the city), administrative area (the state or province), and postal code (or zip code), with spaces between them where appropriate.
        var line2 = ""
        if let tmp = placemark.locality {
            line2 += tmp + " "
        }
        if let tmp = placemark.administrativeArea {
            line2 += tmp + " "
        }
        if let tmp = placemark.postalCode {
            line2 += tmp }
        // 5 - the two lines are concatenated, or added together, with a newline character in between.
        return line1 + "\n" + line2
    }
    
    
    @objc func didTimeOut() {
        print("*** Time out")
        // If after that one minute there still is no valid location, you stop the location manager, create your own error code, and update the screen.
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
    }
    
    //Chpater 25 - asks the navigation controller to hide the navigation bar when this particular view is about to appear. 
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.isNavigationBarHidden = true
    }
    
    //reverse viewWillAppear.
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      navigationController?.isNavigationBarHidden = false
    }
    
    //Chapter 25 -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            //Chapter 27 - This should also explain why the managedObjectContext variable is declared as an implicitly unwrapped optional with the type NSManagedObjectContext!.
            controller.managedObjectContext = managedObjectContext
        }
    }
}
