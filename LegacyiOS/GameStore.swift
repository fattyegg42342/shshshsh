import Foundation
import Combine
import ZIPFoundation

@MainActor
final class GameStore:ObservableObject {
    @Published var games:[Game]=[]
    @Published var logs:[String]=[]
    @Published var busy=false
    @Published var error:String?
    let fm=FileManager.default

    init(){load()}

    var base:URL {
        let p=fm.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("LegacyiOS",isDirectory:true)
        try? fm.createDirectory(at:p,withIntermediateDirectories:true)
        return p
    }
    var gamesDir:URL {
        let p=base.appendingPathComponent("Games",isDirectory:true)
        try? fm.createDirectory(at:p,withIntermediateDirectories:true)
        return p
    }
    var libraryURL:URL { base.appendingPathComponent("library.json") }

    func load(){
        guard let d=try? Data(contentsOf:libraryURL),let v=try? JSONDecoder().decode([Game].self,from:d) else{return}
        games=v
    }
    func save(){
        guard let d=try? JSONEncoder().encode(games) else{return}
        try? d.write(to:libraryURL,options:.atomic)
    }
    func log(_ s:String){
        logs.append("\(Date().formatted(date:.omitted,time:.standard))  \(s)")
    }
    func remove(_ g:Game){
        try? fm.removeItem(at:gamesDir.appendingPathComponent(g.folder))
        games.removeAll{$0.id==g.id}
        save()
        log("Removed \(g.name)")
    }
    func importIPA(_ url:URL){
        busy=true
        error=nil
        let dir=gamesDir
        Task {
            do {
                let g=try await Task.detached(priority:.userInitiated){try IPAImporter.importIPA(url,to:dir)}.value
                games.append(g)
               games.sort{$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending}
                save()
                log("Imported \(g.name) [\(g.arch)]")
            } catch {
                self.error=error.localizedDescription
                log("Import failed: \(error.localizedDescription)")
            }
            busy=false
        }
    }
    func path(_ g:Game)->URL { gamesDir.appendingPathComponent(g.folder) }
}
