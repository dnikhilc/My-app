//
//  ViewController.swift
//  Meal-O
//
//  Created by MehulS on 21/07/21.
//

import UIKit
import GoogleMaps



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Navigation Bar Title
        self.title = "Restaurants"
        
        // Google Map View
        let camera = GMSCameraPosition.camera(withLatitude: 32.8563718, longitude: -96.8297929, zoom: 10.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
    }


}

