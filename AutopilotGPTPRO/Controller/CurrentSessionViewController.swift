
import UIKit
import AVFoundation

class CurrentSessionViewController: UIViewController {
    
    private var updateTimer: Timer?
    private var audioRecorder: AVAudioRecorder?
    
    var position: String?
    private var tokens: Int = 896
    
    private var sessionPosts: [MessageModel] = []
    
    private var recording: Bool = false {
        didSet {
            if !recording {
                stopRecording()
            } else {
                startRecording()
            }
            notRecordingBottomView.isHidden.toggle()
            recordingBottomView.isHidden.toggle()
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var waveformView: WaveformView = {
        let view = WaveformView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        button.addAction(UIAction { [weak self] _ in
            self?.resetButtonTapped()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var notRecordingBottomView: UIView = {
        let view = UIView()
        view.isHidden = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var recordingBottomView: UIView = {
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
        
        //tableView.dataSource = self
        
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
        self.view.addSubview(notRecordingBottomView)
        self.view.insertSubview(recordingBottomView, at: 0)
        
        NSLayoutConstraint.activate([
            notRecordingBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            notRecordingBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            notRecordingBottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            notRecordingBottomView.heightAnchor.constraint(equalToConstant: 64),
            
            recordingBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recordingBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recordingBottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            recordingBottomView.heightAnchor.constraint(equalToConstant: 64),
            
            messagesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            messagesView.bottomAnchor.constraint(equalTo: notRecordingBottomView.topAnchor),
            messagesView.bottomAnchor.constraint(equalTo: recordingBottomView.topAnchor)
        ])
        
        setupBottomViews()
    }
    
    private func setupBottomViews() {
        
        notRecordingBottomView.addSubview(recButton)
        
        NSLayoutConstraint.activate([
            recButton.centerXAnchor.constraint(equalTo: notRecordingBottomView.centerXAnchor),
            recButton.bottomAnchor.constraint(equalTo: notRecordingBottomView.bottomAnchor),
            recButton.heightAnchor.constraint(equalToConstant: 64),
            recButton.widthAnchor.constraint(equalToConstant: 64)
        ])
        
        recordingBottomView.addSubview(sendButton)
        recordingBottomView.addSubview(resetButton)
        recordingBottomView.addSubview(waveformView)
        
        NSLayoutConstraint.activate([
            resetButton.leadingAnchor.constraint(equalTo: recordingBottomView.leadingAnchor, constant: 10),
            resetButton.bottomAnchor.constraint(equalTo: recordingBottomView.bottomAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 64),
            resetButton.widthAnchor.constraint(equalToConstant: 64),
            
            sendButton.trailingAnchor.constraint(equalTo: recordingBottomView.trailingAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: recordingBottomView.bottomAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 64),
            sendButton.widthAnchor.constraint(equalToConstant: 64),
            
            waveformView.leadingAnchor.constraint(equalTo: resetButton.trailingAnchor, constant: 40),
            waveformView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -40),
            waveformView.topAnchor.constraint(equalTo: recordingBottomView.topAnchor, constant: 10),
            waveformView.bottomAnchor.constraint(equalTo: recordingBottomView.bottomAnchor, constant: -10)
            
        ])
        
    }
    
    
    
    private func recButtonTapped() {
        self.recording.toggle()
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
        recording.toggle()
    }
    
    private func endSession() {
        if recording {
            recording.toggle()
        }
        saveCurrentSession()
        print("Session ended")
    }
    
    private func saveCurrentSession() {
        
        DataManager.shared.registerNewSession(session: SessionModel(id: 0, date: Date(), position: self.position!))
        
        print("Session saved")
    }

}

extension CurrentSessionViewController: AVAudioRecorderDelegate {
    
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
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure the audio session: \(error)")
        }
    }
    
    
    
    private func startRecording() {
        
        configureAudioSession()
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            if audioRecorder?.record() == true {
                print("Recording started")
                startUpdatingWaveform()
            } else {
                print("Failed to start recording.")
            }
            
        } catch {
            print("Failed to initialize the audio recorder: \(error)")
        }
    }
    
    private func startUpdatingWaveform() {
        
        audioRecorder?.isMeteringEnabled = true
        let MaximumPowerLevelsCount = 50
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            self?.audioRecorder?.updateMeters()
            
            let averagePower: Float = self?.audioRecorder?.averagePower(forChannel: 0) ?? 0
            if averagePower > 0 {
                self?.waveformView.powerLevels.append(CGFloat(averagePower))
            }
            self?.waveformView.powerLevels.append(CGFloat(averagePower))
            
            // Optionally, trim the powerLevels array to keep it within a reasonable size
            if self?.waveformView.powerLevels.count ?? 0 > MaximumPowerLevelsCount {
                self?.waveformView.powerLevels.removeFirst()
            }
        }
    }
    
    private func stopUpdatingWaveform() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopUpdatingWaveform()
    }
    
    private func checkRecordedFileExists() {
        let filePath = getDocumentsDirectory().appendingPathComponent("recording.wav")
        if FileManager.default.fileExists(atPath: filePath.path) {
            print("File with name: recording.wav exists and full path to this file is: \(filePath.path)")
            // Optionally, send the file to a server
        } else {
            print("Recording file does not exist.")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully.")
            checkRecordedFileExists()
        } else {
            print("!!! Recording finished unsuccessfully !!!")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Encode error occurred: \(error.localizedDescription)")
        }
    }
    
}

extension CurrentSessionViewController {
    
    private func fetchPosts() {
        
        tableView.reloadData()
    }
    
}

//extension CurrentSessionViewController: UITableViewDataSource {
//    
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        //
////
////    }
////    
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        //
////    }
//    
//    
//}
