import Foundation


struct Note: Codable {
    let id: String
    var title: String
    var content: String
    let createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        title:String,
        content:String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

}