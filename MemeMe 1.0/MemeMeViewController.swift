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
    
    //MARK: IBOutlets.
    @IBOutlet weak var imagePickedView: UIImageView!
    @IBOutlet weak var cameraPickerButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    
    
    @IBOutlet weak var pickerToolbar: UIToolbar!
    //@IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelToolbarButton: UIBarButtonItem!
    @IBOutlet weak var shareOrCancelToolbar: UIToolbar!
    
    
    //MARK: Class members, enums, and attributes.
    var meme = Meme()
    enum SourceSelection: Int { case Album = 0, Camera }
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSStrokeWidthAttributeName: -5.0,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    ]
    
    //MARK: Overriden UIViewController methods.
    override func viewWillAppear(animated: Bool) {
        cameraPickerButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subcribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        topTextField.delegate = self
        bottomTextField.delegate = self
        configureUI()
    }
    
    //MARK: IBActions.
    @IBAction func pickImage(sender: AnyObject) {
        
        let  controller = UIImagePickerController()
        controller.delegate = self
        
        switch sender.tag {
        case SourceSelection.Album.rawValue:
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        case SourceSelection.Camera.rawValue:
            controller.sourceType = UIImagePickerControllerSourceType.Camera
        default:
            let alertController = UIAlertController()
            alertController.title = "Meme Me Error"
            alertController.message = "There was an error while choosing an image."
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {action in self.dismissViewControllerAnimated(true, completion: nil)})
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        presentViewController(controller, animated: true, completion: nil)
        shareButton.enabled = true
        shareButton.hidden = false
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        save()
        let activityController = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(sender: AnyObject) {
        reset()
    }
    
    
    //MARK: UIImagePickerDelegate methods.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickedView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate methods.
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        let textSize: CGSize = newText.sizeWithAttributes([NSFontAttributeName: textField.font!])
        return textSize.width < textField.bounds.size.width
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
    
    
    //MARK: UIConfiguration methods.
    func configureUI() {
        configureText(topTextField)
        configureText(bottomTextField)
        hideShare(true)
    }
    
    func configureText(textField: UITextField){
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
        switch textField.tag {
        case 0:
            textField.text = "TOP"
        case 1:
            textField.text = "BOTTOM"
        default:
            textField.text = "ERROR"
            let alertController = UIAlertController()
            alertController.title = "Meme Me Error"
            alertController.message = "There was an error while configuring the app."
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {action in self.dismissViewControllerAnimated(true, completion: nil)})
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func hideUIElements(hide: Bool) {
        pickerToolbar.hidden = hide
        hideShare(hide)
        shareOrCancelToolbar.hidden = hide
    }
    
    //MARK: Meme generation supporting methods.
    func generateMemedImage() -> UIImage
    {
        hideUIElements(true)
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        hideUIElements(false)
        
        return memedImage
    }
    
    func hideShare(hide: Bool){
        shareButton.hidden = hide
        shareButton.enabled = !hide
    }
    
    func save() {
        meme = Meme(topTextField: topTextField.text, bottomTextField: bottomTextField.text, originalImage: imagePickedView.image, memedImage: generateMemedImage())
    }
    
    func reset(){
        imagePickedView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
    }
}