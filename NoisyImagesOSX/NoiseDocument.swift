//
//  NoiseDocument.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/30/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import OmniSwiftX
import GLKit

enum NoiseDocumentError: ErrorType {
    case MissingData
}

public class NoiseDocument: NSDocument {
    
    var state = NoiseState()
    var uuid:String {
        get { return self.gradientContainer.uuid }
        set { self.gradientContainer.uuid = newValue }
    }
    let gradientContainer = GradientContainer()
    var imageData:NSData? = nil
    
    public override init() {
        super.init()
    }
    /*
    override public func readFromData(data: NSData, ofType typeName: String) throws {
        guard let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSObject:AnyObject] else {
            return
        }
        var anchors:[ColorAnchor] = []
        for i in 0..<16 {
            guard let str = dict["Anchor \(i)"] as? String else {
                break
            }
            anchors.append(ColorAnchor(string: str))
        }
        let gradient = ColorGradient1D(colorsAndWeights: anchors.map() { $0.getTuple() }, smoothed: dict["Smoothed"] as! Bool)
        self.state = NoiseState(width: dict["Width"] as! CGFloat, height: dict["Height"] as! CGFloat, noiseWidth: dict["Noise Width"] as! CGFloat, noiseHeight: dict["Noise Height"] as! CGFloat, xOffset: dict["X Offset"] as! CGFloat, yOffset: dict["Y Offset"] as! CGFloat, zOffset: dict["Z Offset"] as! CGFloat, seed: (dict["Seed"] as! NSNumber).unsignedIntValue, noiseDivisor: dict["Noise Divisor"] as! CGFloat, noiseType: GLSPerlinNoiseSprite.NoiseType(rawValue: dict["Noise Type"] as! String)!, isTiled: dict["Tiled"] as! Bool, noiseAngle: dict["Noise Angle"] as! CGFloat, gradient: gradient)
        self.uuid = dict["UUID"] as! String
        self.gradientContainer.gradient = gradient
    }
    
    override public func dataOfType(typeName: String) throws -> NSData {
        var dict:[NSObject:AnyObject] = [:]
        dict["Width"] = state.width
        dict["Height"] = state.height
        dict["Noise Width"] = state.noiseWidth
        dict["Noise Height"] = state.noiseHeight
        dict["X Offset"] = state.xOffset
        dict["Y Offset"] = state.yOffset
        dict["Z Offset"] = state.zOffset
        dict["Seed"] = NSNumber(unsignedInt: state.seed)
        dict["Noise Divisor"] = state.noiseDivisor
        dict["Noise Type"] = state.noiseType.rawValue
        dict["Tiled"] = state.isTiled
        dict["Noise Angle"] = state.noiseAngle
        for (i, (color: color, weight: weight)) in self.gradientContainer.gradient.anchors.enumerate() {
            dict["Anchor \(i)"] = ColorAnchor(color: NSColor(vector4: color), weight: weight).getString()
        }
        dict["Smoothed"] = self.gradientContainer.gradient.isSmoothed
        dict["UUID"] = self.uuid
        return NSKeyedArchiver.archivedDataWithRootObject(dict)
    }
    */
    
    private func getNoiseData() -> NSData {
        var dict:[NSObject:AnyObject] = [:]
        dict["Width"]           = self.state.width
        dict["Height"]          = self.state.height
        dict["Noise Width"]     = self.state.noiseWidth
        dict["Noise Height"]    = self.state.noiseHeight
        dict["X Offset"]        = self.state.xOffset
        dict["Y Offset"]        = self.state.yOffset
        dict["Z Offset"]        = self.state.zOffset
        dict["Seed"]            = NSNumber(unsignedInt: self.state.seed)
        dict["Noise Divisor"]   = self.state.noiseDivisor
        dict["Noise Type"]      = self.state.noiseType.rawValue
        dict["Tiled"]           = self.state.isTiled
        dict["Noise Angle"]     = self.state.noiseAngle
        for (i, (color: color, weight: weight)) in self.gradientContainer.gradient.anchors.enumerate() {
            dict["Anchor \(i)"] = ColorAnchor(color: NSColor(vector4: color), weight: weight).getString()
        }
        dict["Smoothed"]        = self.gradientContainer.gradient.isSmoothed
        dict["UUID"]            = self.uuid
        return NSKeyedArchiver.archivedDataWithRootObject(dict)
    }
    
