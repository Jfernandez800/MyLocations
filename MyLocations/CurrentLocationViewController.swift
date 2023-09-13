//
//  ViewController.swift
//  MyLocations
//
//  Created by James Fernandez on 9/12/23.
//

import UIKit
//--------------------------Chapter 22---------------------------------
import CoreLocation

class CurrentLocationViewController: UIViewController, /*Chapter 22*/ CLLocationManagerDelegate {
    
    //will give you GPS coordinates.
    let locationManager = CLLocationManager()
    
    //--------------------------Chapter 22---------------------------------
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    //This method is hooks up to "Get My Location" button. tells the location manager that the view controller is its delegate and that you want to receive locations with an accuracy of up to ten meters.
    @IBAction func getLocation() {
        
        //this checks the current authorization status. If it is .notDetermined — meaning that this app has not asked for permission yet — then the app will request “When In Use” authorization.
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //Then you start the location manager.
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    //error.localizedDescription bit which, instead of simply printing out the contents of the error variable,
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        //outputs a human understandable version of the error (if possible) based on the device’s current locale, or language setting.
        print("didFailWithError \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
    }
}

