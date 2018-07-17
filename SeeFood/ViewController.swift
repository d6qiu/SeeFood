//
//  ViewController.swift
//  SeeFood
//
//  Created by wenlong qiu on 7/16/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
//1
import CoreML
import Vision // process images and allow use images with coreml without writing complicted code

//2
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //4
    @IBOutlet weak var imageView: UIImageView!
    
    //5
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //6 imagepicker is when user picks an image
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary //or .camera to specify camera as the source of image, how user picks an image
        imagePicker.allowsEditing = false //allows user to edit images or not
    }
    //8 tells delege or an event triggers when user has picked an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) { // info contains the image that user pickerd
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else { fatalError("could not convert to CIImage")}// core image for coreml
            detect(image: ciimage)
        }//original unedited image selected by user, as? retunrs nil if cant perform conversion
        
        
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    //9 method process or classifies ciimage
    func detect(image: CIImage) {
        //VNcoreModel from vision framework that perform image analysis request using core ml model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{ fatalError("loading coreml model fail ")} //create container for coreml model, look for class and has var model //try? makes it nil if fail, if fails u want error message, so guard
        
        //make a request to use model to process image
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation] else {fatalError("model fail to process image")} //result will be an array of obseravations like 85% confident that this is keyboard, 70% confident that this is type  writer
            
            //10
            if let firstResult = result.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                }
                else {
                    self.navigationItem.title = "Not Hotdog!" //even without internet still works
                }
            }
            
        } //classfication information/observation after iamge analysis request
        
        
        let handler = VNImageRequestHandler(ciImage: image) //object that perform request on a single image
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    //3
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        //7 present camera as a viewcontroller to user, includes photo album
        present(imagePicker, animated: true, completion: nil)
    }
    
}

