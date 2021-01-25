//
//  SetUpViewController.swift
//  TiktokStyleApp
//
//  Created by 白石裕幸 on 2021/01/09.
//

import UIKit
import SwiftyCam
import AVFoundation
import MobileCoreServices

class SetUpViewController: SwiftyCamViewController,SwiftyCamViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    
    @IBOutlet var captureButton: SwiftyRecordButton!
    @IBOutlet var flipCameraButton: UIButton!
    
    var videoURL:URL?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldPrompToAppSettings = true
        
        //SwiftyCamViewControllerDelegate
        cameraDelegate = self
        
        //SwiftyCamButtonが使用されている場合の最大ビデオ時間
        maximumVideoDuration = 20.0
        
        //撮影データをデバイスの向きに合わせるかどうかの設定
        shouldUseDeviceOrientation = false
        
        //
        allowAutoRotate = false
        //撮影時に音を入れるかどうか
        audioEnabled = false
        //
//        captureButton.buttonEnabled = true
//        //
//        captureButton.delegate = self
        //スワイプでズーム可能にする？
        swipeToZoomInverted = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ナビゲーションを消す
        navigationController?.isNavigationBarHidden = true
        
        
    }
    
    
    
    @IBAction func openAlbum(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
    
        imagePicker.delegate = self
        //
        imagePicker.sourceType = .savedPhotosAlbum
        //ここで動画を選択(動画のみ)
        imagePicker.mediaTypes = ["public.movie"]
        //取得した画像を編集するかどうか
        imagePicker.allowsEditing = false
        //動画を高画質で保存する
        imagePicker.videoQuality = .typeHigh
        //
        present(imagePicker, animated: true, completion: nil)
        
        
        
    }
    
    //キャンセルを行った時
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //ユーザーが選択したメディアに関する情報を取得するために使用するキー。
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        //URLで動画を取得
        let mediaUrl = info[.mediaURL] as? URL
        videoURL = mediaUrl
        
        picker.dismiss(animated: true, completion: nil)
        
        //情報を取得したら画面遷移
       // let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyboard?.instantiateViewController(withIdentifier: "editVC") as! EditViewController
        editVC.videoUrl = self.videoURL
        navigationController?.pushViewController(editVC, animated: true)
        
        
    }
    
    
    //*****************githubから参照***************************************↓
    
    override var prefersStatusBarHidden: Bool {
           return true
       }

       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           captureButton.delegate = self
       }
       
       func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
           print("Session did start running")
           captureButton.buttonEnabled = true
       }
       
       func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
           print("Session did stop running")
           captureButton.buttonEnabled = false
       }
       

       func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
           print("Did Begin Recording")
           captureButton.growButton()
           hideButtons()
       }

       func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
           print("Did finish Recording")
           captureButton.shrinkButton()
           showButtons()
       }

       func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
           
           //ここで撮影後生成されたURLが入っていくる
           print(url.debugDescription)

           //値を渡しながら画面遷移
           let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
           let editVC = storyboard.instantiateViewController(withIdentifier: "editVC") as! EditViewController
           videoURL = url
           editVC.videoUrl = videoURL
           self.navigationController?.pushViewController(editVC, animated: true)
           
       }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
           print("Did focus at point: \(point)")
           focusAnimationAt(point)
       }
       
       func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
           let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
           let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
           alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
           present(alertController, animated: true, completion: nil)
       }

       func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
           print("Zoom level did change. Level: \(zoom)")
           print(zoom)
       }

       func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
           print("Camera did change to \(camera.rawValue)")
           print(camera)
       }
       
       func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
           print(error)
       }

       @IBAction func cameraSwitchTapped(_ sender: Any) {
           switchCamera()
       }
       
       
       func hideButtons() {
           UIView.animate(withDuration: 0.25) {
               self.flipCameraButton.alpha = 0.0
           }
       }
       func showButtons() {
           UIView.animate(withDuration: 0.25) {
               self.flipCameraButton.alpha = 1.0
           }
       }
    
    func focusAnimationAt(_ point: CGPoint) {
         let focusView = UIImageView(image:  #imageLiteral(resourceName: "focus"))
         focusView.center = point
         focusView.alpha = 0.0
         view.addSubview(focusView)
         
         UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
             focusView.alpha = 1.0
             focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
         }) { (success) in
             UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                 focusView.alpha = 0.0
                 focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
             }) { (success) in
                 focusView.removeFromSuperview()
             }
         }
     }

    
    //*****************githubから参照***************************************↑
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
