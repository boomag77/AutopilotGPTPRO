
import UIKit

//protocol WebSocketObserverProtocol: UIViewController {
//    func webSocketDidiOpen()
//    func webSocketDidClose(with error: Error?)
//    
//    func webSocketDidFailWithError(_ error: Error?)
//}

class WebSocketDelegate: NSObject, URLSessionWebSocketDelegate {
    
    weak var owner: RequestHandler?
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task {
            await owner?.setConnectionState(.connected)
        }
        print("Websocket connection opened")
    }
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
//        let error = NSError(domain: "WebSocketError",
//                            code: Int(closeCode.rawValue),
//                            userInfo: [NSLocalizedDescriptionKey: "WebSocket closed with code \(closeCode.rawValue)"])
        Task {
            await owner?.setConnectionState(.disconnected)
        }
        print("WebSocket connection closed")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let error = error {
            
            print("From Delegate: WebSocket task completed with error: \(error.localizedDescription)")
        }
    }
    
    internal func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // WARNING: Trusting all certificates is insecure and not recommended for production
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    
    
    
}
