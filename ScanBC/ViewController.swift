//
//  ViewController.swift
//  ScanBC
//
//  Ref: https://www.raywenderlich.com/163445/tesseract-ocr-tutorial-ios
//
//  Created by Siyang Zhang on 2/21/18.
//  Copyright © 2018 Siyang Zhang. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var phone: String = ""
    var address: String = ""
    var link: String = ""
    var output: String = ""
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.textView.dataDetectorTypes = UIDataDetectorTypes.all;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Take Closeup Pics
    @IBAction func takePhoto(_sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Validate Personal Info
    @IBAction func getInfo(_sender: Any) {
        if let input = textView.text {
    
            // Do some validations
            let detectorAllType = try! NSDataDetector(types: NSTextCheckingAllSystemTypes)
            let attributeString = NSMutableAttributedString(string: input, attributes: nil)
            let range = NSRange(location: 0, length: input.count)
            
            detectorAllType.enumerateMatches(in: attributeString.string, options: [], range: range) { (result, flags, _) in
                
                // Detect Phone Number
                if((result?.phoneNumber) != nil) {
                    phone = (result?.phoneNumber)!
                    print("phone is found")
                }

                // Detect URL
                if((result?.url) != nil) {
                    link = (result?.url?.absoluteString)!
                    print("link is found")
                }
                
                // Detect other components
                
            }
            output = "\n\nPhone: " + phone + "\n\nLink: " + link
            textView.text = output
        } else {
            print("myString has no value")
        }
    }
    
    // Process Token Image
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let scaledImage = selectedPhoto.scaleImage(1000) {
            
            textView.text = "Hold on for a second"
            dismiss(animated: true, completion: {
                self.performImageRecognition(scaledImage)
            })
        }
    }
    
    // Tesseract Image Recognition
    func performImageRecognition(_ image: UIImage) {
        
        if let tesseract = G8Tesseract(language: "eng") {
            
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .auto
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            textView.text = tesseract.recognizedText
        }
    }
}

// MARK: - UIImage extension
extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

