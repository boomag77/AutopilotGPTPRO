
protocol AutopilotError: Error {
    var title: String { get }
    var description: String { get }
    //func retryAction() -> (() -> Void)?
}


enum NetworkError: AutopilotError {
    
    case disconnected
    case failedToReceive
    
    var title: String {
        return "Network Error"
    }
    
    var description: String {
        switch self {
        case .disconnected:
            return "The Internet connection appears to be offline."
        case .failedToReceive:
            return "Failed to receive response from server."
        }
        
    }
    
//    func retryAction() -> (() -> Void)? {
//        switch self {
//        case .disconnected:
//            return {  }
//        case .failedToReceive:
//            return
//        default:
//            return nil
//        }
//    }
}

