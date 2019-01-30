import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
  var id: UUID?
  var token: String
  var userId: User.ID

  init(token: String, userId: User.ID) {
    self.token = token
    self.userId = userId
  }
}

extension Token: PostgreSQLUUIDModel {}

extension Token: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.reference(from: \.userId, to: \User.id)
    })
  }
}

extension Token: Content {}

extension Token {
  static func generate(for user: User) throws -> Token {
    let random = try CryptoRandom().generateData(count: 16)
    return try Token(token: random.base64EncodedString(), userId: user.requireID())
  }
}

extension Token: Authentication.Token {
  static let userIDKey: UserIDKey = \Token.userId
  typealias UserType = User
}

extension Token: BearerAuthenticatable {
  static var tokenKey: TokenKey = \Token.token
}
