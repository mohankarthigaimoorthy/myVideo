//
//  ViewController.swift
//  myVideoApp
//
//  Created by Mohan K on 29/12/22.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var currentLabel: UILabel!
  
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var timeLapse: UISlider!
    
    @IBOutlet weak var pipButton: UIButton!
    
    
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isVideoPlaying = false
    private var playerItemContext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        
        player = AVPlayer(url: url!)
        
//        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial],context: nil)
//        if let currentItem =   player.currentItem{
//            currentItem.addObserver(self,
//                                    forKeyPath: #keyPath(AVPlayerItem.status),
//                                    options: [.old, .new],
//                                    context: &playerItemContext)
//        }
        
        addTimeObserver()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        videoView.layer.addSublayer(playerLayer)
        buttonView.layer.addSublayer(playerLayer)
        
//        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 5) {
//            self.setupPictureInPicture()
//        }
//        pipButton.setImage(startImage, for: UIControl.State.normal)
//        pipButton.setImage(stopImage, for: UIControl.State.normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            switch status {
            case .readyToPlay:
                print("readyToPlay")
//                self.setupPictureInPicture()
                // Player item is ready to play.
            case .failed:
                print("failed")
                // Player item failed. See error.
            case .unknown:
                print("unknown")
                // Player item is not yet ready.
            }
        }
    }
    
    func addTimeObserver(){
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            self?.timeLapse.maximumValue = Float(currentItem.duration.seconds)
            self?.timeLapse.minimumValue = 0.0
            self?.timeLapse.value = Float(currentItem.currentTime().seconds)
            self?.currentLabel.text =  self?.getTimeString(from: currentItem.currentTime())
            
        })
        
    }
    
    @IBAction func didClickPlayButton(_ sender: UIButton) {
        print("press")
        if isVideoPlaying  {
            player.pause()
        }else{
            player.play()
        }
        
        isVideoPlaying = !isVideoPlaying
        sender.isSelected = !sender.isSelected
    }
    
  

    
    @IBAction func didClickForwardButton(_ sender: UIButton) {
        
        guard let duration = player.currentItem?.duration else{return}
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 5.0
        
        if newTime < (CMTimeGetSeconds(duration) - 5.0) {
            let time: CMTime = CMTimeMake(value: Int64(newTime*10000), timescale: 10000)
            player.seek(to: time)
        }
        
    }
    
    @IBAction func didClickBackutton(_ sender: UIButton) {
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 5.0
        
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
        player.seek(to: time)
        
    }
    
    
    @IBAction func didClickSliderValueChange(_ sender: UISlider) {
        
        
        player.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
        
    }
    
    @IBAction func landscapeMode(_ sender: UIButton) {
        print("turn")
        videoView.transform = videoView.transform.rotated(by: .pi / 2)
        buttonView.transform = buttonView.transform.rotated(by: .pi / 2)
    }
    
    
    @IBAction func pipMode(_ sender: UIButton) {
//        print("isPictureInPictureActive: \(pipController.isPictureInPictureActive)")
//        if pipController.isPictureInPictureActive {
//            pipController.startPictureInPicture()
//        }else{
//            pipController.stopPictureInPicture()
//        }
       
    }
//
//    func setupPictureInPicture() {
//        if AVPictureInPictureController.isPictureInPictureSupported() {
//            pipController = AVPictureInPictureController(playerLayer: playerLayer)
//            pipController.delegate = self
//
//            pipPossibleObservation = pipController.observe(\AVPictureInPictureController.isPictureInPicturePossible,
//                                                            options: [.initial, .new]) { [weak self] t, change in
//                print("isPictureInPicturePossible isposible: \(t)  \(change.newValue ?? false)")
//                self?.pipButton.isEnabled = change.newValue ?? false
//            }
//        }else{
//            pipButton.isEnabled = false
//
//        }
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
//            self.durationLabel.text = getTimeString(from: player.currentItem!.duration)
//        }
//    }
//
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%1:%02i:%02i", arguments: [hours,minutes,seconds])
        }
        else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
}


//extension ViewController: AVPictureInPictureControllerDelegate{
//
//    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
//                                    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
//        // Restore the user interface.
//        completionHandler(true)
//    }
//}
