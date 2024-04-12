
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

final class RequestHandler: NSObject {
    
    static let shared = RequestHandler()
    
        
    private var audioWebSocketTask: URLSessionWebSocketTask?
    private var textWebSocketTask: URLSessionWebSocketTask?
    
    private let audioServerURL = URL(string: "wss://autopilotgpt.pro:8765")!
    private let textServerURL = URL(string: "wss://autopilotgpt.pro:8704")!
    
    override init() {
        super.init()
        //connectToServer()
    }
    
    func connectToServer() {
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        
        audioWebSocketTask = session.webSocketTask(with: audioServerURL)
        textWebSocketTask = session.webSocketTask(with: textServerURL)
        
        audioWebSocketTask?.resume()
        textWebSocketTask?.resume()
        
    }
    
    func disconnectFromServer() {
        audioWebSocketTask?.cancel(with: .goingAway, reason: nil)
        textWebSocketTask?.cancel(with: .goingAway, reason: nil)
        print("Disconnected from server")
    }
    
    func sendRecordedAudioData(_ audioData: Data) {
        
        if audioWebSocketTask?.state != .running {
            connectToServer()
        }
        print("*** Audio socket connected ***")
        let message = URLSessionWebSocketTask.Message.data(audioData)
        audioWebSocketTask?.send(message) { error in
            if let error = error {
                print("Failed to send audio data: \(error.localizedDescription)")
            } else {
                print("Audio data sent successfully")
            }
        }
    }
    
    func sendInstruction(_ text: String) {
        
        let jsonObject: [String: Any] = ["instruction_from_app": text]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to serialize JSON")
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(jsonString)
        textWebSocketTask?.send(message) { error in
            if let error = error {
                print("Failed to send instruction text as JSON: \(error.localizedDescription)")
            } else {
                print("Instruction text sent as JSON successfully")
            }
        }
    }
    
    func sendTranscribedText(_ text: String) {
        
        let jsonObject: [String: Any] = ["transcribed_text": text]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to serialize JSON")
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(jsonString)
        textWebSocketTask?.send(message) { error in
            if let error = error {
                print("Failed to send Transcribed text as JSON: \(error.localizedDescription)")
            } else {
                print("Transcribed text sent as JSON successfully")
            }
        }
    }
    
    func receiveTranscribedAudioMessage(completion: @escaping (String) -> Void) {
        if audioWebSocketTask?.state != .running {
            connectToServer()
        }
        audioWebSocketTask?.receive { result in
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error.localizedDescription)")
                completion("Error: \(error.localizedDescription)") // Returning error as string
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text: \(text)")
                    completion(text) // Returning the received text
                case .data(let data):
                    print("Received data: \(data)")
                    if let text = String(data: data, encoding: .utf8) {
                        completion(text) // Converting data to text if possible
                    } else {
                        completion("Received non-text data") // Handling non-text data
                    }
                @unknown default:
                    completion("Unknown message type received")
                }
                
                
            }
            // Optionally continue receiving messages here if needed
            //self.receiveAudioMessage(completion: completion)
        }
    }
    
    func receiveJSONResponse(completion: @escaping (Result<String, Error>) -> Void) {
        textWebSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Failed to receive JSON message: \(error.localizedDescription)")
                completion(.failure(error))
                
            case .success(let message):
                switch message {
                case .string(let jsonString):
                    self?.parseJSONString(jsonString, completion: completion)
                case .data(let jsonData):
                    print("data")
                    self?.parseJSONData(jsonData, completion: completion)
                @unknown default:
                    print("Unknown message type received")
                }
                
                // Continuously receive messages by recursively calling this method
                //self?.receiveJSONResponse(completion: completion)
            }
        }
    }

}

extension RequestHandler {
    
    // Parses a JSON string and completes with either the server's response or an error.
    private func parseJSONString(_ jsonString: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let data = jsonString.data(using: .utf8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data"])))
            return
        }
        parseJSONData(data, completion: completion)
    }

    // Parses a JSON Data object and completes with either the server's response or an error.
    private func parseJSONData(_ jsonData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        
        //completion(.success("Response from server"))
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                if let responseText = json["response"] as? String {
                    // Success case: the server returned a response.
                    completion(.success(responseText))
                } else if let errorText = json["error"] as? String {
                    // Error case: the server returned an error.
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorText])))
                } else {
                    // The JSON did not contain the expected keys.
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "JSON did not contain 'response' or 'error' keys"])))
                }
            } else {
                // The JSON structure was not as expected.
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])))
            }
        } catch {
            // There was an error parsing the JSON.
            completion(.failure(error))
        }
    }
}


extension RequestHandler: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
        if webSocketTask == textWebSocketTask {
            print("Text WebSocket connection opened")
        } else if webSocketTask == audioWebSocketTask {
            print("Audio WebSocket connection opened")
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        if webSocketTask == textWebSocketTask {
            print("Text WebSocket connection closed")
        } else if webSocketTask == audioWebSocketTask {
            if closeCode == .messageTooBig {
                print("Disconnected: Data frame size is too large.")
            }
            print("Audio WebSocket connection closed: \(closeCode.rawValue)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("WebSocket task completed with error: \(error.localizedDescription)")
        } else {
            print("WebSocket task completed successfully.")
        }
    }
    
    
    
}

extension RequestHandler {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // WARNING: Trusting all certificates is insecure and not recommended for production
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
