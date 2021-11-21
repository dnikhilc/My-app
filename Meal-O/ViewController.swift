//
//  ViewController.swift
//  Meal-O
//
//  Created by MehulS on 21/07/21.
//

import UIKit
import GoogleMaps
import MapKit
import Turf
import CoreLocation
import SVProgressHUD
import Alamofire
import SwiftyJSON
import SDWebImage

enum CompassPoint: Double {
    case min = 0.0201
    case max = 0.016
}


class CellRestaurant: UICollectionViewCell {
    // CellRestaurant
    @IBOutlet weak var imageViewRestaurant: UIImageView!
    @IBOutlet weak var lblRestaurantName: UILabel!
    
}

class ViewController: UIViewController {
    
    // IBOutlet
    @IBOutlet weak var collectionViewRestaurant: UICollectionView!
    
    var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    
    var latArray = [Double]()
    var longArray = [Double]()
    
    var currentLatitude = 0.0
    var currentLongitude = 0.0
    var radius = 5000
    
    let GOOGLE_SEARCH_TYPE = "restaurant"
    let GOOGLE_SEARCH_RANKED_BY = "distance"
    let GOOGLE_API_KEY = "AIzaSyD2acd7GIfeeUgUYdswlfI1umkKrPNxu_o"
    let DOCUMENU_API_KEY = "81e921e52770f277fd21ba58aced2350"
    
    var googleRestaurantInfo: GoogleResturant!
    var arrayNearbyRestaurant = [Restaurants]()
    var selectedNearbyRestaurant = [Restaurants]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Navigation Bar Title
        self.title = "Restaurants"
        
        // Navigation Bar Right Button
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "Cart")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(btnCartClicked))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
        // Test Location, Stockton. California
        self.currentLatitude = 37.5576008
        self.currentLongitude = -121.9740721
        
        // Call Method
        self.getNearByRestaurants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Bring CollectionView to Front of MapView
        self.view.bringSubviewToFront(self.collectionViewRestaurant)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: - Cart Button
    @objc func btnCartClicked() -> Void {
        // Navigate to Restaurant Screen
        let viewCTR = self.storyboard?.instantiateViewController(identifier: "Cart") as! Cart        
        self.navigationController?.pushViewController(viewCTR, animated: true)
    }


}


// MARK: - Location Manager Delegates
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 16.0)
        
        self.mapView?.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
        
        if let location = locations.last {
            print("Current Location")
            print("Latitude: \(location.coordinate.latitude)")
            print("Longitude: \(location.coordinate.longitude)")
                        
            // Stop Updating Location
            self.locationManager.stopUpdatingLocation()
            
            // Get Nearby Restaurants
            // Check Lat and Long, if it is SAME then do not this method from here
            if self.currentLatitude != location.coordinate.latitude && self.currentLongitude != location.coordinate.longitude {
                
                // Get Current Location
                self.currentLatitude = location.coordinate.latitude
                self.currentLongitude = location.coordinate.longitude
                
                
                // Google Map View
                let camera = GMSCameraPosition.camera(withLatitude: self.currentLatitude, longitude: self.currentLongitude, zoom: 16.0)
                self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 160), camera: camera)
                self.mapView.isMyLocationEnabled = true
                self.view.addSubview(self.mapView)
                
                // Call Method
//                self.getNearByRestaurants()
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
}


// MARK: - UICollectionView Methods
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayNearbyRestaurant.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: self.collectionViewRestaurant.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellRestaurant", for: indexPath) as! CellRestaurant
        
        // Get Model
        let restaurant = self.arrayNearbyRestaurant[indexPath.row]
        
        // Set Data
        cell.lblRestaurantName.text = restaurant.restaurantName
        
        // Get Image
//        if let photoRef = restaurant.photos?.first?.photoReference {
//            let width = Int(UIScreen.main.bounds.width)
//            let strImageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(width)&photoreference=\(photoRef)&key=\(GOOGLE_API_KEY)"
//            let urlImage = URL(string: strImageURL)
//            cell.imageViewRestaurant.sd_setImage(with: urlImage, placeholderImage: UIImage(named: "food"))
//
//        }else {
            cell.imageViewRestaurant.image = UIImage(named: "food")
