import Foundation

struct Game: Identifiable,Codable,Hashable {
    var id:UUID
    var name:String
    var bundle:String
    var version:String
    var minOS:String
    var arch:String
    var executable:String
    var folder:String
    var icon:String?
    var imported:Date
}
