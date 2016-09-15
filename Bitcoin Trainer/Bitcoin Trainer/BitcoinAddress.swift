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

	var address = "Error"
	var guid = "Error"
	var password = "Error"


	override init() {
		super.init()
	}


	//Uses blockchain.info to create a bitcoin wallet.
	func createProperties(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

		password = randomStringWithLength(10)

		let BASE_URL = "https://blockchain.info/api/v2/create_wallet"

		let methodArguments = [
			"api_code": API_KEY,
			"password": password,
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
				self.address = (parsedResult["address"] as? String)!
				
				self.guid = (parsedResult["guid"] as? String)!
				completionHandler(true, nil)
			}
		}) 
		task.resume()
	}

	//Used when the properties already exist and are being restored from NSCoding.
	func setProperties(_ password: String, address: String, guid: String) {
		self.password = password
		self.address = address
		self.guid = guid
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

		let BASE_URL = "https://blockchain.info/merchant/\(BitcoinAddress.sharedInstance().guid)/payment"

		let methodArguments = [
			"api_code": API_KEY,
			"password": BitcoinAddress.sharedInstance().password,
			"to": address,
			"amount": amount
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
				if parsedResult["message"] == nil {
					completionHandler(false, "Cannot send Bitcoin. Confirm that the address is correct and your balance is high enough to allow for a 10000 satoshi fee.")

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


	//Creates a password to send to blockchain.info.
	//http://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
	func randomStringWithLength(_ length: Int) -> String {

		let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let allowedCharsCount = UInt32(allowedChars.characters.count)
		var randomString = ""

		for _ in (0..<length) {
			let randomNum = Int(arc4random_uniform(allowedCharsCount))
			let newCharacter = allowedChars[allowedChars.characters.index(allowedChars.startIndex, offsetBy: randomNum)]
			randomString += String(newCharacter)
		}

		return randomString
	}


	//The bitcoin address information is persisted with NSCoding, not Core Data:
	
	//Required for the class to conform to the NSCoding protocol.
	func encodeWithCoder(_ aCoder: NSCoder!) {
		aCoder.encode(password, forKey:"password")
		aCoder.encode(address, forKey:"address")
		aCoder.encode(guid, forKey:"guid")
	}


	//Required for the class to conform to the NSCoding protocol.
	init(coder aDecoder: NSCoder!) {
		password = aDecoder.decodeObject(forKey: "password") as! String
		address = aDecoder.decodeObject(forKey: "address") as! String
		guid = aDecoder.decodeObject(forKey: "guid") as! String
	}


	//Allows other classes to reference a common instance of this object.
	class func sharedInstance() -> BitcoinAddress {

		struct Singleton {
			static var sharedInstance = BitcoinAddress()
		}
		return Singleton.sharedInstance
	}
}
