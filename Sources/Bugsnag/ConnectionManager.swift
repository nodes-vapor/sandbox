import Vapor
import HTTP
import Foundation

public final class ConnectionMananger {
    
    let drop: Droplet
    let config: Configuration
    
    public init(drop: Droplet, config: Configuration) {
        self.drop = drop
        self.config = config
    }
    
    func headers() -> [HeaderKey: String] {
        
        let headers = [
            HeaderKey("Content-Type"): "application/json",
        ]
        
        return headers
    }
    
    func body(message: String, request: Request) throws -> JSON {
        var stacktraceList: [Node] = []
        
        for entry in Thread.callStackSymbols {
            stacktraceList.append(Node([
                "file": Node(entry),
                "lineNumber": 0,
                "columnNumber": 0,
                "method": Node(entry),
                "code": Node([
                    "1": Node(entry)
                ])
            ]))
        }
        
        let stacktrace = Node(stacktraceList)
   
        let app: Node = Node([
            "releaseStage": Node(drop.environment.description),
            "type": "Vapor"
        ])
        
        var headers: [String: Node] = [:]
        for (key, value) in request.headers {
            headers[key.key] = Node(value)
        }
        
        let metaData = Node([
            "request": Node([
                "method": Node(request.method.description),
                "headers": Node(headers),
                "params": request.parameters,
                "url": Node(request.uri.path)
            ])
        ])
        
        
        let event: Node = Node([
            Node([
                "payloadVersion": 2,
                "exceptions": Node([
                    Node([
                        "errorClass": Node(message),
                        "message": Node(message),
                        "stacktrace": stacktrace
                    ])
                ]),
                "app": app,
                "severity": "error",
                "metaData": metaData
            ])
        ])
    
        return try JSON(node: [
            "apiKey": self.config.apiKey,
            "notifier": Node([
                    "name": "Bugsnag Vapor",
                    "version": "1.0.11",
                    "url": "https://github.com/nodes-vapor/bugsnag"
            ]),
            "events": event,
        ])
    }
    
    func post(json: JSON) throws -> Status {
        let response = try drop.client.post(self.config.endpoint, headers: headers(), body: json.makeBody())
        
        return response.status
    }
    
    func post(status: Status, message: String, request: Request) throws -> Status {
        return try post(json: body(message: message, request: request))
    }
    
}
