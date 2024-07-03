import Foundation
import AmplitudeSwift

final class AmplitudeManager {
    
    static let shared = AmplitudeManager()
    
    private var amplitude: Amplitude
    
    private init() {
        
        let configuration = Configuration(
            apiKey: AppConstants.amplitudeAPIKey,
            logLevel: .WARN, // Enable logging
            callback: { (event: BaseEvent, code: Int, message: String) -> Void in
                print("eventcallback: \(event.eventType), code: \(code), message: \(message)")
                if let props = event.eventProperties {
                    print(props)
                }
                
            }
        )
        self.amplitude = Amplitude(configuration: configuration)
    }
    
    @discardableResult
    func track(eventType: String, properties: [String: Any]? = nil, callback: EventCallback? = nil) -> Amplitude {
        let event = BaseEvent(eventType: eventType)
        
        if let properties = properties {
            event.eventProperties = properties
        }
        
        if let callback = callback {
            event.callback = callback
        }
        
        amplitude.track(event: event)
        
        return amplitude
    }
    
}
