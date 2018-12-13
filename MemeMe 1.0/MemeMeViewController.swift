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
    @IBOutlet weak var cancelToolbarButton: UIBarButtonItem!
    @IBOutlet weak var shareOrCancelToolbar: UIToolbar!
    
    
    //MARK: Class members, enums, and attributes.
    var meme = Meme()
    enum SourceSelection: Int { case album = 0, camera }
    let memeTextAttributes = [
        convertFromNSAttributedStringKey(NSAttributedString.Key.strokeColor) : UIColor.black,
        convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.white,
        convertFromNSAttributedStringKey(NSAttributedString.Key.strokeWidth): -5.0,
        convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    ] as [String : Any]
    
    //MARK: Overriden UIViewController methods.
    override func viewWillAppear(_ animated: Bool) {
        cameraPickerButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
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
            controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        case SourceSelection.camera.rawValue:
            controller.sourceType = UIImagePickerController.SourceType.camera
        default:
            let alertController = UIAlertController()
            alertController.title = "Meme Me Error"
            alertController.message = "There was an error while choosing an image."
            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {action in self.dismiss(animated: true, completion: nil)})
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
        present(controller, animated: true, completion: nil)
        
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
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
        let textSize: CGSize = newText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): textField.font!]))
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
        textField.defaultTextAttributes = convertToNSAttributedStringKeyDictionary(memeTextAttributes)
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
            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {action in self.dismiss(animated: true, completion: nil)})
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
