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


	func createProperties(completionHandler: (success: Bool, errorString: String?) -> Void) {

		password = randomStringWithLength(10)

		let BASE_URL = "https://blockchain.info/api/v2/create_wallet"

		let methodArguments = [
			"api_code": API_KEY,
			"password": password,
			]

		let session = NSURLSession.sharedSession()
		let urlString = BASE_URL + escapedParameters(methodArguments)
		let url = NSURL(string: urlString)!
		let request = NSURLRequest(URL: url)

		let task = session.dataTaskWithRequest(request) {data, response, downloadError in
			if let error = downloadError {
				completionHandler(success: false, errorString: "Could not complete the request \(error)")
			} else {
				let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
				self.address = (parsedResult["address"] as? String)!
				
				self.guid = (parsedResult["guid"] as? String)!
				completionHandler(success: true, errorString: nil)
			}
		}
		task.resume()
	}


	func setProperties(password: String, address: String, guid: String) {
		self.password = password
		self.address = address
		self.guid = guid
	}


	func getBalance(balanceDisplay: UILabel, completionHandler: (success: Bool, errorString: String?) -> Void) {

		if address == "Error" {
			return
		} else {

			let BASE_URL = "https://blockchain.info/address/\(BitcoinAddress.sharedInstance().address)"

			let methodArguments = [
				"format": "json",
				]

			let session = NSURLSession.sharedSession()
			let urlString = BASE_URL + self.escapedParameters(methodArguments)
			let url = NSURL(string: urlString)!
			let request = NSURLRequest(URL: url)

			let task = session.dataTaskWithRequest(request) {data, response, downloadError in
				if let error = downloadError {
						completionHandler(success: false, errorString: "Could not complete the request \(error)")
				} else {
					let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options:		NSJSONReadingOptions.AllowFragments)) as! NSDictionary
					let balance = parsedResult["final_balance"]!.stringValue
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						balanceDisplay.text = String(balance)
					});
					completionHandler(success: true, errorString: nil)
				}
			}
			task.resume()
		}
	}


	func sendBitcoin(address: String, amount: String, completionHandler: (success: Bool, errorString: String?) -> Void) {

		let BASE_URL = "https://blockchain.info/merchant/\(BitcoinAddress.sharedInstance().guid)/payment"

		let methodArguments = [
			"api_code": API_KEY,
			"password": BitcoinAddress.sharedInstance().password,
			"to": address,
			"amount": amount
		]

		let session = NSURLSession.sharedSession()
		let urlString = BASE_URL + escapedParameters(methodArguments)
		let url = NSURL(string: urlString)!
		let request = NSURLRequest(URL: url)

		let task = session.dataTaskWithRequest(request) {data, response, downloadError in
			if let error = downloadError {
				completionHandler(success: false, errorString: "Could not complete the request \(error)")
			} else {
				let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
				print(parsedResult["message"]!)
				completionHandler(success: true, errorString: nil)
			}
		}
		task.resume()
	}


	/* Helper function: Given a dictionary of parameters, convert to a string for a url */
	func escapedParameters(parameters: [String: AnyObject]) -> String {

		var urlVars = [String]()

		for (key, value) in parameters {

			/* Make sure that it is a string value */
			let stringValue = "\(value)"

			/* FIX: Replace spaces with '+' */
			let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)

			/* Append it */
			urlVars += [key + "=" + "\(replaceSpaceValue)"]
		}

		return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
	}


	//http://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
	func randomStringWithLength(length: Int) -> String {

		let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let allowedCharsCount = UInt32(allowedChars.characters.count)
		var randomString = ""

		for _ in (0..<length) {
			let randomNum = Int(arc4random_uniform(allowedCharsCount))
			let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
			randomString += String(newCharacter)
		}

		return randomString
	}


	//Required for the class to conform to the NSCoding protocol.
	func encodeWithCoder(aCoder: NSCoder!) {
		aCoder.encodeObject(password, forKey:"password")
		aCoder.encodeObject(address, forKey:"address")
		aCoder.encodeObject(guid, forKey:"guid")
	}


	//Required for the class to conform to the NSCoding protocol.
	init(coder aDecoder: NSCoder!) {
		password = aDecoder.decodeObjectForKey("password") as! String
		address = aDecoder.decodeObjectForKey("address") as! String
		guid = aDecoder.decodeObjectForKey("guid") as! String
	}


	//Allows other classes to reference a common instance of this object.
	class func sharedInstance() -> BitcoinAddress {

		struct Singleton {
			static var sharedInstance = BitcoinAddress()
		}
		return Singleton.sharedInstance
	}
}
