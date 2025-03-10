//
//  PubBrain.swift
//  rub a dub pub
//
//  Created by Jonah Ramchandani on 30/01/2024.
//

import UIKit
import Firebase
import FirebaseStorage

var timeBrain = TimeBrain()

class PubBrain {
    let storage = Storage.storage()
    private var imageURLCache: [String: [String]] = [:]
    private var pendingImageRequests: [String: Task<[String], Error>] = [:]
    
    func getImageURLs(imageFolder: String) -> [String] {
        print("🔍 Starting getImageURLs for folder: \(imageFolder)")
        if let cachedURLs = imageURLCache[imageFolder] {
                    print("📦 Returning cached URLs for \(imageFolder)")
                    return cachedURLs
                }
        
        let storageRef = storage.reference()
        print("🪣 Storage bucket: \(storageRef.bucket)")
        // Clean the path by removing any gs:// prefix and storage bucket name
        var cleanPath = imageFolder
            .replacingOccurrences(of: "gs://\(storageRef.bucket)/", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Ensure the path doesn't start with a slash
        if cleanPath.hasPrefix("/") {
            cleanPath = String(cleanPath.dropFirst())
        }

        print("🧹 Cleaned path: \(cleanPath)")
        return [" "]
    }

//        
//        // Synchronized access to pending requests
//        if let existingTask = pendingImageRequests[imageFolder] {
//            print("⏳ Reusing existing request for \(imageFolder)")
//            return try await existingTask.value
//        }
//        
//        let task = Task<[String], Error> {
//            print("🆕 Creating new task for \(imageFolder)")
//            
//            guard !imageFolder.isEmpty else {
//                return []
//            }
//
//        
//            

//            
//            // Get and verify the complete storage reference
//            let folderRef = storageRef.child(cleanPath)
//            print("📂 Complete storage path verification:")
//            print("  - Bucket: \(folderRef.bucket)")
//            print("  - Full path: \(folderRef.fullPath)")
//            print("  - Name: \(folderRef.name)")
//            print("  - Parent path: \(folderRef.parent()?.fullPath ?? "none")")
//            print("  - Root reference: \(storageRef.root().fullPath)")
//            
//            do {
//                // First, verify the folder exists
//                let folderRef = storageRef.child(cleanPath)
//                print("📂 Attempting to list contents of: \(folderRef.fullPath)")
//                
//                let result = try await folderRef.listAll()
//                
//                if result.items.isEmpty {
//                    print("⚠️ No items found in folder")
//                    let defaultURLs = [
//                        "https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9",
//                        "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ",
//                        "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"
//                    ]
//                    imageURLCache[imageFolder] = defaultURLs
//                    return defaultURLs
//                }
//                
//                print("📊 Found \(result.items.count) items")
//                
//                var downloadURLs: [String] = []
//                for item in result.items {
//                    do {
//                        let url = try await item.downloadURL()
//                        downloadURLs.append(url.absoluteString)
//                        print("✅ Got URL for \(item.name)")
//                    } catch {
//                        print("⚠️ Failed to get URL for \(item.name): \(error.localizedDescription)")
//                        continue
//                    }
//                }
//                
//                // Sort URLs to ensure consistent order
//                downloadURLs.sort()
//                
//                if !downloadURLs.isEmpty {
//                    print("📦 Caching \(downloadURLs.count) URLs")
//                    imageURLCache[imageFolder] = downloadURLs
//                    return downloadURLs
//                } else {
//                    let defaultURLs = [
//                        "https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9",
//                        "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ",
//                        "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"
//                    ]
//                    imageURLCache[imageFolder] = defaultURLs
//                    return defaultURLs
//                }
//                
//            } catch let error as StorageErrorCode {
//                print("❌ Firebase Storage error: \(error.localizedDescription)")
//                // Return default URLs for any storage error
//                let defaultURLs = [
//                    "https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9",
//                    "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ",
//                    "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"
//                ]
//                imageURLCache[imageFolder] = defaultURLs
//                return defaultURLs
//            } catch {
//                print("❌ Unexpected error: \(error.localizedDescription)")
//                throw error
//            }
//        }
//        
//        // Store the task
//        pendingImageRequests[imageFolder] = task
//        
//        do {
//            let results = try await task.value
//            pendingImageRequests[imageFolder] = nil
//            return results
//        } catch {
//            pendingImageRequests[imageFolder] = nil
//            throw error
//        }
//    }
    
    func getImageURL(path: String) async throws -> [String] {
        print("🔍 Starting getImageURL for path: \(path)")
        
        let storageRef = storage.reference(withPath: path)
        
        // Log storage reference details
        print("📂 Storage reference details:")
        print("  - Bucket: \(storageRef.bucket)")
        print("  - Full path: \(storageRef.fullPath)")
        print("  - Name: \(storageRef.name)")
        
        do {
            let downloadURL = try await storageRef.downloadURL()
            print("✅ Successfully got URL for \(storageRef.name)")
            return [downloadURL.absoluteString]  // Return as single-element array
            
        } catch let error as StorageErrorCode {
            print("❌ Firebase Storage error: \(error.localizedDescription)")
            // Return default URLs array in case of error
            return ["https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9"]
            
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func findPubID(pubArray: [Pub], pubID: Int) -> Pub? {
        for p in pubArray {
            if p.id == pubID {
                return p
            }
        }
        return nil

    }
    
    func pubConverter(pubData: [String: Any], id: Int) async throws -> Pub {
        
        let openingDict = pubData["openingTimes"] as! [String: Float]
        let openingTimes: [Float] = [openingDict["sun"]!, openingDict["mon"]!, openingDict["tue"]!, openingDict["wed"]!, openingDict["thu"]!, openingDict["fri"]!, openingDict["sat"]!]
        
        let closingDict = pubData["closingTimes"] as! [String: Float]
        let closingTimes: [Float] = [closingDict["sun"]!, closingDict["mon"]!, closingDict["tue"]!, closingDict["wed"]!, closingDict["thu"]!, closingDict["fri"]!, closingDict["sat"]!]
        
        let happyDict = pubData["happyHour"] as! [String: Bool]
        let happyHours: [Bool] = [happyDict["sun"]!, happyDict["mon"]!, happyDict["tue"]!, happyDict["wed"]!, happyDict["thu"]!, happyDict["fri"]!, happyDict["sat"]!]
        
        let calendarDict = pubData["whatsOn"] as! [String: String]
        var calendar: [String] = [calendarDict["sun"]!, calendarDict["mon"]!, calendarDict["tue"]!, calendarDict["wed"]!, calendarDict["thu"]!, calendarDict["fri"]!, calendarDict["sat"]!]
        for (index, item) in calendar.enumerated() {
            if item.isEmpty {
                calendar[index] = "Nothing on today"
            }
        }
        
        let imageFolder = pubData["imageFolder"] as? String ?? ""
//        let imageURLs = try await getImageURLs(imageFolder: imageFolder)
        let imageURLs = try await getImageURL(path: "/image-folder/pub-on-the-park/1.JPG")
        
        let newPub: Pub = Pub(id: id,
                              name: pubData["pubName"] as! String, 
                              address: pubData["address"] as! String,
                              openingTimes: openingTimes,
                              closingTimes: closingTimes, 
                              phone: pubData["phoneNumber"] as! String, 
                              website: pubData["websiteURL"] as! String,
                              garden: pubData["garden"] as! Bool, 
                              food: pubData["food"] as! Bool,
                              roast: pubData["roast"] as! Bool,
                              pool: pubData["pool"] as! Bool,
                              darts: pubData["darts"] as! Bool,
                              sports: pubData["sports"] as! Bool,
                              beer: pubData["beer"] as! Bool,
                              quiz: weekdayDictionary[pubData["quiz"] as! String] as? Int,
                              cheap: pubData["cheap"] as! Bool,
                              slots: pubData["slots"] as! Bool,
                              fire: pubData["cosy"] as! Bool,
                              games: pubData["games"] as! Bool,
                              karaoke: pubData["karaoke"] as! Bool,
                              liveMusic: pubData["live"] as! Bool,
                              dogs: pubData["dogs"] as! Bool,
                              jukeBox: pubData["jukebox"] as! Bool,
                              privateFunctions: pubData["functions"] as! Bool,
                              happyHour: happyHours,
                              calendar: calendar,
                              openNow: timeBrain.checkOpenBool(openingTimes: openingTimes, closingTimes: closingTimes),
                              long: pubData["longitude"] as! Double,
                              lat: pubData["latitude"] as! Double,
                              images: imageURLs,
                              desc: pubData["longDesc"] as! String)
        
        return newPub

    }
    
    static var pubs: [Pub] = [
        
        Pub(id: 0,
            name: "The Crown",
            address: "10 Dispensary Lane, E8 1FT",
            openingTimes: [12, 3, 3, 3, 3, 12, 12],
            closingTimes: [23, 23, 23, 23, 23, 23, 23],
            phone: "07805403126",
            website: "google.com",
            garden: true,
            food: false,
            roast: false,
            pool: true,
            darts: true,
            sports: true,
            beer: true,
            quiz: nil,
            cheap: false,
            slots: true,
            fire: false,
            games: false,
            karaoke: true,
            liveMusic: false,
            dogs: true,
            jukeBox: false,
            privateFunctions: false,
            happyHour: [false, false, false, false, true, true, false],
            calendar: ["None", "None", "Quiz night, Life drawing", "Comedy night", "2 for £12 cocktails", "Late night DJ", "Late night DJ"],
            openNow: timeBrain.checkOpenBool(openingTimes: [12, 3, 3, 3, 3, 12, 12], closingTimes: [23, 23, 23, 23, 23, 23, 23]),
            long: -0.05455774699172663,
            lat: 51.54967370352562, distance: nil,
            images: ["https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9", "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ", "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"],
            desc: "The Crown is a local boozer with plenty of sports playing, a roofed garden, a pool table and reasonably priced pints. The toilets smell like the customers and the customers smell like the toilets. A real institution if you ask me."
           ),
        
        Pub(id: 1,
            name: "The Chesham Arms",
            address: "10 Dispensary Lane, E8 1FT",
            openingTimes: [12, 3, 3, 3, 3, 12, 12],
            closingTimes: [22, 23, 23, 23, 23, 23, 23],
            phone: "07805403126",
            website: "google.com",
            garden: true,
            food: true,
            roast: true,
            pool: false,
            darts: false,
            sports: false,
            beer: false,
            quiz: nil,
            cheap: false,
            slots: false,
            fire: true,
            games: false,
            karaoke: false,
            liveMusic: false,
            dogs: true,
            jukeBox: false,
            privateFunctions: false,
            happyHour: [false, false, false, false, true, true, false],
            calendar: ["None", "None", "Quiz night, Life drawing", "Comedy night", "None", "Late night DJ", "Late night DJ"],
            openNow: timeBrain.checkOpenBool(openingTimes: [12, 3, 3, 3, 3, 12, 12], closingTimes: [22, 23, 23, 23, 23, 23, 23]),
            long: -0.0500729846566192,
            lat: 51.54822120866921, distance: nil,
            images: ["https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9", "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ", "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"],
            desc: "The Chesham Arms is a trendy pub, hidden away in a residential area with a homely back garden and good food to go with it."
           ),
        
        Pub(id: 2,
            name: "The Star By Hackney Downs",
            address: "10 Dispensary Lane, E8 1FT",
            openingTimes: [12, 3, 3, 3, 3, 12, 12],
            closingTimes: [23, 23, 23, 23, 23, 25, 25],
            phone: "07805403126",
            website: "google.com",
            garden: true,
            food: true,
            roast: true,
            pool: false,
            darts: false,
            sports: true,
            beer: false,
            quiz: 2,
            cheap: false,
            slots: false,
            fire: false,
            games: false,
            karaoke: true,
            liveMusic: false,
            dogs: true,
            jukeBox: false,
            privateFunctions: false,
            happyHour: [false, false, false, false, true, true, false],
            calendar: ["None", "None", "Quiz night, Life drawing", "Comedy night", "None", "None", "Late night DJ"],
            openNow: timeBrain.checkOpenBool(openingTimes: [12, 3, 3, 3, 3, 12, 12], closingTimes: [23, 23, 23, 23, 23, 25, 25]),
            long: -0.057766531648115266,
            lat: 51.5532267509596, distance: nil,
            images: ["https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9", "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ", "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"],
            desc: "The Star is a lovely, park adjacent pub with a sunny front garden, friendly staff, an upstairs area hosting drawing classes and comedy nights, 2 for £12 cocktails on Thursday and a private karaoke room for the musically inclined."
           ),
        
        Pub(id: 3,
            name: "The Pembury Tavern",
            address: "10 Dispensary Lane, E8 1FT",
            openingTimes: [12, 3, 3, 3, 3, 12, 12],
            closingTimes: [23, 23, 23, 23, 24, 24, 24],
            phone: "07805403126",
            website: "google.com",
            garden: false,
            food: true,
            roast: false,
            pool: false,
            darts: true,
            sports: true,
            beer: false,
            quiz: nil,
            cheap: false,
            slots: true,
            fire: false,
            games: false,
            karaoke: false,
            liveMusic: false,
            dogs: true,
            jukeBox: false,
            privateFunctions: false,
            happyHour: [false, false, false, false, true, true, false],
            calendar: ["None", "None", "Quiz night, Life drawing", "Comedy night", "2 for £12 cocktails", "Late night DJ", "None"],
            openNow: timeBrain.checkOpenBool(openingTimes: [12, 3, 3, 3, 3, 12, 12], closingTimes: [23, 23, 23, 23, 24, 24, 24]),
            long: -0.059225464403259286,
            lat: 51.54952268149752, distance: nil,  
            images: ["https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9", "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ", "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"],
            desc: "Boozer I don't really care about, feel like it has serious main character syndrome sitting in the middle of a five road junction, everyone in Hackney seems to talk about but seems a bit like of Fox on the Green to me"
           ),
        
        Pub(id: 4, name: "The Cock Tavern", 
            address: "10 Dispensary Lane, E8 1FT",
            openingTimes: [12, 3, 3, 3, 3, 12, 12],
            closingTimes: [22.5, 23, 23, 23, 23, 25, 25],
            phone: "07805403126",
            website: "google.com", 
            garden: false,
            food: false,
            roast: false,
            pool: false,
            darts: false,
            sports: false,
            beer: false,
            quiz: 1,
            cheap: false,
            slots: false,
            fire: false,
            games: false,
            karaoke: false,
            liveMusic: false,
            dogs: true,
            jukeBox: false,
            privateFunctions: false,
            happyHour: [false, false, false, false, true, true, false],
            calendar: ["None", "None", "Quiz night, Life drawing", "Comedy night", "2 for £12 cocktails", "Late night DJ", "Late night DJ"],
            openNow: timeBrain.checkOpenBool(openingTimes: [12, 3, 3, 3, 3, 12, 12], closingTimes: [22.5, 23, 23, 23, 23, 25, 25]),
            long: -0.05534290590488441,
            lat: 51.54635098133681,
            distance: nil,
            images: ["https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9", "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ", "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"],
            desc: "If you actually like the taste of beer, this is the rub-a-dub for you. A billion taps behind the bar, but not a Peroni in sight."
           ),
        
        Pub(id: 5, 
            name: "Baxter's Court",
            address: "10 Dispensary Lane, E8 1FT",
            openingTimes: [12, 3, 3, 3, 3, 12, 12],
            closingTimes: [24, 24, 24, 24, 24, 25, 25],
            phone: "07805403126",
            website: "google.com", 
            garden: false,
            food: true,
            roast: false,
            pool: false,
            darts: false,
            sports: false,
            beer: false,
            quiz: nil,
            cheap: true,
            slots: true,
            fire: false,
            games: false,
            karaoke: false,
            liveMusic: false,
            dogs: true,
            jukeBox: false,
            privateFunctions: false,
            happyHour: [false, false, false, false, true, true, false],
            calendar: ["None", "None", "Quiz night, Life drawing", "Comedy night", "2 for £12 cocktails", "Late night DJ", "Late night DJ"],
            openNow: timeBrain.checkOpenBool(openingTimes: [12, 3, 3, 3, 3, 12, 12], closingTimes: [24, 24, 24, 24, 24, 25, 25]),
            long: -0.0550761049221273,
            lat: 51.545364324085895,
            distance: nil,
            images: ["https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9", "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ", "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"],
            desc: "So, you've made it this far. Let's face it, what else could you have expected clicking the cheap filter. But let's be honest, it does what it says on the tin. So well done, you truly, truly value the institution of a cheap London pint - nothing to be sniffed at, and perhaps something that deserves a bit more of a sniffing from time to time. You might even say we could all do with a bit less spoons-snobbery running through our veins."
           )
    ]
    
    
// MARK: -
// MARK: -
// MARK: - filteredPubs is just a duplicated version of pubs
    
    static var filteredPubs: [Pub] = pubs
    static var favouritePubs: [Pub] = []
    static var favouriteIDs: [Int] = []
    let weekdayDictionary: [String: Int?] = ["Sunday": 0, "Monday": 1, "Tuesday": 2, "Wednesday": 3, "Thursday": 4, "Friday": 5, "Saturday": 6, "None": nil]
}
