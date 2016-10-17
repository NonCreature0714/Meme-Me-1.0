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
    enum SourceSelection: Int { case album = 0, camera }
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSStrokeWidthAttributeName: -5.0,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    ] as [String : Any]
    
    //MARK: Overriden UIViewController methods.
    override func viewWillAppear(_ animated: Bool) {
        cameraPickerButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        subcribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        topTextField.delegate = self
        bottomTextField.delegate = self
        configureUI()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //MARK: IBActions.
    @IBAction func pickImage(_ sender: AnyObject) {
        
        let  controller = UIImagePickerController()
        controller.delegate = self
        
        switch sender.tag {
        case SourceSelection.album.rawValue:
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case SourceSelection.camera.rawValue:
            controller.sourceType = UIImagePickerControllerSourceType.camera
        default:
            let alertController = UIAlertController()
            alertController.title = "Meme Me Error"
            alertController.message = "There was an error while choosing an image."
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {action in self.dismiss(animated: true, completion: nil)})
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
        present(controller, animated: true, completion: {
            action in
            controller.prefersStatusBarHidden
        })
        shareButton.isEnabled = true
        shareButton.isHidden = false
    }
    
    @IBAction func shareMeme(_ sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { type, completed, returnedItems, error -> Void in
            if completed {
                self.save()
            }
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(_ sender: AnyObject) {
        reset()
    }
    
    
    //MARK: UIImagePickerDelegate methods.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickedView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate methods.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        let textSize: CGSize = newText.size(attributes: [NSFontAttributeName: textField.font!])
        return textSize.width < textField.bounds.size.width
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text! == "TOP" || textField.text! == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: UIConfiguration methods.
    func configureUI() {
        configureText(topTextField)
        configureText(bottomTextField)
        hideShare(true)
    }
    
    func configureText(_ textField: UITextField){
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
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
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {action in self.dismiss(animated: true, completion: nil)})
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func hideUIElements(_ hide: Bool) {
        pickerToolbar.isHidden = hide
        hideShare(hide)
        shareOrCancelToolbar.isHidden = hide
    }
    
    
    //MARK: Meme generation supporting methods.
    func generateMemedImage() -> UIImage
    {
        hideUIElements(true)
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideUIElements(false)
        
        return memedImage
    }
    
    func hideShare(_ hide: Bool){
        shareButton.isHidden = hide
        shareButton.isEnabled = !hide
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
