//
//  BitcoinAddress.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 8/29/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import Foundation
import UIKit

class  BitcoinAddress: NSCoder  {

	let API_KEY = "SET API KEY HERE."
	let SECRET_PIN = "SET PIN HERE."

	var address = "Error"
	var label = "Error"


	override init() {
		super.init()
	}


	//Uses block.io to create a bitcoin wallet.
	func createProperties(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

		let BASE_URL = "https://block.io/api/v2/get_new_address/"

		let methodArguments = [
			"api_key": API_KEY
			]

		let session = URLSession.shared
		let urlString = BASE_URL + escapedParameters(methodArguments as [String : AnyObject])
		let url = URL(string: urlString)!
		let request = URLRequest(url: url)

		let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
			if let error = downloadError {
				completionHandler(false, "Could not complete the request \(error)")
			} else {
				let parsedResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary
				self.address = (parsedResult.value(forKey: "data") as! NSDictionary).value(forKey: "address") as! String
				self.label = (parsedResult.value(forKey: "data") as! NSDictionary).value(forKey: "label") as! String
				completionHandler(true, nil)
			}
		}) 
		task.resume()
	}

	//Used when the properties already exist and are being restored from NSCoding.
	func setProperties(_ address: String, label: String) {
		self.address = address
		self.label = label
	}


	//Get the balance of the Bitcoin address.
	func getBalance(_ balanceDisplay: UILabel, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

		//Sometimes this function is called before a bitcoin Address can be created.
		if address == "Error" {
			completionHandler(true, nil)
		} else {

			let BASE_URL = "https://blockchain.info/address/\(BitcoinAddress.sharedInstance().address)"

			let methodArguments = [
				"format": "json",
				]

			let session = URLSession.shared
			let urlString = BASE_URL + self.escapedParameters(methodArguments as [String : AnyObject])
			let url = URL(string: urlString)!
			let request = URLRequest(url: url)

			let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
				if downloadError != nil {

					//Return a friendly error message.
					completionHandler(false, "Cannot Connect to the Network")

				} else {
					let parsedResult = (try! JSONSerialization.jsonObject(with: data!, options:		JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary
					let balance = (parsedResult["final_balance"]! as AnyObject).stringValue
					DispatchQueue.main.async(execute: { () -> Void in
						balanceDisplay.text = balance
					});
					completionHandler(true, nil)
				}
			}) 
			task.resume()
		}
	}


	//Send bitcoin to an external address.
	func sendBitcoin(_ address: String, amount: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

		let BASE_URL = "https://block.io/api/v2/withdraw_from_addresses/"

		let methodArguments = [
			"api_key": API_KEY,
			"from_addresses": BitcoinAddress.sharedInstance().address,
			"to_addresses": address,
			"amounts": amount,
			"pin": SECRET_PIN
		]

		let session = URLSession.shared
		let urlString = BASE_URL + escapedParameters(methodArguments as [String : AnyObject])
		let url = URL(string: urlString)!
		let request = URLRequest(url: url)

		let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in

			//Failure due to network issues.
			if downloadError != nil {
				completionHandler(false, "Cannot connect to the network.")

			} else {
				let parsedResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary

				//Failed bitcoin transaction.
				if parsedResult["status"] as! String == "fail" {
					completionHandler(false, (parsedResult.value(forKey: "data") as! NSDictionary).value(forKey: "error_message") as! String?)

				//Success.
				} else {
					completionHandler(true, nil)
				}
			}
		}) 
		task.resume()
	}


	/* Helper function: Given a dictionary of parameters, convert to a string for a url */
	func escapedParameters(_ parameters: [String: AnyObject]) -> String {

		var urlVars = [String]()

		for (key, value) in parameters {

			/* Make sure that it is a string value */
			let stringValue = "\(value)"

			/* FIX: Replace spaces with '+' */
			let replaceSpaceValue = stringValue.replacingOccurrences(of: " ", with: "+", options: NSString.CompareOptions.literal, range: nil)

			/* Append it */
			urlVars += [key + "=" + "\(replaceSpaceValue)"]
		}

		return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
	}


	//The bitcoin address information is persisted with NSCoding, not Core Data:

	//Required for the class to conform to the NSCoding protocol.
	@objc func encodeWithCoder(_ aCoder: NSCoder!) {
		aCoder.encode(address, forKey:"address")
		aCoder.encode(label, forKey:"label")
	}


	//Required for the class to conform to the NSCoding protocol.
	@objc init(coder aDecoder: NSCoder!) {
		address = aDecoder.decodeObject(forKey: "address") as! String
		label = aDecoder.decodeObject(forKey: "label") as! String
	}


	//Allows other classes to reference a common instance of this object.
	class func sharedInstance() -> BitcoinAddress {

		struct Singleton {
			static var sharedInstance = BitcoinAddress()
		}
		return Singleton.sharedInstance
	}
}
