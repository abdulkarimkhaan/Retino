//
//  ViewController.swift
//  picturetoserver
//
//  Created by Abdul  Karim Khan on 19/06/2019.
//  Copyright © 2019 Abdul  Karim Khan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageStatus: UILabel!
    var img = UIImage()

    var imagePickerController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.isUserInteractionEnabled = true;
      
    }

    @IBAction func uploadImage(_ sender: Any) {
        uploadImage(image: img)
    }
    @IBAction func chooseImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            picker.dismiss(animated: false, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.imageView.image = image
                self.img = image
            })
        }
        imageStatus.text = "Image Selected"
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(image: UIImage) -> Void{
        //Convert the image to a data blob
        guard let png = image.pngData() else{
            print("error")
            return
        }
        
        //Set up a network request
        let url = URL(string: "http://192.168.8.102:5000/api/test")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(png.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = png
        // Figure out what the request is making and the encoding type...
        
        //Execute the network request
        let upload = URLSession.shared.uploadTask(with: request as URLRequest, from: png) { (data: Data!, response: URLResponse?, error: Error?) -> Void in
            //What you want to do when the upload succeeds or fails
            if(error==nil)
            {
                print("no error")
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
                let alert = UIAlertController(title: "Retinopathy Result", message: Optional("\(String(describing: responseString))"), preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }

        }
        
        upload.resume()
        
    }
}

