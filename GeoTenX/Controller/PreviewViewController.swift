//
//  PreviewViewController.swift
//  GeoTenX
//
//  Created by saadhvi on 8/28/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    var mergeImage: UIImage?
    @IBOutlet weak var MergeImageView: UIImageView!
  
    @IBOutlet weak var buttonsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //combine the two images
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        MergeImageView.image = mergeImage
        buttonsView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        if let composeViewController = self.navigationController?.viewControllers[2] {
            print(composeViewController)
            self.navigationController?.popToViewController(composeViewController, animated: true)
        }
    }
    @IBAction func UsePhotoBtnPressed(_ sender: Any) {
        //save the photo and return..
        if let composeViewController = self.navigationController?.viewControllers[2] {
            print(composeViewController)
            self.navigationController?.popToViewController(composeViewController, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
