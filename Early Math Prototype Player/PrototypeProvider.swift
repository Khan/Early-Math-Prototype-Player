//
//  PrototypeProvider.swift
//  Prototope
//
//  Created by Jason Brennan on 2015-06-22.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation


/** Provides Prototype objects loaded from the application's bundle. */
struct PrototypeProvider {
	
	private static let prototypeDirectory = "Early-Math-Prototypes"
	private static let prototypeHiddenMarker = "hideme" // If this file is present in a prototype directory, we skip it in the UI.
	let prototypes: [Prototype]
	
	init() {
		if let resourcePath = NSBundle.mainBundle().resourcePath {
			let earlyMathPath = resourcePath.stringByAppendingPathComponent(PrototypeProvider.prototypeDirectory)
			var errorPtr = NSErrorPointer()
			let files = NSFileManager.defaultManager().contentsOfDirectoryAtPath(earlyMathPath, error: errorPtr) as! [String]
			let validPrototypeDirectories = files.filter { prototypeDirectory in
				PrototypeProvider.prototypeIsValidAtPath(earlyMathPath.stringByAppendingPathComponent(prototypeDirectory))
			}
			self.prototypes = validPrototypeDirectories.map { prototypeDirectory in
				let prototypeURL = NSURL(fileURLWithPath: earlyMathPath.stringByAppendingPathComponent(prototypeDirectory), isDirectory: true)!
				return Prototype(directoryURL: prototypeURL, name: prototypeDirectory)!
			}
		} else {
			self.prototypes = []
		}
		
	}

	private static func prototypeIsValidAtPath(path: String) -> Bool {
		var isDirectory: ObjCBool = ObjCBool(false)
		let fileManager = NSFileManager.defaultManager()
		if fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) {
			let prototypeIsMarkedAsHidden = fileManager.fileExistsAtPath(path.stringByAppendingPathComponent(PrototypeProvider.prototypeHiddenMarker))
			return isDirectory.boolValue && !prototypeIsMarkedAsHidden
		} else {
			return false
		}
	}
}


/** Prototype..er, type. Represents a prototype directory on disk with reference to the main javascript file. Derived from Protorope.Prototype. */
struct Prototype {
	let mainFileURL: NSURL
	let readmeURL: NSURL?
	let name: String
}


extension Prototype {
	init?(directoryURL: NSURL, name: String) {
		
		if !directoryURL.fileURL { return nil }
		
		var error: NSError? = nil
		let path = directoryURL.filePathURL!.path!
		
		var isDirectory: ObjCBool = ObjCBool(false)
		let exists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
		if !exists {
			println("File does not exist: \(path)")
			return nil
		}
		
		var mainScriptPath: String

		if isDirectory.boolValue {
			var error: NSError? = nil
			let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: &error) as! [String]?
			if contents == nil {
				println("Couldn't read directory \(path): \(error)")
				return nil
			}
			
			let javaScriptFiles = contents!.filter { $0.pathExtension == "js" }
			switch javaScriptFiles.count {
			case 0:
				println("No JavaScript files found in \(path)")
				return nil
			case 1:
				mainScriptPath = path.stringByAppendingPathComponent(javaScriptFiles.first!)
			default:
				println("Multiple JavaScript files found in \(path): \(javaScriptFiles)")
				return nil
			}

			let readmeFiles = contents!.filter { $0.lowercaseString.hasPrefix("readme.md") }
			switch readmeFiles.count {
			case 0:
				readmeURL = nil
			case 1:
				readmeURL = NSURL(fileURLWithPath: path.stringByAppendingPathComponent(readmeFiles[0]))
			default:
				println("Multiple README files found in \(path): \(readmeFiles)")
				return nil
			}
		} else {
			readmeURL = nil
			mainScriptPath = path
		}
		
		self.name = name
		self.mainFileURL = NSURL(fileURLWithPath: mainScriptPath)!
	}
}

