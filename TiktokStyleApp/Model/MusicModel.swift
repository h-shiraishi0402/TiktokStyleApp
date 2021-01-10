//
//  MusicModel.swift
//  Swift6Tiktok1
//
//  Created by Yuta Fujii on 2020/09/16.
//

import Foundation
import SwiftyJSON
import Alamofire


protocol MusicProtocol {
    
    //規則
    func catchData(count:Int)
    
}

class MusicModel{
    
//    //アーティスト名
//    var artistName:String?
//    //曲名
//    var trackCensoredName:String?
//    //音源URL
//    var preViewUrl:String?
//    //ジャケ写
//    var artworkUrl100:String?
    
    var artistNameArray = [String]()
    var trackCensoredNameArray = [String]()
    var preViewUrlArray = [String]()
    var artworkUrl100Array = [String]()
    
    var musicDelegate:MusicProtocol?
    
    //通信
    
    //JSON解析
    
    func setData(resultCount:Int,encodeUrlString:String){
        
        //通信
        AF.request(encodeUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            
            //ここ
            self.artistNameArray.removeAll()
            self.trackCensoredNameArray.removeAll()
            self.preViewUrlArray.removeAll()
            self.artworkUrl100Array.removeAll()
            
            print(response)
            
            switch response.result{
            
              case .success:
                
                do {
                    let json:JSON = try JSON(data: response.data!)
                    for i in 0...resultCount - 1{
                        print(i)
                        
                        if json["results"][i]["artistName"].string == nil{
                            print("ヒットしませんでした。")
                            return
                            
                        }
                        
                        self.artistNameArray.append(json["results"][i]["artistName"].string!)
                        self.trackCensoredNameArray.append(json["results"][i]["trackCensoredName"].string!)
                        self.preViewUrlArray.append(json["results"][i]["previewUrl"].string!)
                        self.artworkUrl100Array.append(json["results"][i]["artworkUrl100"].string!)
                    
                    
                    }
                    
                    //全てのデータが取得完了している状態
                    self.musicDelegate?.catchData(count: 1)
                    
                } catch  {
                }
                break
              case .failure(_): break
                
            }
            
        }
        //ここが呼ばれる
        
    }
    
    
}
