//
//  GoogleResturants.swift
//  Meal-O
//
//  Created by MehulS on 05/10/21.
//

import Foundation

// MARK: - Welcome
struct GoogleResturant: Codable {
    let totalResults, page, totalPages: Int?
    let morePages: Bool?
    var data: [Restaurants]?
    let numResults: Int?

    enum CodingKeys: String, CodingKey {
        case totalResults, page
        case totalPages = "total_pages"
        case morePages = "more_pages"
        case data, numResults
    }
}

// MARK: - Datum
struct Restaurants: Codable {
    let restaurantName, restaurantPhone: String?
    let restaurantWebsite: String?
    let hours: String?
    let priceRange: String?
    let priceRangeNum: Int?
    let restaurantID: Double?
    let cuisines: [String]?
    let address: Address?
    let geo: Geo?
    var menus: [Menu]?
    let lastUpdated: String?
    
    // Local
    var isAddedInCart: Bool? = false

    enum CodingKeys: String, CodingKey {
        case restaurantName = "restaurant_name"
        case restaurantPhone = "restaurant_phone"
        case restaurantWebsite = "restaurant_website"
        case hours
        case priceRange = "price_range"
        case priceRangeNum = "price_range_num"
        case restaurantID = "restaurant_id"
        case cuisines, address, geo, menus
        case lastUpdated = "last_updated"
    }
}

// MARK: - Address
struct Address: Codable {
    let city: String?
    let state: String?
    let postalCode, street, formatted: String?
    
    enum CodingKeys: String, CodingKey {
        case city
        case state
        case postalCode = "postal_code"
        case street, formatted
    }
}


// MARK: - Geo
struct Geo: Codable {
    let lat, lon: Double?
}

// MARK: - Menu
struct Menu: Codable {
    let menuName: MenuName?
    var menuSections: [MenuSection]?

    enum CodingKeys: String, CodingKey {
        case menuName = "menu_name"
        case menuSections = "menu_sections"
    }
}

enum MenuName: String, Codable {
    case breakfast = "Breakfast"
    case dinner = "Dinner"
    case empty = ""
    case lunch = "Lunch"
    case main = "Main"
}

// MARK: - MenuSection
struct MenuSection: Codable {
    let sectionName, menuSectionDescription: String?
    var menuItems: [MenuItem]?

    enum CodingKeys: String, CodingKey {
        case sectionName = "section_name"
        case menuSectionDescription = "description"
        case menuItems = "menu_items"
    }
}

// MARK: - MenuItem
struct MenuItem: Codable {
    let name, menuItemDescription: String?
    let pricing: [Pricing]?
    let price: Double?
    
    // Local
    var quantity: Int? = 0

    enum CodingKeys: String, CodingKey {
        case name
        case menuItemDescription = "description"
        case pricing, price
    }
}

// MARK: - Pricing
struct Pricing: Codable {
    let price: Double?
    let currency: String?
    let priceString: String?
}







