//
//  ShareViewController.swift
//  TiktokStyleApp
//
//  Created by 白石裕幸 on 2021/01/25.
//

import UIKit
import AVKit
import Photos

class ShareViewController: UIViewController {
    
    
    var captionString = String()
    
    var passedUrl = String()
    var player:AVPlayer?
    var playerController:AVPlayerViewController?
    
    
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var backObj: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        backObj.layer.cornerRadius = 25
        backObj.clipsToBounds = true
        
        let notification = NotificationCenter.default
        
        notification.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        notification.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        //完成された動画URlの再生(passedUrl)
        setUPVideoPlayer(url: URL(string: passedUrl)!)
    }
    func setUPVideoPlayer(url:URL){
        
        
        self.view.backgroundColor = UIColor.black
        playerController?.removeFromParent()
        player = AVPlayer(url: url)
        self.player?.volume = 1
        
        playerController = AVPlayerViewController()
        playerController!.view.frame = CGRect(x: 0, y: 88, width: view.frame.size.width, height: 365 )
        playerController?.videoGravity = .resizeAspectFill
        playerController!.showsPlaybackControls = false
        playerController!.player = player!
        self.addChild(playerController!)
        self.view.addSubview(playerController!.view)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
        
        player?.play()
        
    }
    
    //キーボードが上がった時間を計測してその分だけviewをずらす
    @objc func keyboardWillShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
        }
    }
    
    //キーボードが下がったらもとに戻す
    @objc func keyboardWillHide(notification: Notification?) {
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.transform = CGAffineTransform.identity
        }
    }
    
    @objc func playerItemDidReachEnd(_ notification:Notification){
        //繰り返し
        if player != nil{
            //指定した時間に移動する(今回0まで)
            player?.seek(to: CMTime.zero)
            //オーディオプレーヤーの音量 (最大1.0)
            player?.volume = 1
            //再生
            player?.play()
            
        }
        
    }
    
    
    
    @IBAction func savrphot(_ sender: Any) {
        
        PHPhotoLibrary.shared().performChanges { [self] in
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(string: passedUrl)!)
        } completionHandler: { (result, error) in
            
            
            if error != nil{
                print(error.debugDescription)
            }
            
            if result{
                print("保存完了")
                
            }
        }

    }
    
    
    @IBAction func share(_ sender: Any) {
        
        //アクティビティーview
        
        let activityItems = [URL(string: passedUrl) as Any,"\(textView.text!)\n\(captionString)\n#TESTEST"]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityController.popoverPresentationController?.sourceView = self.view
        activityController.popoverPresentationController?.sourceRect = self.view.frame
        self.present(activityController, animated: true, completion: nil)
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        
        //停止
        player?.pause()
        //ホームに戻る
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
}
