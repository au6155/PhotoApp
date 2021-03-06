//
//  Document.swift
//  PhotoApp
//
//  Created by Pixelmator on 6/14/17.
//  Copyright © 2017 Pixelmator. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    
    override init() {
        super.init()
    }
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    var loadedImage: CIImage?
    
    override func makeWindowControllers() {
        // padaro storyboard kuris atvaizduoja dokumenta
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil) //sukuriamas storyboard
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController // sukuria window controller
        self.addWindowController(windowController)
        
        if let viewController = windowControllers.first?.contentViewController as? ViewController {
            let actuallyLoadedImage: CIImage
            if let image = loadedImage {
                actuallyLoadedImage = image
            } else {
                actuallyLoadedImage = CIImage(cgImage: NSImage(named: NSImage.Name(rawValue: "photo"))!.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
                loadedImage = actuallyLoadedImage
                //CIImage(cgImage: actuallyLoadedImage.cgImage(forProposedRect: nil, context:nil, hints: nil)!)
            }
            viewController.image = actuallyLoadedImage
//            (windowController as? WindowController)?.originalImage = actuallyLoadedImage
            (windowController as? WindowController)?.originalCIImage = actuallyLoadedImage
            windowController.window?.setFrame(CGRect(origin: origin(windowsize: windowSizeXY(imageSize: actuallyLoadedImage.extent.size, window: windowController.window)), size: windowSizeXY(imageSize: actuallyLoadedImage.extent.size, window: windowController.window)), display: true)
        }
    }
    
    func windowSizeXY(imageSize: CGSize, window: NSWindow?) -> CGSize {
        let toolbarHeight: CGFloat = window!.toolbarHeight()
        let displayX: CGFloat = (NSScreen.main?.visibleFrame.width)!
        let displayY: CGFloat = (NSScreen.main?.visibleFrame.height)!
        let imageX: CGFloat = imageSize.width
        let imageY: CGFloat = imageSize.height
        var windowX: CGFloat
        var windowY: CGFloat
        var tooBigX: Bool = false
        var tooBigY: Bool = false
        
        if imageY > displayY { tooBigY = true }
        if imageX > displayX { tooBigX = true }
        
        let imageRatio: CGFloat = imageX/imageY
        let tooBig = (tooBigX, tooBigY)
        
        switch tooBig {
        case (true, false) :
            windowX = displayX
            windowY = windowX/imageRatio
        case (false, true) :
            windowY = displayY
            windowX = windowY*imageRatio
        case (true, true) :
            let dispRatio: CGFloat = displayX/displayY
            
            if dispRatio < imageRatio {
                windowX = displayX
                windowY = windowX/imageRatio
            }
            else {
                windowY = displayY
                windowX = windowY*imageRatio
            }
        default:
        if imageY > 150.0 {
            windowY = imageY
        } else { windowY = 150.0 }
        
        if imageX > 300.0 {
            windowX = imageX
        } else { windowX = 300.0 }
        }
        windowX = -(1.52*toolbarHeight*imageRatio) + windowX
        //windowY = windowY + toolHeight
        return CGSize(width: windowX, height: windowY)
    }
    
    func origin(windowsize: CGSize) -> CGPoint {
        //get display size
        let displayX: CGFloat = (NSScreen.main?.frame.width)!
        let displayY: CGFloat = (NSScreen.main?.frame.height)!
        let windowX: CGFloat = windowsize.width
        let windowY: CGFloat = windowsize.height
        let point: CGPoint = CGPoint(x: (displayX - windowX)/2, y: (displayY - windowY)/2)
        return point
    }
    
    override func data(ofType typeName: String) throws -> Data {
        if let viewController = windowControllers.first?.window?.contentViewController as? ViewController,
            let image = viewController.image {
            let ciImageRep: NSCIImageRep = NSCIImageRep(ciImage: image)
            let nsImage: NSImage = NSImage(size: ciImageRep.size)
            nsImage.addRepresentation(ciImageRep)
            if let tiffData = nsImage.tiffRepresentation {
                return tiffData
            }
        }
        fatalError("Unable to write data")
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        loadedImage = CIImage(cgImage: (NSImage(data: data)?.cgImage(forProposedRect: nil, context: nil, hints: nil)!)!)
        // CIImage(cgImage: actuallyLoadedImage.cgImage(forProposedRect: nil, context:nil, hints: nil)!)
    }
}


extension NSWindow {
    func toolbarHeight() -> CGFloat {
        var toolbar: NSToolbar?
        var toolbarHeight: CGFloat = CGFloat(0.0)
        var windowFrame: NSRect
        toolbar = self.toolbar
        if let toolbar = toolbar {
            if toolbar.isVisible {
                windowFrame = NSWindow.contentRect(forFrameRect: self.frame, styleMask: self.styleMask)
                toolbarHeight = windowFrame.height - (self.contentView?.frame.height)!
            }
        }
        return CGFloat(toolbarHeight)
    }
}
