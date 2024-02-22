//
//  RecorderVC.swift
//  Alarm
//
//  Created by pinali gabani on 19/12/23.
//

import UIKit
import AVFoundation

class RecorderVC: UIViewController {
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var meterTimer: Timer!
    var soundFileURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopBtn.isEnabled = false
        playBtn.isEnabled = false
        setSessionPlayback()
        askForNotifications()
        checkHeadphones()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
    }
    
    func setSessionPlayback() {
        print("\(#function)")
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSession.Category.playback, options: .defaultToSpeaker)
            
        } catch {
            print("could not set session category")
            print(error.localizedDescription)
        }
        
        do {
            try session.setActive(true)
        } catch {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func askForNotifications() {
        print("\(#function)")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RecorderVC.background(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RecorderVC.foreground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RecorderVC.routeChange(_:)),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
    }
    
    @objc func updateAudioMeter(_ timer: Timer) {
        if let recorder = self.recorder {
            if recorder.isRecording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                timeLbl.text = s
                recorder.updateMeters()
            }
        }
    }
    
    @objc func background(_ notification: Notification) {
        print("\(#function)")
    }
    
    @objc func foreground(_ notification: Notification) {
        print("\(#function)")
    }
    
    @objc func routeChange(_ notification: Notification) {
        print("\(#function)")
        
        if let userInfo = (notification as NSNotification).userInfo {
            print("routeChange \(userInfo)")
            
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSession.RouteChangeReason(rawValue: reason)! {
                case AVAudioSession.RouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSession.RouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSession.RouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSession.RouteChangeReason.override:
                    print("Override")
                case AVAudioSession.RouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSession.RouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSession.RouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSession.RouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                    
                @unknown default:
                    break
                }
            }
        }
        
        // this cast fails. that's why I do that goofy thing above.
        //        if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? AVAudioSessionRouteChangeReason {
        //        }
        
        /*
         AVAudioSessionRouteChangeReasonUnknown = 0,
         AVAudioSessionRouteChangeReasonNewDeviceAvailable = 1,
         AVAudioSessionRouteChangeReasonOldDeviceUnavailable = 2,
         AVAudioSessionRouteChangeReasonCategoryChange = 3,
         AVAudioSessionRouteChangeReasonOverride = 4,
         AVAudioSessionRouteChangeReasonWakeFromSleep = 6,
         AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory = 7,
         AVAudioSessionRouteChangeReasonRouteConfigurationChange NS_ENUM_AVAILABLE_IOS(7_0) = 8
         
         routeChange Optional([AVAudioSessionRouteChangeReasonKey: 1, AVAudioSessionRouteChangePreviousRouteKey: <AVAudioSessionRouteDescription: 0x17557350,
         inputs = (
         "<AVAudioSessionPortDescription: 0x17557760, type = MicrophoneBuiltIn; name = iPhone Microphone; UID = Built-In Microphone; selectedDataSource = Bottom>"
         );
         outputs = (
         "<AVAudioSessionPortDescription: 0x17557f20, type = Speaker; name = Speaker; UID = Built-In Speaker; selectedDataSource = (null)>"
         )>])
         routeChange Optional([AVAudioSessionRouteChangeReasonKey: 2, AVAudioSessionRouteChangePreviousRouteKey: <AVAudioSessionRouteDescription: 0x175562f0,
         inputs = (
         "<AVAudioSessionPortDescription: 0x1750c560, type = MicrophoneBuiltIn; name = iPhone Microphone; UID = Built-In Microphone; selectedDataSource = Bottom>"
         );
         outputs = (
         "<AVAudioSessionPortDescription: 0x17557de0, type = Headphones; name = Headphones; UID = Wired Headphones; selectedDataSource = (null)>"
         )>])
         */
    }

    func checkHeadphones() {
        print("\(#function)")
        
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if !currentRoute.outputs.isEmpty {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSession.Port.headphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    func setupRecorder() {
        print("\(#function)")
        
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        print("writing to soundfile url: '\(soundFileURL!)'")
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 32000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func recordWithPermission(_ setup: Bool) {
        print("\(#function)")
        
        AVAudioSession.sharedInstance().requestRecordPermission {
            [unowned self] granted in
            if granted {
                
                DispatchQueue.main.async {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target: self,
                                                           selector: #selector(self.updateAudioMeter(_:)),
                                                           userInfo: nil,
                                                           repeats: true)
                }
            } else {
                print("Permission to record not granted")
            }
        }
        
        if AVAudioSession.sharedInstance().recordPermission == .denied {
            print("permission denied")
        }
    }
    
    func setSessionPlayAndRecord() {
        print("\(#function)")
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
        } catch {
            print("could not set session category")
            print(error.localizedDescription)
        }
        
        do {
            try session.setActive(true)
        } catch {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    @IBAction func recordBtnClicked(_ sender: Any) {
        if player != nil && player.isPlaying {
            print("stopping")
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            recordBtn.setTitle("Pause", for: .normal)
            playBtn.isEnabled = false
            stopBtn.isEnabled = true
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.isRecording {
            print("pausing")
            recorder.pause()
            recordBtn.setTitle("Continue", for: .normal)
            
        } else {
            print("recording")
            recordBtn.setTitle("Pause", for: .normal)
            playBtn.isEnabled = false
            stopBtn.isEnabled = true
            //            recorder.record()
            recordWithPermission(false)
        }
    }
    
    func play() {
        print("\(#function)")
    
        var url: URL?
        if self.recorder != nil {
            url = self.recorder.url
        } else {
            url = self.soundFileURL!
        }
        print("playing \(String(describing: url))")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            stopBtn.isEnabled = true
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch {
            self.player = nil
            print(error.localizedDescription)
        }
    }
    
    func renameRecording(_ from: URL, to: URL) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let toURL = documentsDirectory.appendingPathComponent(to.lastPathComponent)
        
        print("renaming file \(from.absoluteString) to \(to) url \(toURL)")
        let fileManager = FileManager.default
        fileManager.delegate = self
        do {
            try FileManager.default.moveItem(at: from, to: toURL)
        } catch {
            print(error.localizedDescription)
            print("error renaming recording")
        }
    }

    @IBAction func stopBtnClicked(_ sender: Any) {
        recorder?.stop()
        player?.stop()
        
        meterTimer.invalidate()
        
        recordBtn.setTitle("Record", for: .normal)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            playBtn.isEnabled = true
            stopBtn.isEnabled = false
            recordBtn.isEnabled = true
        } catch {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
    }
    
    @IBAction func playBtnClicked(_ sender: Any) {
        play()
    }
}
extension RecorderVC: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool) {
        
        print("\(#function)")
        print("finished recording \(flag)")
        stopBtn.isEnabled = false
        playBtn.isEnabled = true
        recordBtn.setTitle("Record", for: UIControl.State())
        
        let alert = UIAlertController(title: "Enter filename",
            message: nil,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {_ in
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            [unowned alert] _ in
            
            if let textFields = alert.textFields {
                let tfa = textFields as [UITextField]
                let text = tfa[0].text
                let url = URL(fileURLWithPath: text!).deletingPathExtension().appendingPathExtension("m4a")
                self.renameRecording(self.soundFileURL, to: url)
                self.dismiss(animated: true)
            }
        }))
        
        alert.addTextField(configurationHandler: {textfield in
            textfield.placeholder = "filename"
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                          error: Error?) {
        print("\(#function)")
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
}

// MARK: AVAudioPlayerDelegate
extension RecorderVC : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("\(#function)")
        
        print("finished playing \(flag)")
        recordBtn.isEnabled = true
        stopBtn.isEnabled = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("\(#function)")
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
}
extension RecorderVC: FileManagerDelegate {

    func fileManager(_ fileManager: FileManager, shouldMoveItemAt srcURL: URL, to dstURL: URL) -> Bool {

        print("should move \(srcURL) to \(dstURL)")
        return true
    }
}
