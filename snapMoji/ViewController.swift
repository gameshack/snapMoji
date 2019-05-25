// ViewController.swift

import UIKit
import ARKit
import ReplayKit

import SCSDKCreativeKit

class ViewController: UIViewController, RPPreviewViewControllerDelegate {
    
    let trackingView = ARSCNView()
    let smileLabel = UILabel()
    let valueLabel = UILabel()
    let buttonLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startRecording))
        
        // Check to make sure AR face tracking is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            // If face tracking isn't available throw error and exit
            fatalError("ARKit is not supported on this device")
        }
        
        // Request camera permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if (granted) {
                // If access is granted, setup the main view
                DispatchQueue.main.sync {
                    self.setupSmileTracker()
                }
            } else {
                // If access is not granted, throw error and exit
                fatalError("This app needs Camera Access to function. You can grant access in Settings.")
            }
        }
    }
    
    func shareVideo(mediaURL: URL) {
        let snapVideo = SCSDKSnapVideo(videoUrl: mediaURL)
        let snapContent = SCSDKVideoSnapContent(snapVideo: snapVideo)
        
        // Send it over to Snapchat
        let snapAPI = SCSDKSnapAPI(content: snapContent)
        snapAPI.startSnapping { (error: Error?) in
            print("Sharing a video on SnapChat.")
        }
    }
    
    //buffered recorder test
    /*@objc func startCapture() {
        let recorder = RPScreenRecorder.shared()
        
        recorder.isMicrophoneEnabled = true
        
        recorder.startCapture(handler: <#T##((CMSampleBuffer, RPSampleBufferType, Error?) -> Void)?##((CMSampleBuffer, RPSampleBufferType, Error?) -> Void)?##(CMSampleBuffer, RPSampleBufferType, Error?) -> Void#>, completionHandler: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
        
    }*/
    
    @objc func startRecording() {
        let recorder = RPScreenRecorder.shared()
        
        recorder.isMicrophoneEnabled = true
        
        recorder.startRecording{ [unowned self] (error) in
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(self.stopRecording))
            }
        }
    }
    
    @objc func stopRecording() {
        let recorder = RPScreenRecorder.shared()
        
        recorder.stopRecording { [unowned self] (preview, error) in
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(self.startRecording))
            
            
            
            
            if let unwrappedPreview = preview {
                unwrappedPreview.previewControllerDelegate = self
                self.present(unwrappedPreview, animated: true)
            }
        }
    }
    
    func setupSmileTracker() {
        // Configure and start face tracking session
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run ARSession and set delegate to self
        trackingView.session.run(configuration)
        trackingView.delegate = self
        
        // Add trackingView so that it will run
        view.addSubview(trackingView)
        
        // Add smileLabel to UI
        buildSmileLabel()
    }
    
    func buildSmileLabel() {
        valueLabel.text = ""
        //valueLabel.font = UIFont.systemFontSize(ofSize: 50)
        
        view.addSubview(valueLabel)
        
        // Set constraints
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.numberOfLines = 20
        valueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        valueLabel.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        smileLabel.text = ""
        smileLabel.font = UIFont.systemFont(ofSize: 200)
        
        view.addSubview(smileLabel)
        
        // Set constraints
        smileLabel.translatesAutoresizingMaskIntoConstraints = false
        smileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        smileLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func handleSmile(smileValue: CGFloat, 
                     eyeLeftValue: CGFloat, 
                     eyeRightValue: CGFloat, 
                     mouthFunnelValue: CGFloat,
                     tongueOutValue: CGFloat) {
        
        //debug
        //valueLabel.text = "smile\n" + smileValue.description + "\n\neyeLeft\n" + eyeLeftValue.description + "\n\neyeRight\n" + eyeRightValue.description + "\n\nmouthFunnel\n" + mouthFunnelValue.description + "\n\ntongueOut\n" + tongueOutValue.description
        
        switch smileValue {
        case _ where tongueOutValue > 0.1 && eyeRightValue < 0.6 && eyeLeftValue < 0.6:
            smileLabel.text = "😛"
        case _ where mouthFunnelValue > 0.35:
            smileLabel.text = "😮"
        case _ where eyeRightValue > 0.6 && eyeLeftValue > 0.6:
            smileLabel.text = "😌"
        case _ where eyeRightValue > 0.6 && eyeLeftValue > 0.6 && tongueOutValue > 0.1:
            smileLabel.text = "😝"
        case _ where eyeRightValue > 0.5 && tongueOutValue > 0.1:
            self.smileLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            smileLabel.text = "😜"
        case _ where eyeLeftValue > 0.5 && tongueOutValue > 0.1:
            self.smileLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            smileLabel.text = "😜"
        case _ where eyeLeftValue > 0.6:
            self.smileLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            smileLabel.text = "😉"
        case _ where eyeRightValue > 0.6:
            self.smileLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            smileLabel.text = "😉"
        case _ where smileValue > 0.7:
            smileLabel.text = "😆"
        case _ where smileValue > 0.5:
            smileLabel.text = "😁"
        case _ where smileValue > 0.4:
            smileLabel.text = "😃"
        case _ where smileValue > 0.3:
            smileLabel.text = "😀"
        case _ where smileValue > 0.2:
            smileLabel.text = "🙂"
        default:
            smileLabel.text = "😐"
        }
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Cast anchor as ARFaceAnchor
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Pull left/right smile coefficents from blendShapes
        let leftMouthSmileValue = faceAnchor.blendShapes[.mouthSmileLeft] as! CGFloat
        let rightMouthSmileValue = faceAnchor.blendShapes[.mouthSmileRight] as! CGFloat
        let eyeLeftValue = faceAnchor.blendShapes[.eyeBlinkRight] as! CGFloat
        let eyeRightValue = faceAnchor.blendShapes[.eyeBlinkLeft] as! CGFloat
        let mouthFunnelValue = faceAnchor.blendShapes[.mouthFunnel] as! CGFloat
        let tongueOutValue = faceAnchor.blendShapes[.tongueOut] as! CGFloat

        DispatchQueue.main.async {
            // Update label for new smile value
            self.handleSmile(smileValue: (leftMouthSmileValue + rightMouthSmileValue)/2.0, 
                             eyeLeftValue: eyeLeftValue, 
                             eyeRightValue: eyeRightValue,
                             mouthFunnelValue: mouthFunnelValue,
                             tongueOutValue: tongueOutValue
            )
        }
    }
    
}
