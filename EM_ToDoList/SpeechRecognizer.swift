import Speech
import AVFoundation
import Combine

@MainActor
final class SpeechRecognizer: ObservableObject {
    @Published var text = ""
    @Published var isRecording = false

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US" /*"ru-RU"*/))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var silenceTimer: Timer?
    private let silenceTimeout: TimeInterval = 2.0

    func requestPermission() async -> Bool {
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(
                    returning: status == .authorized
                )
            }
        }

        let audioAuthorized = await AVAudioApplication.requestRecordPermission()

        return speechAuthorized && audioAuthorized
    }

    func startRecording() {
        guard !isRecording else { return }

        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        guard recordingFormat.sampleRate > 0, recordingFormat.channelCount > 0 else {
            print("Invalid recording format: \(recordingFormat)")
            recognitionRequest = nil
            return
        }

        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: recordingFormat
        ) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: request ) { [weak self] result, error in
            guard let self else { return }
            
            if let result {
                let newText = result.bestTranscription.formattedString
                if !newText.isEmpty {
                    self.text = newText
                }
                self.resetSilenceTimer()
            }
            
            if let error {
                print("Recognition error:", error.localizedDescription)
            }
            
            if error != nil || result?.isFinal == true {
                self.stopRecording()
            }
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            resetSilenceTimer()
        } catch {
            stopRecording()
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    // MARK: - Silence timer
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceTimeout, repeats: false) { [weak self] _ in
            Task {
                await self?.stopRecording()
            }
        }
    }
}
