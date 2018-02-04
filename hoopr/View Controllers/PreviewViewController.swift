//
//  PreviewViewController.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/27/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    @IBOutlet weak var photo: UIImageView!
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = image
        
        // Do any additional setup after loading the view.
    }
    @IBAction func save(_ sender: Any) {
        guard let imageToSave = image else {
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        dismiss(animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 2
    
    }
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
