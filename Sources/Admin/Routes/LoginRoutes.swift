import Vapor
import HTTP
import Routing

public struct LoginRoutes: RouteCollection {
    
    public typealias Wrapped = Responder
    
    let drop: Droplet
    
    public init(droplet: Droplet) {
        drop = droplet
    }
    
    public func build<Builder: RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        
        let controller = LoginController(droplet: drop)
        
        builder.get("/", handler: controller.form);
        builder.get("/admin", handler: controller.form);
        builder.post("/admin/login", handler: controller.submit);
        builder.get("/admin/logout", handler: controller.logout);
    }
}
