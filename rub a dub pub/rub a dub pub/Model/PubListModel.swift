//
//  PubListMode.swift
//  rub a dub pub
//
//  Created by Jonah Ramchandani on 30/01/2024.
//

import UIKit

struct Pub {
    let id: Int
    let name: String
    let address: String
    let openingTimes: [Float]
    let closingTimes: [Float]
    let phone: String
    let website: String
    let garden: Bool
    let food: Bool
    let roast: Bool
    let pool: Bool
    let darts: Bool
    let sports: Bool
    let beer: Bool
    var quiz: Int?
    let cheap: Bool
    let slots: Bool
    let fire: Bool
    let games: Bool
    let karaoke: Bool
    let liveMusic: Bool
    let dogs: Bool
    let jukeBox: Bool
    let privateFunctions: Bool
    let happyHour: [Bool]
    let calendar: [String]
    var openNow: Bool
    let long: Double
    let lat: Double
    var distance: Double?
    let images: [String]
    let desc: String
}
