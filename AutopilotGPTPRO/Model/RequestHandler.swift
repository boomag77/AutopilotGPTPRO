
//For Development and Testing:
//
//If you're encountering this issue during development, especially if you're working with a server that uses a self-signed certificate or a certificate from a non-trusted CA, you can temporarily disable ATS for specific domains or completely (not recommended) in your app's Info.plist.
//
//To disable ATS for specific domains, add the following keys to your Info.plist:
//
//xml
//Copy code
//<key>NSAppTransportSecurity</key>
//<dict>
//    <key>NSExceptionDomains</key>
//    <dict>
//        <key>autopilotgpt.pro</key>
//        <dict>
//            <!-- Allows HTTP connections -->
//            <key>NSExceptionAllowsInsecureHTTPLoads</key>
//            <true/>
//            <!-- Allows loading from this domain even if the certificate is invalid -->
//            <key>NSExceptionRequiresForwardSecrecy</key>
//            <false/>
//            <key>NSIncludesSubdomains</key>
//            <true/>
//        </dict>
//    </dict>
//</dict>
//This plist configuration allows insecure HTTP loads and disables Forward Secrecy requirement for the domain autopilotgpt.pro and its subdomains, which can be helpful if you're facing issues due to the certificate not supporting modern cipher suites.
//
//For Production:
//
//For a production environment, it's crucial to address the root cause of the SSL/TLS trust issue:
//
//Ensure the server uses a certificate from a trusted CA.
//Check the server's certificate chain for any missing intermediate certificates.
//Verify the certificate is not expired and matches the domain name of your server.
//Handling SSL Errors in Code (Development Only)
//As shown in your provided code snippet, you've implemented a method to bypass SSL certificate validation errors by accepting all certificates. This approach can resolve trust issues during development but introduces significant security risks and should never be used in production apps.
//
//Long-Term Solution
//The best long-term solution is to ensure your server's SSL configuration is correct and up-to-date. You can use tools like SSL Labs' SSL Test (https://www.ssllabs.com/ssltest/) to check your server's SSL configuration and certificate chain for any issues.
//
//Remember, bypassing SSL errors or disabling ATS should only be done temporarily during development and testing phases. Always aim to use valid, trusted certificates in your production environment to ensure the security and privacy of your application's data transmissions.


import UIKit

protocol RequestHandlerViewControllerProtocol: UIViewController {
    var connectionState: ConnectionState { get set }
    func processResponse(_ response: Result<[String: String], Error>)
}

actor RequestHandler {
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let serverURL = URL(string: "wss://autopilotgpt.pro:8765/start_chat")!
    
    var delegate = WebSocketDelegate()
    weak var viewController: RequestHandlerViewControllerProtocol? {
        didSet {
            print("viewController set as \(viewController)")
        }
    }
    
    deinit {
        print("Requester deinitialized")
    }
    
    func isWebSocketTaskRunning() -> Bool {
        return webSocketTask?.state == .running
    }
    
    func setViewController(_ viewController: UIViewController?) {
        self.viewController = viewController as? RequestHandlerViewControllerProtocol
    }
    
    func connect() {
        
        delegate.owner = self
        
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: OperationQueue())
        
        webSocketTask = session.webSocketTask(with: serverURL)
        
        webSocketTask?.resume()
        
        print("connecting to server")
        
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("Disconnected from server")
    }
    
    func sendRecordedAudioData(_ audioData: Data) async {
        
//        if webSocketTask?.state != .running {
//            connectToServer()
//        }
        
        let message = URLSessionWebSocketTask.Message.data(audioData)
        
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Failed to send audio data: \(error.localizedDescription)")
            } else {
                
                print("Audio data sent successfully")
            }
        }
    }
    
    func sendInstruction(_ text: String) {
        
        let jsonObject: [String: Any] = ["instruction_prompt": text, "user_id": 11]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to serialize JSON")
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(jsonString)
        
        webSocketTask?.send(message) { error in
            
            if let error = error {
                
                print("Failed to send instruction text as JSON: \(error.localizedDescription)")
            } else {
                print("Instruction text sent as JSON successfully")
            }
        }
        
    }
    
    func receiveTranscribedAudioMessage() {
        
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                
                Task { [weak self] in
                    guard let self = self else {return}
                    await self.viewController?.processResponse(.failure(error))
                }

            case .success(let message):
                switch message {
                case .string(let text):
                    let parser = JSONParser()
                    let response = parser.parseJSONString(text)
                    Task { [weak self] in
                        guard let self = self else {return}
                        await self.viewController?.processResponse(response)
                    }
                    

                case .data(let data):
                    let parser = JSONParser()
                    let response = parser.parseJSONData(data)
                    Task { [weak self] in
                        guard let self = self else {return}
                        await self.viewController?.processResponse(response)
                    }

                @unknown default:
                    let error = NSError(domain: "WebSocketErrorDomain", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Unknown message type received"])
                    Task { [weak self] in
                        guard let self = self else {return}
                        await self.viewController?.processResponse(.failure(error))
                    }
                }
                //self?.receiveTranscribedAudioMessage()
            }
        }
    }
    
