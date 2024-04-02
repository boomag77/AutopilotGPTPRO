
import Foundation

class RequestHandler {
    
    static let shared = RequestHandler()
    
    private lazy var socketFD: Int32 = -1
    private let serverAddress: String = "autopilotpro.com"
    private let serverPort: Int = 1234

    init() {}

    func connectToServer() -> Bool {
        socketFD = socket(AF_INET, SOCK_STREAM, 0)
        guard socketFD > 0 else {
            print("Socket creation failed")
            return false
        }

        var server = sockaddr_in()
        server.sin_family = sa_family_t(AF_INET)
        server.sin_port = in_port_t(serverPort).bigEndian

        // Convert server address from hostname to IP
        let serverIP = gethostbyname(serverAddress)
        bcopy(serverIP?.pointee.h_addr_list[0], &server.sin_addr.s_addr, Int(serverIP?.pointee.h_length ?? 0))

        let connectionResult = withUnsafePointer(to: &server) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(socketFD, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
            }
        }

        if connectionResult < 0 {
            print("Connection to server failed")
            return false
        }

        print("Connected to server at \(serverAddress):\(serverPort)")
        return true
    }

    func disconnectFromServer() {
        if socketFD != -1 {
            close(socketFD)
            socketFD = -1
            print("Disconnected from server")
        }
    }

    func sendAudioData(_ audioData: Data) {
        audioData.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Void in
            let _ = send(socketFD, bytes.baseAddress, audioData.count, 0)
        }
        print("Audio data sent")
    }

    func receiveResponse() -> String? {
        var buffer = [UInt8](repeating: 0, count: 1024)
        let receivedBytes = recv(socketFD, &buffer, buffer.count, 0)
        
        guard receivedBytes > 0 else {
            print("Data reception failed or connection closed")
            return nil
        }
        
        return String(bytes: Array(buffer[0..<receivedBytes]), encoding: .utf8)
    }
    
}
