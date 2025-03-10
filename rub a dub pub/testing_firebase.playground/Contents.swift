import PlaygroundSupport
import FirebaseStorage
import FirebaseCore
import Firebase
import UIKit

// Make sure playground execution continues until async operations complete
PlaygroundPage.current.needsIndefiniteExecution = true

// Initialize Firebase (assuming you have GoogleService-Info.plist in the playground resources)
FirebaseApp.configure()

let storage = Storage.storage()
let storageRef = storage.reference()

func downloadImage() {
    let imageRef = storageRef.child("image-folder/pub-on-the-park/1.JPG")
    print(imageRef.fullPath)
    print("imageRef bucket: \(imageRef.bucket)")
    imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading: \(error)")
            return
        }
        
        if let imageData = data,
           let image = UIImage(data: imageData) {
            print("Image downloaded successfully")
            PlaygroundPage.current.finishExecution() // Stop playground when done
        }
    }
}

downloadImage()