//    func receiveJSONResponse(completion: @escaping (Result<[String: String], Error>) -> Void) {
//        webSocketTask?.receive { result in
//            Task {
//                switch result {
//                case .failure(let error):
//                    print("Failed to receive JSON message: \(error.localizedDescription)")
//                    completion(.failure(error))
//                    
//                case .success(let message):
//                    switch message {
//                    case .string(let jsonString):
//                        Task { [weak self] in
//                            await self?.parseJSONString(jsonString, completion: completion)
//                        }
//                        
//                    case .data(let jsonData):
//                        print("data")
//                        Task { [weak self] in
//                            await self?.parseJSONData(jsonData, completion: completion)
//                        }
//                    @unknown default:
//                        print("Unknown message type received")
//                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown message type received"])))
//                    }
//                    
//                    // Continuously receive messages by recursively calling this method
//                    //self?.receiveJSONResponse(completion: completion)
//                }
//            }
//            
//        }
//    }

}

//extension RequestHandler {
//    
//    // Parses a JSON string and completes with either the server's response or an error.
//    private func parseJSONString(_ jsonString: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
//        
//        if let data = jsonString.data(using: .utf8) {
//            parseJSONData(data, completion: completion)
//        } else {
//            let error = NSError(domain: "DataErrorDomain", code: 0,
//                                userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON string"])
//            completion(.failure(error))
//        }
//        
//    }
//
//    // Parses a JSON Data object and completes with either the server's response or an error.
//    private func parseJSONData(_ jsonData: Data, completion: @escaping (Result<[String: String], Error>) -> Void) {
//        do {
//            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//               let transcribed = json["transcribed"] as? String,
//               let response = json["response"] as? [String: Any],
//                let message = response["message"] as? String {
//                completion(.success(["transcribed": transcribed, "response": message]))
//            } else {
//                let error = NSError(domain: "DataErrorDomain", code: 0,
//                                    userInfo: [NSLocalizedDescriptionKey: "JSON does not contain 'transcribed' or 'response' keys"])
//                completion(.failure(error))
//            }
//        } catch {
//            completion(.failure(error))
//        }
//    }
//}

extension RequestHandler {
    
    func setConnectionState(_ state: ConnectionState) {
        self.viewController?.connectionState = state
    }
    
}

//extension RequestHandler {
//    
//    private func listenForMessages() async {
//        while let task = webSocketTask {
//            do {
//                let message = try await task.receive()
//                handleMessage(message)
//            } catch {
//                print("Error in receiving message: \(error)")
//                break  // Exit the loop and potentially handle the error or reconnect
//            }
//        }
//    }
//    
//    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
//        switch message {
//        case .string(let text):
//            parseJSONString(text, completion: <#T##(Result<[String : String], Error>) -> Void#>)
//        case .data(let data):
//            print("Received data: \(data)")
//            // Handle data message
//        @unknown default:
//            fatalError("Unknown message type received")
//        }
//    }
//    
//}
