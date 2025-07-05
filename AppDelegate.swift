import UIKit
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    let handled = GIDSignIn.sharedInstance.handle(url)
    if handled {
      return true
    }
    return false
  }
}
