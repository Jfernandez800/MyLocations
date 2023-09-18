import Foundation

//Chapter 26 - This is a free function, not a method inside an object. So, it can be used from anywhere in your code.
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
