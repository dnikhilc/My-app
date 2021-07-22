//
//  ViewController.swift
//  Meal-O
//
//  Created by MehulS on 21/07/21.
//

import UIKit
import GoogleMaps


class CellRestaurant: UICollectionViewCell {
    // CellRestaurant
    @IBOutlet weak var imageViewRestaurant: UIImageView!
    @IBOutlet weak var lblRestaurantName: UILabel!
    
}

class ViewController: UIViewController {
    
    // IBOutlet
    @IBOutlet weak var collectionViewRestaurant: UICollectionView!
    
    var mapView: GMSMapView!
    var arraySelectedRestaurant = [Restaurant]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Navigation Bar Title
        self.title = "Restaurants"
        
        // Google Map View
        let camera = GMSCameraPosition.camera(withLatitude: 23.0254946, longitude: 72.5103725, zoom: 16.0)
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 160), camera: camera)
        self.mapView.isMyLocationEnabled = true
        self.view.addSubview(self.mapView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Bring CollectionView to Front of MapView
        self.view.bringSubviewToFront(self.collectionViewRestaurant)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


}


// MARK: - UICollectionView Methods
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayRestaurant.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: self.collectionViewRestaurant.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellRestaurant", for: indexPath) as! CellRestaurant
        
        // Get Model
        let restaurant = arrayRestaurant[indexPath.row]
        
        // Set Data
        cell.imageViewRestaurant.image = UIImage(named: restaurant.image)
        cell.lblRestaurantName.text = restaurant.name
        
        // Highlight cell if selected
        if self.arraySelectedRestaurant.contains(where: { (selectedRestaurant) -> Bool in
            selectedRestaurant.id == restaurant.id
        }) {
            // Exist
            cell.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            cell.lblRestaurantName.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            // Not Exist
            cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.lblRestaurantName.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        // UIImageView Properties
        cell.imageViewRestaurant.contentMode = .scaleAspectFill
        cell.imageViewRestaurant.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If restaurant is not added then add it to array otherwise remove it from array
        let index = self.arraySelectedRestaurant.firstIndex { (restaurant) -> Bool in
            restaurant.id == arrayRestaurant[indexPath.row].id
        } ?? nil
        
        if index == nil {
            // Add to array
            self.arraySelectedRestaurant.append(arrayRestaurant[indexPath.row])
        } else {
            // Remove from Array
            self.arraySelectedRestaurant.remove(at: index ?? 0)
        }
        
        // Refresh CollectionView to Highlight selected cell
        self.collectionViewRestaurant.reloadItems(at: [indexPath])
        
        // Load selected restaurant on the MAP
        self.loadSelectedRestaurantOnMap()
    }
    
}


// MARK: - Map Methods
extension ViewController {
    
    // MARK: - Load Markers on Map
    func loadSelectedRestaurantOnMap() {
        // Remove previosuly added markers
        self.mapView.clear()
        
        // bounds will be use to show all selected Markers
        var bounds = GMSCoordinateBounds()
        
        for restaurant in self.arraySelectedRestaurant {
            // Create Marker
            let position = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
            let marker = GMSMarker(position: position)
            marker.title = restaurant.name
            marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
            marker.map = mapView
            
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
        self.mapView.animate(with: update)
    }
    
}
