import Foundation

//Chapter 26 - This is a free function, not a method inside an object. So, it can be used from anywhere in your code.
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

//Chapter 27 - This creates a new global constant, applicationDocumentsDirectory, containing the path to the app’s Documents directory.
let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()
