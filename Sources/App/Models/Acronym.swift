import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
  var id: Int?
  var short: String
  var long: String
  var userId: User.ID
  
  init(short: String, long: String, userId: User.ID) {
    self.short = short
    self.long = long
    self.userId = userId
  }
}

extension Acronym: PostgreSQLModel {}

extension Acronym: Content {}

extension Acronym: Parameter {}

extension Acronym {
  var user: Parent<Acronym, User> {
    return parent(\.userId)
  }
  
  var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
    return siblings()
  }
}

extension Acronym: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.reference(from: \.userId, to: \User.id)
    })
  }
}