//        }
        
        // Highlight cell if selected
        if self.selectedNearbyRestaurant.contains(where: { (selectedRestaurant) -> Bool in
            selectedRestaurant.restaurantID == restaurant.restaurantID
        }) {
            // Exist
            cell.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            cell.lblRestaurantName.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            // Not Exist
            cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.lblRestaurantName.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if self.arrayNearbyRestaurant.count - 1 == indexPath.row {
            // self.getFoods()
            self.getNearByRestaurants()
        }
        
        // UIImageView Properties
        cell.imageViewRestaurant.contentMode = .scaleAspectFill
        cell.imageViewRestaurant.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If restaurant is not added then add it to array otherwise remove it from array
        let index = self.selectedNearbyRestaurant.firstIndex { (restaurant) -> Bool in
            restaurant.restaurantID == self.arrayNearbyRestaurant[indexPath.row].restaurantID
        } ?? nil
        
        if index == nil {
            // Add to array
            self.selectedNearbyRestaurant.append(arrayNearbyRestaurant[indexPath.row])
        } else {
            // Remove from Array
            self.selectedNearbyRestaurant.remove(at: index ?? 0)
        }
        
        // Refresh CollectionView to Highlight selected cell
        self.collectionViewRestaurant.reloadItems(at: [indexPath])
        
        
        
        
        // Navigate to Restaurant Screen
//        let viewCTR = self.storyboard?.instantiateViewController(identifier: "Restaurant") as! Restaurant
//
//        // Pass Data
//        viewCTR.restaurantObj = self.arrayNearbyRestaurant[indexPath.row]
//        viewCTR.arrayNearbyRestaurant = self.arrayNearbyRestaurant
//
//        self.navigationController?.pushViewController(viewCTR, animated: true)
        
        
        
        
        // If no restaurant selected then remove Polyline and Markers from map
        if self.selectedNearbyRestaurant.count <= 0 {
            // Clear Polyline, Marker, etc.
            self.mapView.clear()
            
        } else {
            // Draw path between Source, Destination and WayPoints (if any)
            self.loadSelectedRestaurantOnMap()
            
            // Draw Path
            self.drawBox()
        }
        
        
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
        
        for restaurant in self.selectedNearbyRestaurant {
            // Create Marker
            let latitude = restaurant.geo?.lat ?? 0.0
            let longitude = restaurant.geo?.lon ?? 0.0
            let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let marker = GMSMarker(position: position)
            marker.title = restaurant.restaurantName
            marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
            marker.map = mapView
            
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
        self.mapView.animate(with: update)
        
        // Pass Coordinates to draw path
//        let fromCoordinates = CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude)
//
//        let latitude = self.selectedNearbyRestaurant.first?.geo?.lat ?? 0.0
//        let longitude = self.selectedNearbyRestaurant.first?.geo?.lon ?? 0.0
//
//        let toCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        //        self.getRoute(from: fromCoordinates, to: toCoordinates)
//        self.fetchRoute(from: fromCoordinates, to: toCoordinates)
        
        // We don't need Source and Destination because
        // Current location will consider as Source
        // Destination will be first selected restaurant
        // Remaining selected restaurants will consider as WayPoints
        self.fetchRoute()
    }
    
    
    // MARK: - Add Multiple Markers on Map
    func addMultipleMarkers(_ markers: [Restaurants]) -> Void {
        for restaurant in markers {
            // Create Marker
            let latitude = restaurant.geo?.lat ?? 0.0
            let longitude = restaurant.geo?.lon ?? 0.0
            let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let marker = GMSMarker(position: position)
            marker.title = restaurant.restaurantName
            marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
            marker.map = mapView
        }
    }
    
}


