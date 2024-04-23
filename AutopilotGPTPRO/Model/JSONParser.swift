
import UIKit

final class JSONParser {
    
    init() {}
    
    deinit {
        print("JSON Parser has been deinitialized.")
    }
    
}

extension JSONParser {
    
    func parseJSONMessage(_ message: URLSessionWebSocketTask.Message) -> Result<[String: String], Error> {
        switch message {
        case .string(let text):
            return parseJSONString(text)
        case .data(let data):
            return parseJSONData(data)
        @unknown default:
            let error = NSError(domain: "WebSocketErrorDomain", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Unknown message type received"])
            return .failure(error)
        }
    }
    
    private func parseJSONString(_ jsonString: String) -> Result<[String: String], Error> {
        
        if let data = jsonString.data(using: .utf8) {
            return parseJSONData(data)
        } else {
            let error = NSError(domain: "DataErrorDomain", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON string"])
            return .failure(error)
        }
        
    }

    // Parses a JSON Data object and completes with either the server's response or an error.
    private func parseJSONData(_ jsonData: Data) -> Result<[String: String], Error> {
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
               let transcribed = json["transcribed"] as? String,
               let response = json["response"] as? [String: Any],
                let message = response["message"] as? String {
                return .success(["transcribed": transcribed, "response": message])
            } else {
                let error = NSError(domain: "DataErrorDomain", code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "JSON does not contain 'transcribed' or 'response' keys"])
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }
    
}
