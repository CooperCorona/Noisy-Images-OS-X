//
//  NoiseDocumentWindowController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/1/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL

class NoiseDocumentWindowController: NSWindowController {

    var menuController:MenuController {
        return (self.contentViewController! as! NSSplitViewController).childViewControllers[0] as! MenuController
    }
    var viewController:ViewController {
        return (self.contentViewController! as! NSSplitViewController).childViewControllers[1] as! ViewController
    }
    var noiseDocument:NoiseDocument {
        return self.document! as! NoiseDocument
    }
    
}

extension NoiseDocumentWindowController: MenuControllerDelegate {
    
    func widthChanged(_ width: CGFloat) {
        self.noiseDocument.state.contentSize.width = width
//        self.renderToTexture()
        self.viewController.widthChanged(width)
    }
    
    func heightChanged(_ height: CGFloat) {
        self.noiseDocument.state.contentSize.height = height
//        self.renderToTexture()
        self.viewController.heightChanged(height)
    }
    
    func noiseWidthChanged(_ noiseWidth: CGFloat) {
        self.noiseDocument.state.noiseSize.width = noiseWidth
//        self.updateForTiled()
//        self.renderToTexture()
        self.viewController.noiseWidthChanged(noiseWidth)
    }
    
    func noiseHeightChanged(_ noiseHeight: CGFloat) {
        self.noiseDocument.state.noiseSize.height = noiseHeight
//        self.updateForTiled()
//        self.renderToTexture()
        self.viewController.noiseHeightChanged(noiseHeight)
    }
    
    func xOffsetChanged(_ xOffset: CGFloat) {
        self.noiseDocument.state.offset.x = xOffset
//        self.renderToTexture()
        self.viewController.xOffsetChanged(xOffset)
    }
    
    func yOffsetChanged(_ yOffset: CGFloat) {
        self.noiseDocument.state.offset.y = yOffset
//        self.renderToTexture()
        self.viewController.yOffsetChanged(yOffset)
    }
    
    func zOffsetChanged(_ zOffset: CGFloat) {
        self.noiseDocument.state.offset.z = zOffset
//        self.renderToTexture()
        self.viewController.zOffsetChanged(zOffset)
    }
    
    func noiseTypeChanged(_ noiseType: GLSPerlinNoiseSprite.NoiseType) {
        self.noiseDocument.state.noiseType = noiseType
//        self.renderToTexture()
        self.viewController.noiseTypeChanged(noiseType)
    }
    
    func seedChanged(_ seed: UInt32) {
        self.noiseDocument.state.seed = seed
//        self.renderToTexture()
        self.viewController.seedChanged(seed)
    }
    
    func noiseDivisorChanged(_ noiseDivisor: CGFloat) {
        self.noiseDocument.state.noiseDivisor = noiseDivisor
//        self.renderToTexture()
        self.viewController.noiseDivisorChanged(noiseDivisor)
    }
    
    func isTiledChanged(_ isTiled: Bool) {
//        self.isTiled = isTiled
//        self.updateForTiled()
//        self.renderToTexture()
        self.noiseDocument.state.isTiled = isTiled
        self.viewController.isTiledChanged(isTiled)
    }
    
    
    func noiseAngleChanged(_ noiseAngle: CGFloat) {
        self.noiseDocument.state.noiseAngle = noiseAngle
        self.viewController.noiseAngleChanged(noiseAngle)
    }
    
    func gradientChanged(_ gradient: ColorGradient1D) {
        self.viewController.gradientChanged(gradient)
    }
    
    func textureChanged(_ texture: CCTexture, withData data:Data?) {
        self.viewController.textureChanged(texture, withData: data)
        self.noiseDocument.imageData = data
    }
    
    func stateChanged(_ state: NoiseState) {
        self.noiseDocument.state = state
        self.viewController.stateChanged(state)
    }
    
}