    public override func fileWrapperOfType(typeName: String) throws -> NSFileWrapper {
        let noiseDataFile = NSFileWrapper(regularFileWithContents: self.getNoiseData())
        if let imageData = self.imageData {
            let imageFile = NSFileWrapper(regularFileWithContents: imageData)
            return NSFileWrapper(directoryWithFileWrappers: ["Noise Data.plist":noiseDataFile, "Image":imageFile])
        } else {
            return NSFileWrapper(directoryWithFileWrappers: ["Noise Data.plist":noiseDataFile])
        }
    }
    
    private func readNoiseData(dict:[NSObject:AnyObject]) {
        var anchors:[ColorAnchor] = []
        for i in 0..<16 {
            guard let str = dict["Anchor \(i)"] as? String else {
                break
            }
            anchors.append(ColorAnchor(string: str))
        }
        let gradient = ColorGradient1D(colorsAndWeights: anchors.map() { $0.getTuple() }, smoothed: dict["Smoothed"] as! Bool)
        self.state = NoiseState(width: dict["Width"] as! CGFloat, height: dict["Height"] as! CGFloat, noiseWidth: dict["Noise Width"] as! CGFloat, noiseHeight: dict["Noise Height"] as! CGFloat, xOffset: dict["X Offset"] as! CGFloat, yOffset: dict["Y Offset"] as! CGFloat, zOffset: dict["Z Offset"] as! CGFloat, seed: (dict["Seed"] as! NSNumber).unsignedIntValue, noiseDivisor: dict["Noise Divisor"] as! CGFloat, noiseType: GLSPerlinNoiseSprite.NoiseType(rawValue: dict["Noise Type"] as! String)!, isTiled: dict["Tiled"] as! Bool, noiseAngle: dict["Noise Angle"] as! CGFloat, gradient: gradient)
        self.uuid = dict["UUID"] as! String
        self.gradientContainer.gradient = gradient
    }
    
    public override func readFromFileWrapper(fileWrapper: NSFileWrapper, ofType typeName: String) throws {
        guard let noiseData = fileWrapper.fileWrappers?["Noise Data.plist"]?.regularFileContents else {
            throw NoiseDocumentError.MissingData
        }
        
        self.readNoiseData(NSKeyedUnarchiver.unarchiveObjectWithData(noiseData) as! [NSObject:AnyObject])
        
        self.imageData = fileWrapper.fileWrappers?["Image"]?.regularFileContents
    }
    
    public override func makeWindowControllers() {
        let wc = NSStoryboard(name: "Document", bundle: nil).instantiateInitialController()! as! NoiseDocumentWindowController
        wc.menuController.undoingEnabled = false
        wc.menuController.state = self.state
        wc.viewController.setState(self.state)
        wc.menuController.undoingEnabled = true
        wc.menuController.delegate = wc
        wc.menuController.gradientContainer = self.gradientContainer
        wc.menuController.gradientContainer.delegate = wc.menuController
        
        self.addWindowController(wc)
        
        let delegate = GradientTableViewDelegate()
        //If the UUID is empty, that means we don't have a valid gradient yet.
        if let gradient = delegate[self.uuid] {
            self.state.gradient = gradient.gradient.blendColor(gradient.overlay.getVector4())
            self.uuid = gradient.uuid
        } else if self.uuid == "" {
            //There is guaranteed to be at least one gradient
            let gradient        = delegate.gradients.first!
            let overlay         = delegate.gradientObjects.first?.overlayColor?.getVector4() ?? SCVector4(x: 0.0, y: 0.0, z: 0.0, w: 0.0)
            self.state.gradient = gradient.blendColor(overlay)
            self.uuid           = delegate.gradientObjects.first!.universalId!
        } else {
            wc.menuController.gradientContainer.gradient = self.state.gradient
            wc.menuController.gradientContainer.uuid = self.uuid
            delegate.verifyGradient(wc.menuController.gradientContainer)
        }
        wc.menuController.gradientContainer.gradient = self.state.gradient
        wc.menuController.gradientContainer.uuid = self.uuid
        
        self.loadImageTexture(wc.menuController)
    }
    
    func loadImageTexture(menuController:MenuController) {
        guard let imageData = self.imageData else {
            return
        }
        menuController.textureData = imageData
        do {
            let tex = try GLKTextureLoader.textureWithContentsOfData(imageData, options: [GLKTextureLoaderOriginBottomLeft:true])
            menuController.texture = CCTexture(name: tex.name)
            menuController.delegate?.textureChanged(menuController.texture!, withData: menuController.textureData)
        } catch {
            
        }
    }

}