// MARK: - Draw Route with MAPKIT
extension ViewController {
    
//    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
    func fetchRoute() {
        
        let session = URLSession.shared
        
//        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=AIzaSyD2acd7GIfeeUgUYdswlfI1umkKrPNxu_o"
        
        var urlString = ""
        var arrayWaypoints = [String]()
        var destinationLatitude = 0.0
        var destinationLongitude = 0.0
        
        if self.selectedNearbyRestaurant.count == 1 {
            let latitude = self.selectedNearbyRestaurant.first?.geo?.lat ?? 0.0
            let longitude = self.selectedNearbyRestaurant.first?.geo?.lon ?? 0.0
            
            urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.currentLatitude),\(self.currentLongitude)&destination=\(latitude),\(longitude)&sensor=false&mode=driving&key=AIzaSyD2acd7GIfeeUgUYdswlfI1umkKrPNxu_o"
        } else {
            var index = 0
            
            for restaurant in self.selectedNearbyRestaurant {
                let lat = restaurant.geo?.lat ?? 0.0
                let long = restaurant.geo?.lon ?? 0.0
                
                if index == 0 {
                    // Destination Coordinates
                    destinationLatitude = lat
                    destinationLongitude = long
                    
                } else {
                    // Waypoints
                    let strWayPoint = "\(lat),\(long)"
                    arrayWaypoints.append(strWayPoint)
                }
                
                // Increase Index
                index = index + 1
            }
        }
        
        // Get string of Way Point
        if arrayWaypoints.count > 0 {
            let strWayPoints = arrayWaypoints.joined(separator: "|")
            urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.currentLatitude),\(self.currentLongitude)&destination=\(destinationLatitude),\(destinationLongitude)&waypoints=\(strWayPoints)&key=AIzaSyD2acd7GIfeeUgUYdswlfI1umkKrPNxu_o"
        }
        
        // Testing URL
