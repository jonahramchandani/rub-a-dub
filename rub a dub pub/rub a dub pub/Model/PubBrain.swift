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
    
    func getImageURLs(imageFolder: String) async throws -> [String] {
        print("🔍 Starting getImageURLs for folder: \(imageFolder)")
        
        // Add "image-folder/" prefix to the folder path
        let prefixedImageFolder = "image-folder/" + imageFolder
        
        // 1. Check cache first for immediate return
        if let cachedURLs = imageURLCache[prefixedImageFolder] {
            print("📦 Using cached URLs for \(prefixedImageFolder)")
            return cachedURLs
        }
        
        // 2. Reuse existing in-flight request if one exists
        if let existingTask = pendingImageRequests[prefixedImageFolder] {
            print("⏳ Reusing existing request for \(prefixedImageFolder)")
            return try await existingTask.value
        }
        
        // 3. Create a new task with a timeout
        let task = Task<[String], Error> {
            print("🆕 Creating new request for \(prefixedImageFolder)")
            
            guard !prefixedImageFolder.isEmpty else {
                print("⚠️ Empty folder path provided")
                return getDefaultURLs()
            }
            
            let storageRef = storage.reference()
            
            // Clean the path by removing any gs:// prefix and storage bucket name
            var cleanPath = prefixedImageFolder
                .replacingOccurrences(of: "gs://\(storageRef.bucket)/", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Ensure the path doesn't start with a slash
            if cleanPath.hasPrefix("/") {
                cleanPath = String(cleanPath.dropFirst())
            }
            
            print("🧹 Cleaned path: \(cleanPath)")
            let folderRef = storageRef.child(cleanPath)
            
            do {
                // 4. Set a maximum number of images to load (limit to first 5 for quick loading)
                let result = try await folderRef.list(maxResults: 10)
                
                if result.items.isEmpty {
                    print("⚠️ No items found in folder")
                    let defaultURLs = getDefaultURLs()
                    imageURLCache[prefixedImageFolder] = defaultURLs
                    return defaultURLs
                }
                
                print("📊 Found \(result.items.count) items")
                
                // 5. Use async let to parallelize URL fetching
                var downloadURLs: [String] = []
                
                // Process only first 5 images max to keep loading time reasonable
                let itemsToProcess = result.items.prefix(10)
                
                // Create array of tasks
                let urlTasks = itemsToProcess.map { item in
                    Task<String?, Error> {
                        do {
                            let url = try await item.downloadURL()
                            print("✅ Got URL for \(item.name)")
                            return url.absoluteString
                        } catch {
                            print("⚠️ Failed to get URL for \(item.name): \(error.localizedDescription)")
                            return nil
                        }
                    }
                }
                
                // Await all tasks concurrently
                for task in urlTasks {
                    if let url = try await task.value {
                        downloadURLs.append(url)
                    }
                }
                
                if downloadURLs.isEmpty {
                    print("⚠️ Failed to load any image URLs")
                    let defaultURLs = getDefaultURLs()
                    imageURLCache[prefixedImageFolder] = defaultURLs
                    return defaultURLs
                }
                
                // Sort URLs for consistent order
                downloadURLs.sort()
                
                print("📦 Caching \(downloadURLs.count) URLs")
                imageURLCache[prefixedImageFolder] = downloadURLs
                return downloadURLs
                
            } catch {
                print("❌ Error loading folder contents: \(error.localizedDescription)")
                let defaultURLs = getDefaultURLs()
                imageURLCache[prefixedImageFolder] = defaultURLs
                return defaultURLs
            }
        }
        
        // Store the task
        pendingImageRequests[prefixedImageFolder] = task
        
        do {
            // 6. Add a timeout if task takes too long
            let timeoutTask = Task<[String], Error> {
                let start = Date()
                do {
                    let result = try await task.value
                    print("⏱️ Loading took \(Date().timeIntervalSince(start)) seconds")
                    return result
                } catch {
                    throw error
                }
            }
            
            let results = try await timeoutTask.value
            pendingImageRequests[prefixedImageFolder] = nil
            return results
        } catch {
            pendingImageRequests[prefixedImageFolder] = nil
            print("❌ Request failed or timed out: \(error.localizedDescription)")
            let defaultURLs = getDefaultURLs()
            imageURLCache[prefixedImageFolder] = defaultURLs
            return defaultURLs
        }
    }

    // Helper function to provide default URLs
    private func getDefaultURLs() -> [String] {
        return [
            "https://drive.google.com/uc?id=1JHQgVHLsx_QKpl-7u09qBF64uDKUEGJ9",
            "https://drive.google.com/uc?id=1iPoCxpdDbKd10b-3tBlP_KwCYWno20MZ",
            "https://drive.google.com/uc?id=17PuuRsQwssBMP_pKKiEDwy_l-vbBEeuL"
        ]
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
        let imageURLs = try await getImageURLs(imageFolder: imageFolder)
        
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
