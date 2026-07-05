import Foundation
import ZIPFoundation

struct IPAImporter {
    static func importIPA(_ source:URL,to root:URL)throws->Game {
        let access=source.startAccessingSecurityScopedResource()
        defer {if access{source.stopAccessingSecurityScopedResource()}}
        let id=UUID()
        let folder=id.uuidString
        let out=root.appendingPathComponent(folder,isDirectory:true)
        try FileManager.default.createDirectory(at:out,withIntermediateDirectories:true)
        do {
            let ipa=out.appendingPathComponent("game.ipa")
            try FileManager.default.copyItem(at:source,to:ipa)
            guard let archive=Archive(url:ipa,accessMode:.read) else{throw ImportError.badZip}
            for entry in archive {
                let p=entry.path.replacingOccurrences(of:"\\",with:"/")
                let parts=p.split(separator:"/",omittingEmptySubsequences:false)
                if p.hasPrefix("/") || parts.contains("..") || entry.type == .symlink {throw ImportError.unsafeZip}
                let target=out.appendingPathComponent(p).standardizedFileURL.path
                if target != out.path && !target.hasPrefix(out.path+"/"){throw ImportError.unsafeZip}
            }
            let unpack=out.appendingPathComponent("app",isDirectory:true)
            try FileManager.default.createDirectory(at:unpack,withIntermediateDirectories:true)
            try FileManager.default.unzipItem(at:ipa,to:unpack)
            guard let app=findApp(unpack) else{throw ImportError.noApp}
            let plistURL=app.appendingPathComponent("Info.plist")
            guard let data=try? Data(contentsOf:plistURL),let plist=try PropertyListSerialization.propertyList(from:data,format:nil) as? [String:Any] else{throw ImportError.noPlist}
            let exe=(plist["CFBundleExecutable"] as? String) ?? ""
            if exe.isEmpty{throw ImportError.noExecutable}
            let exeURL=app.appendingPathComponent(exe)
            let result=try MachOInspector.inspect(exeURL)
            if !result.arm32{throw ImportError.not32Bit(result.arch)}
            if result.encrypted{throw ImportError.encrypted}
            let name=(plist["CFBundleDisplayName"] as? String) ?? (plist["CFBundleName"] as? String) ?? app.deletingPathExtension().lastPathComponent
            let bundle=(plist["CFBundleIdentifier"] as? String) ?? "unknown"
            let version=(plist["CFBundleShortVersionString"] as? String) ?? (plist["CFBundleVersion"] as? String) ?? "unknown"
            let minOS=(plist["MinimumOSVersion"] as? String) ?? "unknown"
            let icon=copyIcon(plist,app,out)
            return Game(id:id,name:name,bundle:bundle,version:version,minOS:minOS,arch:result.arch,executable:exe,folder:folder,icon:icon,imported:Date())
        } catch {
            try? FileManager.default.removeItem(at:out)
            throw error
        }
    }

    static func findApp(_ root:URL)->URL? {
        let payload=root.appendingPathComponent("Payload",isDirectory:true)
        let items=(try? FileManager.default.contentsOfDirectory(at:payload,includingPropertiesForKeys:nil)) ?? []
        return items.first{$0.pathExtension.lowercased()=="app"}
    }

    static func copyIcon(_ plist:[String:Any],_ app:URL,_ out:URL)->String? {
        var names:[String]=[]
        if let a=plist["CFBundleIconFiles"] as? [String]{names+=a}
        if let icons=plist["CFBundleIcons"] as? [String:Any],let primary=icons["CFBundlePrimaryIcon"] as? [String:Any],let a=primary["CFBundleIconFiles"] as? [String]{names+=a}
        let all=(try? FileManager.default.contentsOfDirectory(at:app,includingPropertiesForKeys:nil)) ?? []
        let candidates=all.filter{u in
            let n=u.deletingPathExtension().lastPathComponent
            return u.pathExtension.lowercased()=="png" && (names.isEmpty ? n.lowercased().contains("icon") : names.contains{n.hasPrefix($0)})
        }.sorted{$0.lastPathComponent.count>$1.lastPathComponent.count}
        guard let src=candidates.first else{return nil}
        let dst=out.appendingPathComponent("icon.png")
        try? FileManager.default.copyItem(at:src,to:dst)
        return dst.lastPathComponent
    }
}

enum ImportError:LocalizedError {
    case badZip,unsafeZip,noApp,noPlist,noExecutable,encrypted,not32Bit(String)
    var errorDescription:String? {
        switch self {
        case .badZip:return "This is not a readable IPA/ZIP."
        case .unsafeZip:return "The IPA contains an unsafe path or symlink."
        case .noApp:return "No Payload/*.app bundle was found."
        case .noPlist:return "The app has no readable Info.plist."
        case .noExecutable:return "Info.plist does not name an executable."
        case .encrypted:return "The executable is encrypted. Import a decrypted IPA with cryptid 0."
        case .not32Bit(let a):return "This is not a supported 32-bit ARM app. Detected: \(a)."
        }
    }
}
