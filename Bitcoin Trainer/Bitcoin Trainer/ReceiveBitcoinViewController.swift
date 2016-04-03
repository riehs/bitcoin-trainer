//
//  ReceiveBitcoinViewController.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 8/29/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit

class ReceiveBitcoinViewController: UIViewController {

    @IBOutlet weak var addressDisplay: UITextField!
    @IBOutlet weak var imgQRCode: UIImageView!

    @IBAction func dimissReceiveBitcoin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

	var qrCodeImage: CIImage!

	override func viewDidLoad() {
		super.viewDidLoad()

		addressDisplay.text = BitcoinAddress.sharedInstance().address

		//Convert the Bitcoin address to a QR code.
		let data = addressDisplay.text!.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)

		let filter = CIFilter(name: "CIQRCodeGenerator")

		filter!.setValue(data, forKey: "inputMessage")
		
		//The "Q" represents the level of error-correction data included in the QR code.
		filter!.setValue("Q", forKey: "inputCorrectionLevel")

		qrCodeImage = filter!.outputImage

		//Determine appropriate scale factor for image.
		let scaleX = imgQRCode.frame.size.width / qrCodeImage.extent.size.width
		let scaleY = imgQRCode.frame.size.height / qrCodeImage.extent.size.height

		//Apply scale factor to image.
		let transformedImage = qrCodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))

		//Convert the Core Image to a UIImage.
		imgQRCode.image = UIImage(CIImage: transformedImage)
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