//        var urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=37.5509859,-121.9804076&destination=37.5463756,-121.9839984&waypoints=37.5437198,-121.9828605|37.5449522,-121.9839232|37.546411,-121.9832094&key=AIzaSyD2acd7GIfeeUgUYdswlfI1umkKrPNxu_o"
        
        // Format URL string
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
                
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse["routes"] as? [Any] else {
                return
            }
            
            guard routes.count > 0 else {
                return
            }
            
            guard let route = routes[0] as? [String: Any] else {
                return
            }
            
            guard let legs = route["legs"] as? [Any] else {
                return
            }
            
            guard let legsFirst = legs[0] as? [String: Any] else {
                return
            }
            
            guard let steps = legsFirst["steps"] as? [Any] else {
                return
            }
            print(steps)

            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }
            
            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }
            
            //Call this method to draw path on map
            DispatchQueue.main.async {
                self.drawPath(from: polyLineString, arraySteps: steps)
            }
            
        })
        task.resume()
    }
    
    
    func drawBox() {
        
        // Create Array
        var arrayLatitude = [Double]()
        var arrayLongitude = [Double]()
        
        // First Add Current Coordinates
        arrayLatitude.append(self.currentLatitude)
        arrayLongitude.append(self.currentLongitude)
        
        // Get first selected restaurant and add coordinates
        arrayLatitude.append(self.selectedNearbyRestaurant.first?.geo?.lat ?? 0.0)
        arrayLongitude.append(self.selectedNearbyRestaurant.first?.geo?.lon ?? 0.0)
        


        print(arrayLatitude) // Horizontal points
        print(arrayLongitude) // vertical points

        let maxxCoordinate = arrayLatitude.max() ?? 0.0
        let minxCoordinate = arrayLatitude.min() ?? 0.0
        let maxyCoordinate = arrayLongitude.max() ?? 0.0
        let minyCoordinate = arrayLongitude.min() ?? 0.0

        print(maxxCoordinate as Any)
        print(minyCoordinate as Any)

        print(minxCoordinate as Any)
        print(maxyCoordinate as Any)

        let fromCoordinates = CLLocationCoordinate2D(latitude: minxCoordinate - CompassPoint.min.rawValue, longitude: maxyCoordinate + CompassPoint.max.rawValue)
        let toCoordinates = CLLocationCoordinate2D(latitude: maxxCoordinate + CompassPoint.min.rawValue, longitude: minyCoordinate - CompassPoint.max.rawValue)

        self.drawRectangle(from: fromCoordinates, to: toCoordinates)
    }
    
    
    // Draw Rectangle
    func drawRectangle(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Create a rectangular path
        let rect = GMSMutablePath()
        
        rect.add(source)
        rect.add(CLLocationCoordinate2D(latitude: destination.latitude, longitude: source.longitude))
        rect.add(CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude))
        rect.add(CLLocationCoordinate2D(latitude: source.latitude, longitude: destination.longitude))
        rect.add(source)
                
        // Create the polygon, and assign it to the map.
        let polygon = GMSPolygon(path: rect)
        polygon.fillColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 0.1012492199)
        polygon.strokeColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        polygon.strokeWidth = 2
        polygon.map = mapView
        
        
        print("South West: \(source.latitude), \(destination.longitude)")
        let southWest = CLLocation(latitude: source.latitude, longitude: destination.longitude)
        
        print("North East: \(destination.latitude), \(source.longitude)")
        let northEast = CLLocation(latitude: destination.latitude, longitude: source.longitude)
        
        // Get Center Point of RECT
        let centerX = (source.latitude + destination.latitude) / 2
        let centerY = (source.longitude + destination.longitude) / 2
        print("Center Point: \(centerX), \(centerY)")
        let centerPoint = CLLocation(latitude: centerX, longitude: centerY)
        
        // Distance
        let distanceSouthWest = southWest.distance(from: centerPoint)
        print("Center distance from South West: \(distanceSouthWest) meters")
        
        let distanceNorthEast = northEast.distance(from: centerPoint)
        print("Center distance from North East: \(distanceNorthEast) meters")
        
        // First clear previous data from Array
        self.arrayNearbyRestaurant.removeAll()
        self.googleRestaurantInfo = nil
        self.collectionViewRestaurant.reloadData()
        
        // Setting Center Point to Current Location to get data
        self.currentLatitude = centerX
        self.currentLongitude = centerY
                
        // Call Google API to get restaurant in Rect w.r.t. Center Point
        self.radius = Int(distanceSouthWest)
        self.getNearByRestaurants()
    }
    
    func drawPath(from polyStr: String, arraySteps: [Any]) {
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 7.0
        polyline.strokeColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        polyline.map = mapView // Google MapView
        
//        if let dict = arraySteps.first as? [String: Any] {
//
//            if let startLocation = dict["start_location"] as? [String: Any] {
//
//                let latitude = startLocation["lat"] as? Double ?? 0.0
//                let longitude = startLocation["lng"] as? Double ?? 0.0
//
//                latArray.append(latitude)
//                longArray.append(longitude)
//            }
//        }
//
//        var arrayStepsOfCoordinates = [CLLocationCoordinate2D]()
//        for item in arraySteps {
//            if let dict = item as? [String: Any] {
//                if let endLocation = dict["end_location"] as? [String: Any] {
//
//                    let latitude = endLocation["lat"] as? Double ?? 0.0
//                    let longitude = endLocation["lng"] as? Double ?? 0.0
//
//                    latArray.append(latitude)
//                    longArray.append(longitude)
//
//                    print(latitude)
//                    print(longitude)
//
//
//                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                    arrayStepsOfCoordinates.append(coordinate)
//                }
//            }
//        }
//
//
//        print(latArray) // Horizontal points
//        print(longArray) // vertical points
//
//        let maxxCoordinate = latArray.max() ?? 0.0
//        let minxCoordinate = latArray.min() ?? 0.0
//        let maxyCoordinate = longArray.max() ?? 0.0
//        let minyCoordinate = longArray.min() ?? 0.0
//
//        print(maxxCoordinate as Any)
//        print(minyCoordinate as Any)
//
//        print(minxCoordinate as Any)
//        print(maxyCoordinate as Any)
//
//        let fromCoordinates = CLLocationCoordinate2D(latitude: minxCoordinate - CompassPoint.min.rawValue, longitude: maxyCoordinate + CompassPoint.max.rawValue)
//        let toCoordinates = CLLocationCoordinate2D(latitude: maxxCoordinate + CompassPoint.min.rawValue, longitude: minyCoordinate - CompassPoint.max.rawValue)
//
//        self.drawRectangle(from: fromCoordinates, to: toCoordinates)
//
//        let line = LineString(arrayStepsOfCoordinates)
//        let snapped = line.closestCoordinate(to: CLLocationCoordinate2D(latitude: 23.02771, longitude: 72.5068811))
//        print(snapped?.distance)
//        print(snapped?.coordinate)
        
    }
    
    // MARK: - Check Resturant lies inside Polygon
    func checkResturantInsidePolygon(WithPath polygonPath: GMSPath, restaurantCoorfinates: CLLocationCoordinate2D) -> Bool {
        if GMSGeometryContainsLocation(restaurantCoorfinates, GMSPath(path: polygonPath), true) {
            print("Restaurant is inside polygon")
            return true
        } else {
            print("Restaurant is NOT inside polygon")
            return false
        }
    }
    
}


