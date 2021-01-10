//
//  EditViewController.swift
//  TiktokStyleApp
//
//  Created by 白石裕幸 on 2021/01/10.
//

import UIKit
import AVKit

class EditViewController: UIViewController {
    
    
    var videoUrl:URL?
    var playerContrller:AVPlayerViewController?
    var payer:AVPlayer?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    
    
    
    
    func setupVideoPlayer(url:URL){
        
        
        
        
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
