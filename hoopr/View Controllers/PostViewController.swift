//
//  PostViewController.swift
//  hoopr
//
//  Created by Paul Narcisse on 12/30/17.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit
import AVFoundation
import ImagePicker

class PostViewController: UIViewController {
    
   
    @IBOutlet weak var removeButton: UIBarButtonItem!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    var selectedImage: UIImage?
    var videoUrl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        
       navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Top Bar1"), for: .default)
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        handlePost()
        clean()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    func handlePost() {
        if selectedImage != nil {
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = .orange
        } else {
            self.shareButton.isEnabled = false
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }

    
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
    
        ProgressHUD.show("Waiting...", interaction: false)
        view.endEditing(true)
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            print("size: \(profileImg.size)")
            let ratio = profileImg.size.width / profileImg.size.height
            HelperService.uploadDataToServer(data: imageData, videoUrl: videoUrl, ratio: ratio, caption: captionTextView.text!, onSuccess: {
                self.clean()
                self.tabBarController?.selectedIndex = 0
                self.clean()
            })
    } else {
            ProgressHUD.showError("Image can't be empty")
        }
    }
  
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    
    func clean() {
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "default-placeholder-300x300")
        self.selectedImage = nil
}


    @IBAction func cameraBtn_TouchUpInside(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "Camera_Segue", sender: nil)
        })
        let saveAction = UIAlertAction(title: "Record", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "Record_Segue", sender: nil)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
       self.present(optionMenu, animated: true, completion: nil)
    }
}


extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        print(info)
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            if let thumnailImage = self.thumbnailImageForFileUrl(videoUrl) {
                selectedImage = thumnailImage
                photo.image = thumnailImage
                self.videoUrl = videoUrl
            }
        }
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            videoUrl = nil
            selectedImage = image
            photo.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(6, 3), actualTime: nil)
            return UIImage(cgImage: thumnailCGImage)
        } catch let err {
            print(err)
        }
        return nil
    }
}