// MARK: - Google APIs
extension ViewController {
    
    // MARK: - Nearby Restaurants
    func getNearByRestaurants() -> Void {
        
        // Start Loading
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        
        let url = "https://api.documenu.com/v2/restaurants/search/geo?lat=\(self.currentLatitude)&lon=\(self.currentLongitude)&distance=\(self.radius)&fullmenu&key=\(DOCUMENU_API_KEY)"
        
        
        // Check if we have PAGE TOKEN or not
        //        if self.googleRestaurantInfo != nil {
        //            // If No more data available, no need to call Google API
        //            if self.arrayNearbyRestaurant.count > 0 && (self.googleRestaurantInfo.nextPageToken == "" || self.googleRestaurantInfo.nextPageToken == nil) {
        //                //Stop Activity Indicator
        //                DispatchQueue.main.async {
        //                    SVProgressHUD.dismiss()
        //                }
        //
        //                return
        //            }
        //
        //            url = url + "&pagetoken=\(self.googleRestaurantInfo.nextPageToken ?? "")"
        //        }
        
        
        //Call API to get data
        AF.request(url, parameters: [:])
            .validate()
            .responseJSON(completionHandler: { (response) in
                
                //Stop Activity Indicator
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                
                switch (response.result) {
                
                case .success( _):
                    
                    if let json = response.data {
                        do {
                            let restaurants = try JSONDecoder().decode(GoogleResturant?.self, from: json)
                            
                            //Set response Data
                            self.googleRestaurantInfo = restaurants
                            
                            // Add Markers on Map
                            self.addMultipleMarkers(restaurants?.data ?? [])
                            
                            // Check and append restaurants
                            if self.arrayNearbyRestaurant.count <= 0 {
                                self.arrayNearbyRestaurant = self.googleRestaurantInfo.data ?? []
                            }else {
                                self.arrayNearbyRestaurant.append(contentsOf: self.googleRestaurantInfo.data ?? [])
                            }
                            print("Total Restaurants: \(self.arrayNearbyRestaurant.count)")
                            
                            
                            //Check if there is any data or not
                            if (self.arrayNearbyRestaurant.count <= 0) {
                                //No Data
                                print("No Data")
                                
                            }else {
                            }
                            
                            // Reload Data
                            self.collectionViewRestaurant.reloadData()
                            
                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                            print("Error: \(error)")
                        }
                    }
                    
                case .failure(let error):
                    print("Request error: \(error.localizedDescription)")
                }
            })
    }
    
    
    func getJSONFrom(Data data: Data) -> JSON? {
        do {
            return try JSON(data: data, options: .mutableContainers)
        } catch _ {
            return nil
        }
        
    }
    
    
    
}

