//
//  RestaurantModel.swift
//  Meal-O
//
//  Created by MehulS on 22/07/21.
//

import Foundation

struct Restaurant {
    let id: Int
    let name: String
    let image: String
    let latitude: Double
    let longitude: Double
}

let arrayRestaurant: [Restaurant] = [
    Restaurant(id: 1, name: "Dakshinayan", image: "1.jpg", latitude: 23.0254699, longitude: 72.5100133),
    Restaurant(id: 2, name: "Jassi De Parathe", image: "2.jpg", latitude: 23.0165016, longitude: 72.5070293),
    Restaurant(id: 3, name: "Mocha CG Road", image: "3.jpg", latitude: 23.0289281, longitude: 72.5351102),
    Restaurant(id: 4, name: "Mill & Co", image: "4.jpg", latitude: 23.0742093, longitude: 72.5208002),
    Restaurant(id: 5, name: "Cafe De Italiano", image: "5.jpg", latitude: 23.0374618, longitude: 72.4937565),
    Restaurant(id: 6, name: "The Golden BBQ", image: "6.jpg", latitude: 23.1032995, longitude: 72.5925755),
    Restaurant(id: 7, name: "Greenz Restaurant", image: "7.jpg", latitude: 23.1836123, longitude: 72.6234424),
    Restaurant(id: 8, name: "1944 The Hocco Kitchen", image: "8.jpg", latitude: 23.0694322, longitude: 72.4953906),
    Restaurant(id: 9, name: "Urban Chowk", image: "9.jpg", latitude: 23.0254603, longitude: 72.4950243),
    Restaurant(id: 10, name: "Iscon Thal", image: "10.jpg", latitude: 23.0280099, longitude: 72.5064721),
    Restaurant(id: 11, name: "Domino's Pizza Satellite", image: "11.jpg", latitude: 23.0242225, longitude: 72.5071436),
    Restaurant(id: 12, name: "Zen Cafe", image: "12.jpg", latitude: 23.0269733, longitude: 72.5216402),
    Restaurant(id: 13, name: "Prime Dine", image: "13.jpg", latitude: 23.0190182, longitude: 72.5160279),
    Restaurant(id: 14, name: "Gormoh Restaurant", image: "14.jpg", latitude: 23.0367251, longitude: 72.5123995),
    Restaurant(id: 15, name: "The Grand Bhagwati", image: "15.jpg", latitude: 23.0412966, longitude: 72.51263),
]
