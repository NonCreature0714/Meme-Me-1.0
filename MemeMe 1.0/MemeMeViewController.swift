//
//  MemeMeViewController.swift
//  MemeMe 1.0
//
//  Created by William Brubaker on 8/19/16.
//  Copyright © 2016 William Brubaker. All rights reserved.
//

import Foundation
import UIKit

class MemeMeViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePickedView: UIImageView!
    @IBOutlet weak var cameraPickerButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    //instantiate delegates, if necessary
    
    enum SourceSelection: Int {
        case Album = 0, Camera
    }
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSStrokeWidthAttributeName: -5.0,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    ]
    
    override func viewWillAppear(animated: Bool) {
        cameraPickerButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewDidLoad() {
        topTextField.delegate = self
        topTextField.text = "TOP"
        configureText(topTextField)
        
        bottomTextField.delegate = self
        bottomTextField.text = "BOTTOM"
        configureText(bottomTextField)
        
        imagePickedView.image = UIImage(named: "PixelArt")
    }
    
    @IBAction func pickImage(sender: AnyObject) {
        
        let  controller = UIImagePickerController()
        controller.delegate = self
        
        switch sender.tag {
        case SourceSelection.Album.rawValue:
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            print("Album picture selected.")
        case SourceSelection.Camera.rawValue:
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            print("Camera picture selected.")
        default:
            print("Error in pickImageFunction.")
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("imagePickerController called.")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickedView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel called.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.placeholder = nil
        return true
    }*/
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text! == "TOP" || textField.text! == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func configureText(textField: UITextField){
        textField.textAlignment = NSTextAlignment.Center
        textField.defaultTextAttributes = memeTextAttributes
    }
}