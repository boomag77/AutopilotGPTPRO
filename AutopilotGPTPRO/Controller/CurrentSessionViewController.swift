
import UIKit
import AVFoundation

final class CurrentSessionViewController: UIViewController {
    
    private var updateTimer: Timer?
    private var audioRecorder: AVAudioRecorder?
    private var requester: RequestHandler = RequestHandler()
    
    var instruction: InstructionModel? {
        didSet {
            Task {
                await startSesion(instruction!)
            }
            
        }
    }
    
    private var sessionID: Int?
    private var tokens: Int = 896
    
    
    private var sessionMessages: [MessageModel] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                
                self?.tableView.reloadData()
                self?.scrollToBottom()
                //print(DataManager.shared.getMessagesCount(forSessionID: (self?.sessionID)!))
            }
            
        }
    }
    
    private func scrollToBottom() {
        let indexPath = IndexPath(row: sessionMessages.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
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
        tableView.backgroundColor = .black
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
        button.addAction(UIAction { [weak self] _ in
            Task {
                await self?.sendButtonTapped()
            }
            
        },
                         for: .touchUpInside)
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
    
    private lazy var messagesView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    deinit {
        //print("CurrentSessionViewController is being deinitialized!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let backButton = UIBarButtonItem(title: "End Session", style: .plain, target: self, action: #selector(backToInstructionsList))
//        self.navigationItem.leftBarButtonItem = backButton
        
        
        tableView.dataSource = self
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageCell")
        
        requestMicPermission()
        
        setup()
        
        //startSesion(self.instruction!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // remove StartSessionVC from navigationController stack
        if var navigationStack = navigationController?.viewControllers {
            navigationStack.remove(at: 1)
            navigationController?.setViewControllers(navigationStack, animated: true)
        }
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Task {
            await self.endSession()
        }
        
        //navigationController?.popToRootViewController(animated: false)
    }
    
//    @objc private func backToInstructionsList() {
//        let rootVC = InstructionsViewController()
//        present(rootVC, animated: true)
//    }
    
    
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
            messagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messagesView.bottomAnchor.constraint(equalTo: notRecordingBottomView.topAnchor),
            messagesView.bottomAnchor.constraint(equalTo: recordingBottomView.topAnchor)
        ])
        
//        messagesView.addSubview(self.textLabel)
//        NSLayoutConstraint.activate([
//            textLabel.centerXAnchor.constraint(equalTo: messagesView.centerXAnchor),
//            textLabel.centerYAnchor.constraint(equalTo: messagesView.centerYAnchor)
//        ])
        
        messagesView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: messagesView.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: messagesView.leadingAnchor, constant: 5),
            tableView.trailingAnchor.constraint(equalTo: messagesView.trailingAnchor, constant: -5),
            tableView.bottomAnchor.constraint(equalTo: messagesView.bottomAnchor, constant: -10)
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
    
    private func sendButtonTapped() async {
        
        recording.toggle()
        
        let audioFilePath: URL = getFilePath().appendingPathComponent("recording.wav")
//        
//        do {
//            let fileAttributes = try FileManager.default.attributesOfItem(atPath: audioFilePath.path)
//            if let fileSize = fileAttributes[FileAttributeKey.size] as? NSNumber {
//                // Convert bytes to megabytes (1 MB = 1,024 KB = 1,048,576 bytes)
//                let fileSizeInMB = Double(truncating: fileSize) / 1_048_576
//                print("File \(audioFilePath) is ready for sending!")
//                print("File size: \(String(format: "%.2f", fileSizeInMB)) MB")
//            }
//        } catch {
//            print("Error getting file attributes: \(error.localizedDescription)")
//        }
        
        // stop recording and send file to server
        // After response's recieved - delete recorded file
//        guard let audioFilePath = getPathForAudioFile() else {
//            print("Audio file path not found.")
//            return
//        }
        
        do {
            let audioData = try Data(contentsOf: audioFilePath)
            await requester.sendRecordedAudioData(audioData)
        } catch {
            //print("Failed to load audio data: \(error.localizedDescription)")
        }
        
        // Assuming the server sends a response after processing the audio
        await requester.receiveTranscribedAudioMessage() { [weak self] result in
            switch result {
            case .success(let responseDict):
                DispatchQueue.main.async {
                    self?.processResponseDictionary(responseDict)
                }
            case .failure(let error):
                print("Failed to receive transcribed message: \(error.localizedDescription)")
            }
        }
            
    }
    
    private func processResponseDictionary(_ responseDict: [String: String]) {
        
        guard let transcribedText = responseDict["transcribed"],
              let responseText = responseDict["response"] else {
            print("Response dictionary missing expected keys")
            return
        }

        let transcribedMessage = MessageModel(date: Date(), sender: .user, text: transcribedText)
        let responseMessage = MessageModel(date: Date(), sender: .autopilot, text: responseText)
        
        sessionMessages.append(transcribedMessage)
        DataManager.shared
            .registerNewMessage(message: transcribedMessage,
                                in: self.sessionID!)
        sessionMessages.append(responseMessage)
        DataManager.shared
            .registerNewMessage(message: responseMessage,
                                in: self.sessionID!)
    }
        
    private func sendInstructionToServer(instruction: String) async {
        
        await requester.sendInstruction(instruction)
        
    }
    
    
    private func resetButtonTapped() {
        recording.toggle()
    }
    
    

}

// MARK: Session managing

extension CurrentSessionViewController {
    
    private func startSesion(_ instruction: InstructionModel) async {
        
        await requester.connectToServer()
        
        self.sessionID = DataManager.shared
            .registerNewSession(date: Date(), position: instruction.name)
        
        await sendInstructionToServer(instruction: instruction.text)
        
    }
    
    private func endSession() async {
        
        if recording {
            recording.toggle()
        }
        saveCurrentSession()
        
        await requester.disconnectFromServer()
        //print("Session ended")
    }
    
    // Remove session from storage if it's no messages
    private func saveCurrentSession() {
        
        if DataManager.shared.getMessagesCount(forSessionID: self.sessionID!) == 0 {
            //print("Current session is Empty and will not be saved")
            DataManager.shared.removeSession(withID: self.sessionID!)
        } else {
            //print("Session saved")
        }
        
    }
}

// MARK: Audio recording managing

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
        
        let audioFilename = getFilePath().appendingPathComponent("recording.wav")
        
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
    
    private func getFilePath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopUpdatingWaveform()
    }
    
    private func checkRecordedFileExists() {
        let filePath = getFilePath().appendingPathComponent("recording.wav")
        if FileManager.default.fileExists(atPath: filePath.path) {
            //print("File with name: recording.wav exists and full path to this file is: \(filePath.path)")
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

// MARK: TableView

extension CurrentSessionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionMessages.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = sessionMessages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        
        cell.setText(text: message.text)
        cell.setSender(sender: message.sender)
        
        return cell
        
    }
    
}
