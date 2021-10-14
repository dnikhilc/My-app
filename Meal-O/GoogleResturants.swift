//
//  GoogleResturants.swift
//  Meal-O
//
//  Created by MehulS on 05/10/21.
//

import Foundation

// MARK: - Welcome
struct GoogleResturant: Codable {
    let nextPageToken: String?
    let results: [Restaurants]?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case nextPageToken = "next_page_token"
        case results, status
    }
}

// MARK: - Result
struct Restaurants: Codable {
    let businessStatus: String?
    var geometry: Geometry?
    let icon: String?
    let name: String?
    let openingHours: OpeningHours?
    let photos: [Photo]?
    let placeID: String?
    let plusCode: PlusCode?
    let priceLevel: Int?
    let rating: Double?
    let reference: String?
    let scope: String?
    let types: [String]?
    let userRatingsTotal: Int?
    let vicinity: String?

    enum CodingKeys: String, CodingKey {
        case businessStatus = "business_status"
        case geometry, icon, name
        case openingHours = "opening_hours"
        case photos
        case placeID = "place_id"
        case plusCode = "plus_code"
        case priceLevel = "price_level"
        case rating, reference, scope, types
        case userRatingsTotal = "user_ratings_total"
        case vicinity
    }
}

// MARK: - Geometry
struct Geometry: Codable {
    var location: Location?
    let viewport: Viewport?
}

// MARK: - Location
struct Location: Codable {
    var lat, lng: Double?
}

// MARK: - Viewport
struct Viewport: Codable {
    let northeast, southwest: Location?
}

// MARK: - OpeningHours
struct OpeningHours: Codable {
    let openNow: Bool?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}

// MARK: - Photo
struct Photo: Codable {
    let height: Int?
    let photoReference: String?
    let width: Int?

    enum CodingKeys: String, CodingKey {
        case height
        case photoReference = "photo_reference"
        case width
    }
}

// MARK: - PlusCode
struct PlusCode: Codable {
    let compoundCode, globalCode: String?

    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
}
