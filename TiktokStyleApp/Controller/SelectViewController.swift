//
//  SelectViewController.swift
//  TiktokStyleApp
//
//  Created by 白石裕幸 on 2021/01/25.
//

import UIKit
import SDWebImage
import AVFoundation
import SwiftVideoGenerator//合成するときに

class SelectViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,MusicProtocol {
    
    
    
    
    @IBOutlet var searchObj: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchTextfield: UITextField!
    
    var musicModel = MusicModel()
    var player:AVAudioPlayer?
    var videoPath = String()
    var passedURL:URL?
    
    //遷移元から処理を受け取るクロージャーのプロパティーの用意
    var resultHandler:((String,String,String)->Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchTextfield.delegate = self
        searchObj.layer.cornerRadius = 25
        searchObj.clipsToBounds = true
        
        
    }
    
    
    func catchData(count: Int) {
        if count == 1{
            tableView.reloadData()
        }
    }
    
    
    func refleshData(){
        
        
        if searchTextfield.text?.isEmpty != nil{
            
            //itunes search API
            let musicUrlString = "https://itunes.apple.com/search?term=\(String(describing: searchTextfield.text!))&entity=song&country=jp"
            
            //URLエンコーディング
            let encodeUrlString:String = musicUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            musicModel.musicProtocol = self
            
            //音源関係の取得
            musicModel.setData(resultCount: 50, encodeUrl: encodeUrlString)
            //キーボードを閉じる
            searchTextfield.resignFirstResponder()
            
            
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicModel.artistNameArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //ハイライトをさせない
        cell.isHighlighted = false
        //contentViewの各々に追加する
        let artWorkImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let musicNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        let artistNameLabel = cell.contentView.viewWithTag(3) as! UILabel
        
        artWorkImageView.sd_setImage(with: URL(string: musicModel.artworkUrl100Array[indexPath.row]), completed: nil)
        musicNameLabel.text = musicModel.truckCensoredNameArray[indexPath.row]
        artistNameLabel.text = musicModel.artistNameArray[indexPath.row]
        
        
        
        let fabButton = UIButton(frame: CGRect(x: 320, y: 25, width: 40, height: 40))
        fabButton.setImage(UIImage(named: "fav"), for: .normal)
        fabButton.addTarget(self, action: #selector(fabButtonTap(_:)), for: .touchUpInside)
        fabButton.tag = indexPath.row
        fabButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.contentView.addSubview(fabButton)
        
        let playButton = UIButton(frame: CGRect(x: 20, y: 10, width: 100, height: 76))
        playButton.addTarget(self, action: #selector(playButtonTap(_:)), for: .touchUpInside)
        
        playButton.setImage(UIImage(named: "play"), for: .normal)
        playButton.tag = indexPath.row
        cell.contentView.addSubview(playButton)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height / 7
    }
    
    
    
    @objc func playButtonTap(_ sender:UIButton){
        //音楽を止める
        
        if player?.isPlaying == true{
            player?.stop()
        }
        
        let url = URL(string: musicModel.previewUrlArray[sender.tag])
        downLoadMusicURL(url: url!)
        
        
    }
    //音源のダウンロード
    func downLoadMusicURL(url:URL){
        var downLoadTask:URLSessionDownloadTask
        downLoadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [self](url, respones, error) in
            play(url: url!)
            
        })
        
        downLoadTask.resume()
    }
    
    func play(url:URL){
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            //プレイのためのjunnbi
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
        } catch let error as NSError {
            
            print(error.debugDescription)
            
        }
        
    }
    
    
    //動画と音楽を合成
    @objc func fabButtonTap(_ sender:UIButton){
        //音楽が流れている場合は止める
        if player?.isPlaying == true{
            player?.stop()
        }
        //ローディング画面を出す
        LoadingView.lockView()
        //音声URL、動画URLの合成
        VideoGenerator.fileName = "newAoudioMovie"
        VideoGenerator.current.mergeVideoWithAudio(videoUrl: passedURL!, audioUrl:URL(string: self.musicModel.previewUrlArray[sender.tag])!) { [self] (results) in
            //ローディングを止める
            LoadingView.unlockView()
            
            
            switch results{
            case .success(let url):
                videoPath = url.absoluteString
                if let handler = resultHandler{
                    
                    handler(videoPath,musicModel.artistNameArray[sender.tag],musicModel.truckCensoredNameArray[sender.tag])
                    
                    
                }
                dismiss(animated: true, completion: nil)
            case .failure(let error):
                print(error)
            }
            
            
            
        }
        
        
        
        
        
        //合成ができたらアタイを渡しながら、画面を戻る
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        refleshData()
        textField.resignFirstResponder()
        return true
        
    }
    
    @IBAction func searchAction(_ sender: Any) {
        refleshData()
        
        
    }
    
}
