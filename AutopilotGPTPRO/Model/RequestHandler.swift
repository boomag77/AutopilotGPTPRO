
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

class RequestHandler: NSObject {
    
    static let shared = RequestHandler()
        
    private var webSocketTask: URLSessionWebSocketTask?
    private let serverURL = URL(string: "wss://autopilotgpt.pro:8765")!
    
    override init() {
        super.init()
        connectToServer()
    }
    
    private func connectToServer() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: serverURL)
        webSocketTask?.resume()
        
        // Example usage of receiveMessage
//        receiveMessage { receivedText in
//            print("Received text: \(receivedText)")
//        }
        print("Connecting to server at \(serverURL)")
    }
    
    func disconnectFromServer() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("Disconnected from server")
    }
    
    func sendAudioData(_ audioData: Data) {
        
        let message = URLSessionWebSocketTask.Message.data(audioData)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Failed to send audio data: \(error.localizedDescription)")
            } else {
                print("Audio data sent successfully")
            }
        }
    }
    
    func receiveMessage(completion: @escaping (String) -> Void) {
        webSocketTask?.receive { result in
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
                
                // Optionally continue receiving messages here if needed
                //self?.receiveMessage(completion: completion)
            }
            //self?.receiveMessage(completion: completion)
        }
    }
}

extension RequestHandler: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connection opened")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket connection closed")
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


extension RequestHandler {
    func sendInstruction(_ text: String) {
        // Creating a simple JSON object with a "instruction" key
        let jsonObject: [String: Any] = ["instruction": text]
        
        // Attempt to serialize jsonObject to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) else {
            print("Failed to serialize JSON")
            return
        }
        
        // Assuming the server expects a stringified JSON object
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            // Create a WebSocket text message from the jsonString
            let message = URLSessionWebSocketTask.Message.string(jsonString)
            
            // Send the message
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("Failed to send text data as JSON: \(error.localizedDescription)")
                } else {
                    print("Text data sent as JSON successfully")
                }
            }
        } else {
            print("Failed to encode JSON data as string")
        }
    }
}
