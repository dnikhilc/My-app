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
    var locationManager = CLLocationManager()
    
    var latArray = [Double]()
    var longArray = [Double]()
    
    var currentLatitude = 0.0
    var currentLongitude = 0.0
    
    let GOOGLE_SEARCH_TYPE = "restaurant"
    let GOOGLE_SEARCH_RANKED_BY = "distance"
    let GOOGLE_API_KEY = "AIzaSyD2acd7GIfeeUgUYdswlfI1umkKrPNxu_o"
    
    var googleRestaurantInfo: GoogleResturant!
    var arrayNearbyRestaurant = [Restaurants]()
    var selectedNearbyRestaurant = [Restaurants]()
    
    
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
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
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
                
                // Call Method
                self.getNearByRestaurants()
            }
            
        }
    }
}


// MARK: - UICollectionView Methods
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayNearbyRestaurant.count > 0 {
            return self.arrayNearbyRestaurant.count
        }
        return arrayRestaurant.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: self.collectionViewRestaurant.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellRestaurant", for: indexPath) as! CellRestaurant
        
        
        if self.arrayNearbyRestaurant.count > 0 {
            // Get Model
            let restaurant = self.arrayNearbyRestaurant[indexPath.row]
            
            // Set Data
            cell.lblRestaurantName.text = restaurant.name
            
            // Get Image
            if let photoRef = restaurant.photos?.first?.photoReference {
                let width = Int(UIScreen.main.bounds.width)
                let strImageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(width)&photoreference=\(photoRef)&key=\(GOOGLE_API_KEY)"
                let urlImage = URL(string: strImageURL)
                cell.imageViewRestaurant.sd_setImage(with: urlImage, placeholderImage: UIImage(named: "food"))
            
            }else {
                cell.imageViewRestaurant.image = UIImage(named: "food")
            }
            
            // Highlight cell if selected
            if self.selectedNearbyRestaurant.contains(where: { (selectedRestaurant) -> Bool in
                selectedRestaurant.placeID == restaurant.placeID
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
            
        } else {
            
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
        }
        
        // UIImageView Properties
        cell.imageViewRestaurant.contentMode = .scaleAspectFill
        cell.imageViewRestaurant.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If restaurant is not added then add it to array otherwise remove it from array
        if self.arrayNearbyRestaurant.count > 0 {
            let index = self.selectedNearbyRestaurant.firstIndex { (restaurant) -> Bool in
                restaurant.placeID == self.arrayNearbyRestaurant[indexPath.row].placeID
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
            
            // Load selected restaurant on the MAP
            if self.selectedNearbyRestaurant.count > 0 {
                self.loadSelectedRestaurantOnMap()
            } else {
                // Clear Polyline, Marker, etc.
                self.mapView.clear()
            }
            
        } else {
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
            if self.arraySelectedRestaurant.count > 0 {
                self.loadSelectedRestaurantOnMap()
            } else {
                // Clear Polyline, Marker, etc.
                self.mapView.clear()
            }
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
        
        if self.arrayNearbyRestaurant.count > 0 {
            for restaurant in self.selectedNearbyRestaurant {
                // Create Marker
                let latitude = restaurant.geometry?.location?.lat ?? 0.0
                let longitude = restaurant.geometry?.location?.lng ?? 0.0
                let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let marker = GMSMarker(position: position)
                marker.title = restaurant.name
                marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
                marker.map = mapView
                
                bounds = bounds.includingCoordinate(marker.position)
            }
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
            self.mapView.animate(with: update)
            
            // Pass Coordinates to draw path
            let fromCoordinates = CLLocationCoordinate2D(latitude: 23.0254946, longitude: 72.5103725)
            
            let latitude = self.selectedNearbyRestaurant.first?.geometry?.location?.lat ?? 0.0
            let longitude = self.selectedNearbyRestaurant.first?.geometry?.location?.lng ?? 0.0
            
            let toCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            //        self.getRoute(from: fromCoordinates, to: toCoordinates)
            self.fetchRoute(from: fromCoordinates, to: toCoordinates)
            
        } else {
            
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
            
            // Pass Coordinates to draw path
            let fromCoordinates = CLLocationCoordinate2D(latitude: 23.0254946, longitude: 72.5103725)
            let toCoordinates = CLLocationCoordinate2D(latitude: self.arraySelectedRestaurant.first?.latitude ?? 0.0, longitude: self.arraySelectedRestaurant.first?.longitude ?? 0.0)
            //        self.getRoute(from: fromCoordinates, to: toCoordinates)
            self.fetchRoute(from: fromCoordinates, to: toCoordinates)
        }
    }
    
}


// MARK: - Draw Route with MAPKIT
extension ViewController {
    
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        
        let session = URLSession.shared
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=AIzaSyD2acd7GIfeeUgUYdswlfI1umkKrPNxu_o"
                
        let url = URL(string: urlString)
        
        let task = session.dataTask(with: url!, completionHandler: {
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
    
    // Draw Rectangle
    func drawRectangle(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Create a rectangular path
        let rect = GMSMutablePath()
//        rect.add(CLLocationCoordinate2D(latitude: 23.0254946, longitude: 72.5103725))
//        rect.add(CLLocationCoordinate2D(latitude: 23.0174946, longitude: 72.5103725))
//        rect.add(CLLocationCoordinate2D(latitude: 23.0174946, longitude: 72.4903725))
//        rect.add(CLLocationCoordinate2D(latitude: 23.0254946, longitude: 72.4903725))
        
        rect.add(source)
        rect.add(CLLocationCoordinate2D(latitude: destination.latitude, longitude: source.longitude))
        rect.add(CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude))
        rect.add(CLLocationCoordinate2D(latitude: source.latitude, longitude: destination.longitude))
        rect.add(source)
                
        // Create the polygon, and assign it to the map.
        let polygon = GMSPolygon(path: rect)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
        polygon.strokeColor = UIColor.init(hue: 210, saturation: 88, brightness: 84, alpha: 1)
        polygon.strokeWidth = 2
        polygon.map = mapView
        
        
        // Check Dakshinyan is inside the rectangle
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { (timer) in
            // Get Dakshinyan Latitude and Longitude
            let dakshinyan = CLLocationCoordinate2D(latitude: 23.0254699, longitude: 72.5100133)
            if self.checkResturantInsidePolygon(WithPath: rect, restaurantCoorfinates: dakshinyan) {
                print("Y : Dakshinyan restaurant is inside the rectangle")
            } else {
                print("X : Dakshinyan restaurant is NOT inside the rectangle")
            }
            
        }
    }
    
    func drawPath(from polyStr: String, arraySteps: [Any]) {
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 7.0
        polyline.strokeColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        polyline.map = mapView // Google MapView
        
        
        // Create the polygon, and assign it to the map.
//        let polygon = GMSPolygon(path: path)
//        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
//        polygon.strokeColor = .black
//        polygon.strokeWidth = 2
//        polygon.map = mapView
        
        if let dict = arraySteps.first as? [String: Any] {
            
            if let startLocation = dict["start_location"] as? [String: Any] {
                
                let latitude = startLocation["lat"] as? Double ?? 0.0
                let longitude = startLocation["lng"] as? Double ?? 0.0
                
                latArray.append(latitude)
                longArray.append(longitude)
            }
        }
        
        var arrayStepsOfCoordinates = [CLLocationCoordinate2D]()
        for item in arraySteps {
            if let dict = item as? [String: Any] {
                if let endLocation = dict["end_location"] as? [String: Any] {
                    
                    let latitude = endLocation["lat"] as? Double ?? 0.0
                    let longitude = endLocation["lng"] as? Double ?? 0.0
                    
                    latArray.append(latitude)
                    longArray.append(longitude)
                    
                    print(latitude)
                    print(longitude)

                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    arrayStepsOfCoordinates.append(coordinate)
                }
            }
        }
        
        
        print(latArray) // Horizontal points
        print(longArray) // vertical points
        
        let maxxCoordinate = latArray.max() ?? 0.0
        let minxCoordinate = latArray.min() ?? 0.0
        let maxyCoordinate = longArray.max() ?? 0.0
        let minyCoordinate = longArray.min() ?? 0.0
        
        print(maxxCoordinate as Any)
        print(minyCoordinate as Any)
        
        print(minxCoordinate as Any)
        print(maxyCoordinate as Any)
        
        let fromCoordinates = CLLocationCoordinate2D(latitude: minxCoordinate - 0.0201, longitude: maxyCoordinate + 0.016)
        let toCoordinates = CLLocationCoordinate2D(latitude: maxxCoordinate + 0.0201, longitude: minyCoordinate - 0.016)
        
        self.drawRectangle(from: fromCoordinates, to: toCoordinates)
        
        let line = LineString(arrayStepsOfCoordinates)
        
//        let snapped = line.closestCoordinate(to: CLLocationCoordinate2D(latitude: 23.0243068, longitude: 72.5073994))
//        let snapped = line.closestCoordinate(to: CLLocationCoordinate2D(latitude: 23.0294643, longitude: 72.5114502))
        let snapped = line.closestCoordinate(to: CLLocationCoordinate2D(latitude: 23.02771, longitude: 72.5068811))
        
        print(snapped?.distance)
        print(snapped?.coordinate)
        
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
    
    
    
    
    
    
    
    
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: to))

        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: { (response, error) in
            if let res = response {
                //the function to convert the result and show
                self.show(polyline: self.googlePolylines(from: res))
            }
        })
    }
    
    private func googlePolylines(from response: MKDirections.Response) -> GMSPolyline {

        let route = response.routes[0]
        var coordinates = [CLLocationCoordinate2D](
            repeating: kCLLocationCoordinate2DInvalid,
            count: route.polyline.pointCount)

        route.polyline.getCoordinates(
            &coordinates,
            range: NSRange(location: 0, length: route.polyline.pointCount))

        let polyline = Polyline(coordinates: coordinates)
        let encodedPolyline: String = polyline.encodedPolyline
        let path = GMSPath(fromEncodedPath: encodedPolyline)
        return GMSPolyline(path: path)
        
    }
    
    func show(polyline: GMSPolyline) {

        //add style to polyline
        polyline.strokeColor = UIColor.red
        polyline.strokeWidth = 3
        
        //add to map
        polyline.map = mapView
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
        
        //Get URL
        var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.currentLatitude),\(self.currentLongitude)&rankby=\(GOOGLE_SEARCH_RANKED_BY)&type=\(GOOGLE_SEARCH_TYPE)&key=\(GOOGLE_API_KEY)&opennow"
        
        // Check if we have PAGE TOKEN or not
        if self.googleRestaurantInfo != nil {
            url = url + "&pagetoken=\(self.googleRestaurantInfo.nextPageToken ?? "")"
        }
        
//        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&rankby=distance&type=restaurant&key=AIzaSyD2acd7GIfeeUgUYdswlfI1umkKrPNxu_o&opennow"
        
        
        //Call API to get data
        AF.request(url, parameters: [:])
            .validate()
            .responseDecodable(of: GoogleResturant.self) { response in
                
                //Stop Activity Indicator
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                
                //Check if there is DATA available then only proceed ahead
                guard let restaurantData = response.value else {
                    print("Error: ", response.error?.localizedDescription as Any)
                    return
                }
                
                //Set response Data
                self.googleRestaurantInfo = restaurantData
                
                // Check and append restaurants
                if self.arrayNearbyRestaurant.count <= 0 {
                    self.arrayNearbyRestaurant = self.googleRestaurantInfo.results ?? []
                }else {
                    self.arrayNearbyRestaurant.append(contentsOf: self.googleRestaurantInfo.results ?? [])
                }
                print("Total Restaurants: \(self.arrayNearbyRestaurant.count)")
                
                
                //Check if there is any data or not
                if (self.arrayNearbyRestaurant.count <= 0) {
                    //No Data
                    print("No Data")
                    
                }else {
                    
                    // Reload Data
                    self.collectionViewRestaurant.reloadData()
                }
        }
            // Print Response String
            .responseString { (responce) in
                print("---------------------------------Response--------------------------------------")
                print("URL : ",url)
                print("PARAM : ",[])
                print("RESPONCE :- ",JSON(responce.value ?? ""))
                print("RESPONCE CODE :- ",responce.response?.statusCode ?? "")
                print("------------------------------------------------------------------------------")
        }
    }
    
}

