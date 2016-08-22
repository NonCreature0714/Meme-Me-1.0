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
    var meme = Meme()
    
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
        subcribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeToKeyboardNotifications()
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
    /** 
     *
     *Seems most of the actions for saving/sharing are similar... lets trim it down!
     */
    //vvvvvv
    //vvvvvv
    @IBAction func makeMeme(sender: AnyObject) {
        //TODO: finish it
        saveMeme()
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        //TODO: finish it
    }
    
    @IBAction func saveMeme(sender: AnyObject) {
        saveMeme()
    }
        
    func saveMemeToPhotoLibrary(image: UIImage!) {
        //takes generated meme image and stores in Photolibrary
    }
    //^^^^^^
    //^^^^^^
    func saveMeme() {
        meme = Meme(topTextField: topTextField.text, bottomTextField: bottomTextField.text, originalImage: imagePickedView.image, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage
    {
        //TODO: hide navigation and toolbar
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //TOOD: show navigation and toolbar
        
        return memedImage
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