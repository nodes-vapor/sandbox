import Vapor
import Fluent
import Foundation
import HTTP

final class NMetaMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        
        // Check if it should be
        
        let headerStr = drop.config["nmeta", "header"]?.string ?? "N-Meta"
        
        guard let nMeta = request.headers[HeaderKey(headerStr)]?.string else {
            throw Abort.custom(status: .badRequest, message: "Missing N-Meta header")
        }
        
        try NMeta.setInstance(nMeta: nMeta);
        
        try print(NMeta.getInstance().toNode())
        
        return response
    }
}
