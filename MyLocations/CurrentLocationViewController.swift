//
//  ViewController.swift
//  MyLocations
//
//  Created by James Fernandez on 9/12/23.
//

//--------------------------Chapter 22---------------------------------
import CoreLocation
import UIKit


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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //Chapter 22 - Then you start the location manager.
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    //Chapter 22 - error.localizedDescription bit which, instead of simply printing out the contents of the error variable,
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        //Chapter 22 - outputs a human understandable version of the error (if possible) based on the device’s current locale, or language setting.
        print("didFailWithError \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        //Chapter 22 - You store the CLLocation object that you get from the location manager into the instance variable and call a new updateLabels() method.
        location = newLocation
        updateLabels()
    }
    
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
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"
        }
    }
}
