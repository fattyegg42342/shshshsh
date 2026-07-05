import SwiftUI

struct GameDetail:View {
    @EnvironmentObject var store:GameStore
    @Environment(\.dismiss) var dismiss
    let game:Game
    @State var showLog=false
    var body:some View {
        NavigationStack {
            Form {
                HStack(spacing:18){GameIcon(game:game).frame(width:82,height:82);VStack(alignment:.leading){Text(game.name).font(.title2.bold());Text(game.bundle).foregroundStyle(.secondary)}}
                Section("App"){row("Version",game.version);row("Minimum iOS",game.minOS);row("Executable",game.executable);row("Architecture",game.arch)}
                Section("Runtime") {
                    Label("The IPA importer and validator work. The touchHLE iOS runtime is not linked yet.",systemImage:"hammer")
                    Button("Open runtime log"){store.log("Launch blocked for \(game.name): touchHLE iOS core is not linked");showLog=true}
                }
                Section {Button("Delete game",role:.destructive){store.remove(game);dismiss()}}
            }
            .navigationTitle("Game info")
            .toolbar{ToolbarItem(placement:.topBarTrailing){Button("Done"){dismiss()}}}
            .sheet(isPresented:$showLog){NavigationStack{LogView().toolbar{ToolbarItem(placement:.topBarTrailing){Button("Done"){showLog=false}}}}}
        }
    }
    func row(_ a:String,_ b:String)->some View{HStack{Text(a);Spacer();Text(b).foregroundStyle(.secondary).multilineTextAlignment(.trailing)}}
}
