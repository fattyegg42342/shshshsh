import SwiftUI

struct LogView:View {
    @EnvironmentObject var store:GameStore
    var body:some View {
        NavigationStack {
            ScrollView {
                Text(store.logs.isEmpty ? "No log entries yet.":store.logs.joined(separator:"\n"))
                    .font(.system(.caption,design:.monospaced)).frame(maxWidth:.infinity,alignment:.leading).padding()
            }.navigationTitle("Logs").toolbar{ToolbarItem(placement:.topBarTrailing){Button("Clear"){store.logs=[]}}}
        }
    }
}
