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
			let earlyMathPath = (resourcePath as NSString).stringByAppendingPathComponent(PrototypeProvider.prototypeDirectory)
			let files = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(earlyMathPath)
			let validPrototypeDirectories = files.filter { prototypeDirectory in
				PrototypeProvider.prototypeIsValidAtPath((earlyMathPath as NSString).stringByAppendingPathComponent(prototypeDirectory))
			}
			self.prototypes = validPrototypeDirectories.map { prototypeDirectory in
				let prototypeURL = NSURL(fileURLWithPath: (earlyMathPath as NSString).stringByAppendingPathComponent(prototypeDirectory), isDirectory: true)
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
			let prototypeIsMarkedAsHidden = fileManager.fileExistsAtPath((path as NSString).stringByAppendingPathComponent(PrototypeProvider.prototypeHiddenMarker))
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
	let previewImageURL: NSURL?
	let name: String
}


extension Prototype {
	init?(directoryURL: NSURL, name: String) {
		
		if !directoryURL.fileURL { return nil }
		
		let path = directoryURL.filePathURL!.path!
		
		var isDirectory: ObjCBool = ObjCBool(false)
		let exists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
		if !exists {
			print("File does not exist: \(path)")
			return nil
		}
		
		var mainScriptPath: String

		if isDirectory.boolValue {
			do {
				let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path) as [String]?

				let javaScriptFiles = contents!.filter { ($0 as NSString).pathExtension == "js" }
				switch javaScriptFiles.count {
				case 0:
					print("No JavaScript files found in \(path)")
					return nil
				case 1:
					mainScriptPath = (path as NSString).stringByAppendingPathComponent(javaScriptFiles.first!)
				default:
					print("Multiple JavaScript files found in \(path): \(javaScriptFiles)")
					return nil
				}

				let readmeFiles = contents!.filter { $0.lowercaseString.hasPrefix("readme.md") }
				switch readmeFiles.count {
				case 0:
					readmeURL = nil
				case 1:
					readmeURL = NSURL(fileURLWithPath: (path as NSString).stringByAppendingPathComponent(readmeFiles[0]))
				default:
					print("Multiple README files found in \(path): \(readmeFiles)")
					return nil
				}

				let previewFiles = contents!.filter {
					let normalizedName = $0.lowercaseString
					return normalizedName.hasPrefix("preview") &&
						["png", "gif", "jpg"].contains((normalizedName as NSString).pathExtension)
				}
				switch previewFiles.count {
				case 0:
					previewImageURL = nil
				case 1:
					previewImageURL = NSURL(fileURLWithPath: (path as NSString).stringByAppendingPathComponent(previewFiles[0]))
				default:
					print("Multiple preview images found in \(path): \(previewFiles)")
					return nil
				}
			} catch {
				print("Couldn't read directory \(path): \(error)")
				return nil
			}
		} else {
			readmeURL = nil
			previewImageURL = nil
			mainScriptPath = path
		}
		
		self.name = name
		self.mainFileURL = NSURL(fileURLWithPath: mainScriptPath)
	}
}

