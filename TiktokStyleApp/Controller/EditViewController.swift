//
//  EditViewController.swift
//  TiktokStyleApp
//
//  Created by 白石裕幸 on 2021/01/10.
//

import UIKit
import AVKit




/*やリたこと
 撮影された動画のURLを取得
 
 */


class EditViewController: UIViewController {
    
    
    var videoUrl:URL?
    var playerContrller:AVPlayerViewController?
    var player:AVPlayer?
    
    var captionString = String()
    var passedUrl = String()
   

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
      

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ナビゲーションバーを非表示
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupVideoPlayer(url: videoUrl!)
        
    }
    
    
    
    
    func setupVideoPlayer(url:URL){
        //親との親子関係を切る
        playerContrller?.removeFromParent()
        //空にする
        player = nil
        
        player = AVPlayer(url: url)
        player?.volume = 1
    
        //viewの背景色
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //初期化
        playerContrller = AVPlayerViewController()
        //アスペクト比を維持しつつ、プレイヤーレイヤーいっぱいに表示
        playerContrller?.videoGravity = .resizeAspectFill
        //
        playerContrller?.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 100)
        //再生コントロールを表示するかどうか
        playerContrller?.showsPlaybackControls = false
        //
        playerContrller?.player = player!
        //
        addChild(playerContrller!)
        //
        view.addSubview((playerContrller?.view)!)
        //終わりに近づいていることを知らせる
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        //addObserverについてhttps://qiita.com/mono0926/items/754c5d2dbe431542c75e
        
        //キャンセル
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
        cancelButton.setImage(UIImage(named: "cancel"), for: UIControl.State())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        //再生
        player?.play()
        
    }
    
    @objc func cancel(){
        //1つ前のViewControllerに戻る
        navigationController?.popViewController(animated: true)
        /*
         popToViewController(animated: Bool)    指定した数字分前のViewControllerに戻る
         popToRootViewController(animated: Bool)    １番最初のViewControllerに戻る
         */
        
        
        
        
        
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
    
    //値を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "selectVC"{
            
            let selectVC = segue.destination as! SelectViewController
            selectVC.passedURL = videoUrl
            //メインスレッド(非同期処理)
            DispatchQueue.global().async {
                //この段階のURLは合成された動画のURL
                selectVC.resultHandler = { [self] url, text1, text2 in
                    
                    setupVideoPlayer(url: URL(string:url)!)
                    captionString = text1 + "\n" + text2
                    passedUrl = url
                }
                
            }
            
        }else if segue.identifier == "shareVC"{
            let  shareVC = segue.destination as! ShareViewController
            shareVC.captionString = self.captionString
            shareVC.passedUrl = self.passedUrl
            
        }
        
        
        
    }

    @IBAction func next(_ sender: Any) {
        
        if captionString.isEmpty != true{
            //止める
            player?.pause()
            performSegue(withIdentifier: "shareVC", sender: nil)
            
        }else{
            print("てsと")
            
        }
        
        
    }
    
    @IBAction func showSelectVc(_ sender: Any) {
        performSegue(withIdentifier: "selectVC", sender: nil)
    }
    
    
}
