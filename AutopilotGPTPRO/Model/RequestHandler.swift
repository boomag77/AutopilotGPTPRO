
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
    
    var instruction: InstructionModel? { get }
    func presentResponse(_ response: Result<[String: String], Error>)
}

actor RequestHandler {
    
    var shouldContinueReceivingMessages = true
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let serverURL = URL(string: "wss://autopilotgpt.pro:8765/start_chat")!
    
    var delegate: WebSocketDelegate?
    
    var instruction: InstructionModel? {
        didSet {
            delegate = WebSocketDelegate()
            delegate?.owner = self
            connect()
            sendInstruction()
        }
    }
    
    
    weak var viewController: RequestHandlerViewControllerProtocol? 
    
    deinit {
        print("Requester deinitialized")
        Task { [weak self] in
            await self?.disconnect()
        }
    }
    
    func getViewController() -> UIViewController? {
        return viewController
    }
    
    func setInstruction(_ instruction: InstructionModel) {
        self.instruction = instruction
    }
    
    func setViewController(_ viewController: UIViewController?) {
        self.viewController = viewController as? RequestHandlerViewControllerProtocol
    }
    
    func connect() {
        
        //delegate.owner = self
        
        let session = configureURLSession()
        
        webSocketTask = session.webSocketTask(with: serverURL)
        
        webSocketTask?.resume()
        
        listenForMessages()
        
        print("connecting to server")
        
    }
    
    func reconnect() {
        connect()
        sendInstruction()
        listenForMessages()
    }
    
    private func configureURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 30
        //configuration.timeoutIntervalForResource = 120
        
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: OperationQueue())
    }
    
    func disconnect() {
        delegate = nil
        shouldContinueReceivingMessages = false
        let reason = "Normal disconnect".data(using: .utf8)
        webSocketTask?.cancel(with: .normalClosure, reason: reason)
        webSocketTask = nil
        print("Disconnected from server")
    }
    
    func sendRecordedAudioData(_ audioData: Data) {
        
        if webSocketTask?.state != .running {
            let data = audioData
            print("While sending recorded - Task isn't running! Trying to reconnect......")
            reconnect()
            //sendInstruction()
            sendRecordedAudioData(data)
            
        }
        
        let message = URLSessionWebSocketTask.Message.data(audioData)
        
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Failed to send audio data: \(error.localizedDescription)")
            } else {
                
                print("Audio data sent successfully")
            }
        }
        
//        Task {
//            listenForMessages()
//        }
        
    }
    
    func sendInstruction() {
        
        let text = self.instruction!.text
        
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
        
//        Task {
//            listenForMessages()
//        }
        
    }
    
    private func listenForMessages() {
        
        if !shouldContinueReceivingMessages {
                print("Stopped listening for messages.")
                return  // Stop recursion
            }
        
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                
                Task { [weak self] in
                    //guard let self = self else {return}
                    await self?.viewController?.presentResponse(.failure(error))
                }
//                Task { [weak self] in
//                    await self?.reconnect()
//                }
                

            case .success(let message):
                Task { [weak self] in
                    guard let self = self else {return}
                    let response = await self.handleReceivedMessage(message)
                    await self.viewController?.presentResponse(response)
                }
                
                Task { [weak self] in
                    await self?.listenForMessages()
                }
            }
        }
    }
    
    private func handleReceivedMessage(_ message: URLSessionWebSocketTask.Message) -> Result<[String: String], Error> {
        
        let jsonParser = JSONParser()
        let parsedResponse = jsonParser.parseJSONMessage(message)
        
        switch parsedResponse {
        case .failure(let error):
            return .failure(error)
        case .success(let dictionary):
            return .success(dictionary)
            
        }
    }
}

