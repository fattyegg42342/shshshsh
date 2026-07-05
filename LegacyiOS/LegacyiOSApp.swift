import SwiftUI

@main
struct LegacyiOSApp: App {
    @StateObject var store=GameStore()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(store)
        }
    }
}
