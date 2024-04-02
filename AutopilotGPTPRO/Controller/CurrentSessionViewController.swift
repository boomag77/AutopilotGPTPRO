
import UIKit
import AVFoundation

class CurrentSessionViewController: UIViewController {
    
    private var audioRecorder: AVAudioRecorder?
    
    private var recording: Bool = false {
        didSet {
            inactiveBottomView.isHidden.toggle()
            activeBottomView.isHidden.toggle()
        }
    }
    
    private var tokens: Int = 896
    
    private lazy var recButton: UIButton = {
        let button = SessionControlsButton()
        
        var config = UIButton.Configuration.filled()
        config.title = "REC"
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        button.configuration = config
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.recButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = SessionControlsButton()
        
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "checkmark")
        config.baseBackgroundColor = .systemGreen
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        button.configuration = config
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = SessionControlsButton()
        
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "xmark")
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        button.configuration = config
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var inactiveBottomView: UIView = {
        let view = UIView()
        view.isHidden = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var activeBottomView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messagesView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestMicPermission()
        setup()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.endSession()
    }
    
    private func setup() {
        view.backgroundColor = .black
        
        self.view.addSubview(messagesView)
        self.view.addSubview(inactiveBottomView)
        self.view.insertSubview(activeBottomView, at: 0)
        
        NSLayoutConstraint.activate([
            inactiveBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inactiveBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inactiveBottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            inactiveBottomView.heightAnchor.constraint(equalToConstant: 84),
            
            activeBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            activeBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            activeBottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            activeBottomView.heightAnchor.constraint(equalToConstant: 84),
            
            messagesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            messagesView.bottomAnchor.constraint(equalTo: inactiveBottomView.topAnchor)
        ])
        
        setupBottomViews()
    }
    
    private func setupBottomViews() {
        
        inactiveBottomView.addSubview(recButton)
        
        NSLayoutConstraint.activate([
            recButton.centerXAnchor.constraint(equalTo: inactiveBottomView.centerXAnchor),
            recButton.bottomAnchor.constraint(equalTo: inactiveBottomView.bottomAnchor),
            recButton.heightAnchor.constraint(equalToConstant: 64),
            recButton.widthAnchor.constraint(equalToConstant: 64)
        ])
        
        activeBottomView.addSubview(sendButton)
        activeBottomView.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            resetButton.leadingAnchor.constraint(equalTo: activeBottomView.leadingAnchor, constant: 10),
            resetButton.bottomAnchor.constraint(equalTo: activeBottomView.bottomAnchor, constant: -10),
            resetButton.heightAnchor.constraint(equalToConstant: 64),
            resetButton.widthAnchor.constraint(equalToConstant: 64),
            
            sendButton.trailingAnchor.constraint(equalTo: activeBottomView.trailingAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: activeBottomView.bottomAnchor, constant: -10),
            sendButton.heightAnchor.constraint(equalToConstant: 64),
            sendButton.widthAnchor.constraint(equalToConstant: 64)
            
        ])
        
    }
    
    private func requestMicPermission() {
        
        if #available(iOS 17, *) {
            AVAudioApplication.requestRecordPermission { granted in
                if granted {
                    print("Microphone permission granted (iOS 17+ method).")
                } else {
                    self.showMicAccessNeededAlert()
                    print("Microphone permission denied (iOS 17+ method).")
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    print("Microphone permission granted.")
                } else {
                    self.showMicAccessNeededAlert()
                    print("Microphone permission denied.")
                }
            }
        }
    }
    
    private func showMicAccessNeededAlert() {
        let alertController = UIAlertController(
            title: "Microphone Access Required",
            message: "To use this feature, please enable microphone access in Settings.",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, completionHandler: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func recButtonTapped() {
        startRecording()
        self.recording.toggle()
        print("Recording started!")
    }
    
    private func sendButtonTapped() {
        
        // stop recording and send file to server
        // After response's recieved - delete recorded file
        
//        if RequestHandler.shared.connectToServer() {
//            if let audioData = try? Data(contentsOf: URL(fileURLWithPath: "path/to/audio.wav")) {
//                RequestHandler.shared.sendAudioData(audioData)
//
//                if let response = RequestHandler.shared.receiveResponse() {
//                    print("Received from server: \(response)")
//                }
//            } else {
//                print("Failed to load audio data")
//            }
//
//            RequestHandler.shared.disconnectFromServer()
//        } else {
//            print("Failed to connect to the server.")
//        }
    }
    
    private func resetButtonTapped() {
        
        // Stop recording and delete last recorded file
        
        self.stopRecording()
        recording.toggle()
    }
    
    private func endSession() {
        saveCurrentSession()
        print("Recording stopped")
    }
    
    private func saveCurrentSession() {
        print("Session saved")
    }

}

extension CurrentSessionViewController: AVAudioRecorderDelegate {
    
    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            print("Recording started")
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        print("Recording stopped")
    }
    
}
