//
//  ViewController.swift
//  VideoTest
//
//  Created by Zachary Wooding on 2/14/19.
//  Copyright © 2019 Zachary Wooding. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender:Any?){
        let destination = segue.destination as! AVPlayerViewController
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        if let movieURL = url{destination.player = AVPlayer(url:movieURL)
            
        }
    }
    
    func playerViewController(_ playerViewController:AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping(Bool)->Void){
    let currentViewController = navigationController?.topViewController
        if currentViewController != playerViewController {
            if let topViewController = navigationController?.topViewController{
                topViewController.present(playerViewController, animated:true, completion: {();
                completionHandler(true)})
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

