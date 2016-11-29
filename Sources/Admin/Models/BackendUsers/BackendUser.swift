import Vapor
import Fluent
import Foundation
import HTTP
import Hash

public final class BackendUser: Model {
    /**
     Turn the convertible into a node
     
     - throws: if convertible can not create a Node
     - returns: a node if possible
     */
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email.value,
            "password": password,
            "role": role,
            "created_at": createdAt,
            "updated_at": updatedAt
            ])
    }

    
    public static var entity = "backend_users"
    
    public var id: Node?
    public var name: String?
    public var email: Valid<Email>
    public var password: String?
    public var role: String?
    public var createdAt: Int?
    public var updatedAt: Int?
    
    public init(node: Node, in context: Context) throws {
        id = try? node.extract("id")
        name = try? node.extract("name")
        email = try "test@nodes.dk".validated()
        //email = try node.extract("email").validated()
        
        //email = try node.extract("email")
        password = try? node.extract("password")
        role = try? node.extract("role")
        createdAt = try? node.extract("created_at")
        updatedAt = try? node.extract("updated_at")
    }
    
    public init(request: Request) throws {
        let unhashedPassword = request.data["password"]?.string ?? "";
        
        name = request.data["name"]?.string ?? ""
        email = try request.data["email"].validated()
        //password = unhashedPassword != "" ? try hash.
        role = request.data["role"]?.string ?? "user"
        createdAt = request.data["created_at"]?.int ?? 0
        updatedAt = request.data["updated_at"]?.int ?? 0
    }
    
    public static func prepare(_ database: Database) throws {
        try database.create("backend_users") { table in
            table.id()
            table.string("name");
            table.string("email");
            table.string("password");
            table.string("role");
            table.string("created_at", optional: true)
            table.string("updated_at", optional: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("backend_users")
    }
}