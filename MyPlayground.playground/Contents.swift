import PlaygroundSupport
import FirebaseStorage
import FirebaseCore
import UIKit

print("Greetings, world!")

// Configure Firebase
let options = FirebaseOptions(
    googleAppID: "1:516434038703:ios:7ccbcfd370b49b88ae295a",
    gcmSenderID: "516434038703"
)
options.storageBucket = "rub-a-dub-ios.appspot.com"
FirebaseApp.configure(options: options)

// Get storage reference
let storage = Storage.storage()
let storageRef = storage.reference()


// Example: Download an image
func downloadImage() {
    let imageRef = storageRef.child("image-folder/pub-on-the-park/1.JPG")
    
    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading: \(error)")
            return
        }
        
        if let imageData = data,
           let image = UIImage(data: imageData) {
            print("Image downloaded successfully")
        }
    }
    
}

downloadImage()
