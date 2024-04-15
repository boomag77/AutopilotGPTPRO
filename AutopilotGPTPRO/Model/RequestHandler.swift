
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


import Foundation

actor RequestHandler {
    
    //static let shared = RequestHandler()
    
    
    private var webSocketTask: URLSessionWebSocketTask?
    //private var textWebSocketTask: URLSessionWebSocketTask?
    
    private let serverURL = URL(string: "wss://autopilotgpt.pro:8765/start_chat")!
    //private let textServerURL = URL(string: "wss://autopilotgpt.pro:8704/start_chat")!
    
//    override init() {
//        super.init()
//    }
    private let delegate = WebSocketDelegate()
    
    deinit {
        print("Requester deinitialized")
    }
    
    static func createAndConnect() async -> RequestHandler {
        let requester = RequestHandler()
        await requester.connectToServer()
        return requester
    }
    
    func connectToServer() async {
        
        delegate.owner = self
        
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: OperationQueue())
        
        webSocketTask = session.webSocketTask(with: serverURL)
        
        webSocketTask?.resume()
        print("connecting to server")
        
    }
    
    func disconnectFromServer() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("Disconnected from server")
    }
    
    func sendRecordedAudioData(_ audioData: Data) async {
        
//        if webSocketTask?.state != .running {
//            connectToServer()
//        } else {
//            print("*** Audio socket connected ***")
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
    
    func receiveTranscribedAudioMessage(completion: @escaping (Result<[String: String], Error>) -> Void) {
        webSocketTask?.receive { result in
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error.localizedDescription)")
                completion(.failure(error))

            case .success(let message):
                switch message {
                case .string(let text):
                    // JSON string contain both required fields
                    //print("Received text: \(text)")
                    
                    if let data = text.data(using: .utf8) {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let transcribed = json["transcribed"] as? String,
                               let response = json["response"] as? [String: Any],
                                let message = response["message"] as? String {
                                completion(.success(["transcribed": transcribed, "response": message]))
                            } else {
                                let error = NSError(domain: "DataErrorDomain", code: 0, 
                                                    userInfo: [NSLocalizedDescriptionKey: "JSON does not contain 'transcribed' or 'response' keys"])
                                completion(.failure(error))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        let error = NSError(domain: "DataErrorDomain", code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON string"])
                        completion(.failure(error))
                    }

                case .data(let data):
                    // JSON as in the string case
                    //print("Received data: \(data)")
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let transcribed = json["transcribed"] as? String,
                           let response = json["response"] as? [String: Any],
                            let message = response["message"] as? String {
                            completion(.success(["transcribed": transcribed, "response": message]))
                        } else {
                            let error = NSError(domain: "DataErrorDomain", code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "JSON does not contain 'transcribed' or 'response' keys"])
                            completion(.failure(error))
                        }
                    } catch {
                        completion(.failure(error))
                    }

                @unknown default:
                    let error = NSError(domain: "WebSocketErrorDomain", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Unknown message type received"])
                    completion(.failure(error))
                }
            }
        }
    }
    
    func receiveJSONResponse(completion: @escaping (Result<[String: String], Error>) -> Void) {
        webSocketTask?.receive { result in
            Task {
                switch result {
                case .failure(let error):
                    print("Failed to receive JSON message: \(error.localizedDescription)")
                    completion(.failure(error))
                    
                case .success(let message):
                    switch message {
                    case .string(let jsonString):
                        Task { [weak self] in
                            await self?.parseJSONString(jsonString, completion: completion)
                        }
                        
                    case .data(let jsonData):
                        print("data")
                        Task { [weak self] in
                            await self?.parseJSONData(jsonData, completion: completion)
                        }
                    @unknown default:
                        print("Unknown message type received")
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown message type received"])))
                    }
                    
                    // Continuously receive messages by recursively calling this method
                    //self?.receiveJSONResponse(completion: completion)
                }
            }
            
        }
    }

}

extension RequestHandler {
    
    // Parses a JSON string and completes with either the server's response or an error.
    private func parseJSONString(_ jsonString: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        
        guard let data = jsonString.data(using: .utf8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data"])))
            return
        }
        parseJSONData(data, completion: completion)
    }

    // Parses a JSON Data object and completes with either the server's response or an error.
    private func parseJSONData(_ jsonData: Data, completion: @escaping (Result<[String: String], Error>) -> Void) {
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                var resultData = [String: String]()
                
                if let transcribedText = json["transcribed"] as? String {
                    resultData["transcribed"] = transcribedText
                } else {
                    let errorInfo = "JSON did not contain 'transcribed' key"
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorInfo])))
                    return
                }
                
                if let responseText = json["response"] as? String {
                    resultData["response"] = responseText
                } else {
                    let errorInfo = "JSON did not contain 'response' key"
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorInfo])))
                    return
                }
                
                // Success case: both 'transcribed' and 'response' are available
                completion(.success(resultData))
            } else {
                // The JSON structure was not as expected.
                let parseErrorInfo = "Failed to parse JSON: structure was not as expected."
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: parseErrorInfo])))
            }
        } catch {
            // There was an error parsing the JSON.
            completion(.failure(error))
        }
    }
}
