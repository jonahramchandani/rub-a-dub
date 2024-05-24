//
//  FilterBrain.swift
//  rub a dub pub
//
//  Created by Jonah Ramchandani on 30/01/2024.
//

import Foundation

class FilterBrain {
    
    static var filterDictionary: [String: (Pub) -> Bool] = [:]
    static var filterArray: [String] = []
    
    static var brain: [String: Bool] = [
        "garden" : false,
        "food" : false,
        "open" : false,
        "roast" : false,
        "quiz" : false,
        "sports" : false,
        "cheap" : false,
        "beer" : false,
        "pool" : false,
        "darts" : false,
        "slots" : false,
        "calendar" : false,
        "fire" : false,
        "karaoke" : false,
        "games" : false,
        "live" : false,
        "dog" : false,
        "juke" : false,
        "function" : false,
        "happy" : false
    ]
    
    static var images: [String: [String]] = [
        "garden" : ["GV", "GVP"],
        "food" : ["GG", "GGP"],
        "open" : ["SO", "SOP"],
        "roast" : ["Roast", "Roast P"],
        "quiz" : ["Quiz", "Quiz P"],
        "sports" : ["Sports", "Sports P"],
        "cheap" : ["Cheap", "Cheap P"],
        "beer" : ["BeerL", "BeerL P"],
        "pool" : ["POOL", "POOL P"],
        "darts" : ["DARTS", "DARTS P"],
        "slots" : ["SLOTS", "SLOTS P"],
        "calendar" : ["Calendar", "Calendar P"],
        "fire" : ["FIRE", "FIRE P"],
        "karaoke" : ["KARAOKE", "KARAOKE P"],
        "games" : ["GAMES", "GAMES P"],
        "live" : ["Live", "Live P"],
        "dog" : ["Dog", "Dog P"],
        "juke" : ["Juke", "Juke P"],
        "function" : ["Function", "Function P"],
        "happy" : ["Happy", "Happy P"]
    ]
    
    static var copyDictionary: [String: (Pub) -> Bool] = [
        "garden" : { $0.garden },
        "food" : { $0.food },
        "open" : { $0.openNow },
        "roast" : { $0.roast },
        "sports" : { $0.sports },
        "cheap" : { $0.cheap },
        "beer" : { $0.beer },
        "pool" : { $0.pool },
        "darts" : { $0.darts },
        "slots" : { $0.slots },
        "fire" : { $0.fire },
        "karaoke" : { $0.karaoke },
        "games" : { $0.games },
        "live" : { $0.liveMusic },
        "dog" : { $0.roast },
        "juke" : { $0.jukeBox },
        "function" : { $0.privateFunctions },
    ]
    
    static var quiz: Int?
    static var closing: Float?
    static var closingString: String?
    static var weekdayIndex: Int?
    
}
