import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ContentView:View {
    @EnvironmentObject var store:GameStore
    @State var importer=false
    @State var selected:Game?
    var ipaType:UTType { UTType(filenameExtension:"ipa") ?? .archive }

    var body:some View {
        TabView {
            NavigationStack {
                Group {
                    if store.games.isEmpty {
                        ContentUnavailableView("No games",systemImage:"iphone.gen2",description:Text("Import a decrypted 32-bit IPA to inspect it."))
                    } else {
                        List {
                            ForEach(store.games){g in
                                Button(action:{selected=g}){GameRow(game:g)}.buttonStyle(.plain)
                            }.onDelete{set in set.map{store.games[$0]}.forEach(store.remove)}
                        }
                    }
                }
                .navigationTitle("LegacyiOS")
                .toolbar {ToolbarItem(placement:.topBarTrailing){Button(action:{importer=true}){Image(systemName:"plus")}.disabled(store.busy)}}
            }
            .tabItem{Label("Library",systemImage:"square.grid.2x2")}
            LogView().tabItem{Label("Logs",systemImage:"text.alignleft")}
        }
        .overlay {if store.busy{ProgressView("Importing IPA…").padding(24).background(.regularMaterial,in:RoundedRectangle(cornerRadius:18))}}
        .fileImporter(isPresented:$importer,allowedContentTypes:[ipaType],allowsMultipleSelection:false){r in
            if case .success(let urls)=r,let u=urls.first{store.importIPA(u)}
            if case .failure(let e)=r{store.error=e.localizedDescription}
        }
        .sheet(item:$selected){GameDetail(game:$0)}
        .alert("Import failed",isPresented:Binding(get:{store.error != nil},set:{if !$0{store.error=nil}})){Button("OK"){store.error=nil}} message:{Text(store.error ?? "Unknown error")}
    }
}

struct GameRow:View {
    @EnvironmentObject var store:GameStore
    let game:Game
    var body:some View {
        HStack(spacing:14){
            GameIcon(game:game).frame(width:58,height:58)
            VStack(alignment:.leading,spacing:4){
                Text(game.name).font(.headline)
                Text("\(game.version)  •  \(game.arch)").font(.subheadline).foregroundStyle(.secondary)
                Text(game.bundle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }.padding(.vertical,4)
    }
}

struct GameIcon:View {
    @EnvironmentObject var store:GameStore
    let game:Game
    var body:some View {
        if let icon=game.icon,let image=UIImage(contentsOfFile:store.path(game).appendingPathComponent(icon).path){Image(uiImage:image).resizable().scaledToFill().clipShape(RoundedRectangle(cornerRadius:13))}
        else{RoundedRectangle(cornerRadius:13).fill(.quaternary).overlay{Image(systemName:"gamecontroller.fill").font(.title2)}}
    }
}
