# Noisy Images OS X
Port/Upgrade of Noisy Images for iOS.

Harness the power of Perlin Noise! Noisy Images OS X lets you generate images textured with Perlin Noise. Whether you're making subtle textures or vibrant images, Noisy Images OS X lets you create anything you like.

## Parameters
![](/Readme\ Images/Base\ Image.png)

### Width
The width of the image.

### Height
The height of the image.

### Noise Width
How much noise there is horizontally.

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Noise\ Width.png)

### Noise Height
How much noise there is vertically.

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Noise\ Height.png)

### X Offset
How much the noise is offset in the x-direction (increasing the x-offset shifts the noise left).

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/X\ Offset.png)

### Y Offset
How much the noise is offset in the y-direction (increasing the y-offset shifts the noise down).

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Y\ Offset.png)

### Z Offset
How much the noise is offset in the z-direction (since the images are in 2-D, this has the effect of changing the noise entirely.)

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Z\ Offset.png)

### Noise Type
How the noise is rendered. Options are Default, Fractal, Abs, and Sin.

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Fractal.png)

![](/Readme\ Images/Abs.png) ![](/Readme\ Images/Sin.png)

### Seed
The random seed used to generate the noise. Using the same seed lets you render the same noise. The scramble button randomly generates a new seed.

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Seed.png)

### Noise Divisor
The noise value calculated at each pixel is divided by this value. Defaults to 0.7. Lower values cause greater vibrancy (cause the noise to use colors closer to the ends of the gradient), higher values cause more muted images (cause the noise to use colors nearer the middle of the gradient).

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Noise\ Divisor\ -\ Low.png) ![](/Readme\ Images/Noise\ Divisor\ -\ High.png)

### Noise Angle
The angle of the noise (only affects images with type Sin).

![](/Readme\ Images/Sin.png) ![](/Readme\ Images/Noise\ Angle.png)

### Tiled
If checked, the noise is tiled. If you place two copies of the image right next to each other, the noise will transition seamlessly, so it will appear as one image.

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Tiled.png)

![](/Readme\ Images/Tiled.png)![](/Readme\ Images/Tiled.png)

### Flip
Flips the width and height and the noise width and noise height. If the width of the image is 256 and the height is 512, Flip will make the width 512 and the height 256. The same applies to the noise width and noise heigth.

![](/Readme\ Images/Noise\ Width.png) ![](/Readme\ Images/Noise\ Height.png)

### Image
Loads an image that the noise is blended into (the only blending mode is Multiply; the value of each pixel in the noise is directly multiplied into the value of each pixel in the image).

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Image.png)

### Square & Circle
Determines the shape of the image. If square is selected, the image is rendered as a square (or rectangle, if the width and height are different). If circle is selected, the image is rendered as a circle (or ellipse, if the width and height are different).

![](/Readme\ Images/Base\ Image.png) ![](/Readme\ Images/Circle.png)

## Gradients
The gradient determines the colors in the image. A gradient can have 16 separate colors. Click on the gradient bar to add a new color anchor. Drag the colors to change their positions.

![](/Readme\ Images/Gradient\ Base\ Image.png)

### Color Tabs
Click on one of the color tabs to automatically set the selected color anchor to that color.

### Sliders
The four sliders beneath the color tabs are Red, Green, Blue, and Alpha. Drag them to change the color of the selected anchor.

### Overlay
The second set of color tabs and sliders control the overlay color. This color is blended over the gradient (it has the effect of placing a rectangle with a given color and opacity over the image). For example, if you decide you want a darker image, instead of changing *all* the anchors, you can adjust the overlay.

![](/Readme\ Images/Overlay.png)

### Normalize
The normalize button spaces all the anchors equally. If you have 3 anchors, clicking Normalize causes one at the beginning, one in the middle, and one at the end. The order of the anchors is preserved.

![](/Readme\ Images/Normalize.png)

### Delete
Deletes the currently selected color anchor. There must be at least 2 anchors; Delete fails if there are only 2 left.

### Smoothed
If checked, the colors are interpolated with a smoothing function ```(3x^2 - 2x^3)```. Otherwise, the colors are interpolated linearly.

![](/Readme\ Images/Smoothed.png)

### Saving
Gradients can be saved and reloaded later. File -> Save New Gradient to store a new gradient. File -> Save Gradient to update the currently selected gradient.

## Size Sets
Before exporting an image, you have the opportunity to define size sets. Size sets lets you export the same image at multiple different sizes in a single export. Each size has a defined suffix that is appended to the name of the exported file. Use this to generate retina-sized images, just specify 2x and 3x sized images with the specified @2x and @3x suffixes. To edit size sets, choose File -> Edit Size Sets.

## Export the Application
Instead of running Noisy Images OS X from Xcode, you can export it to your desktop.

1. Open Noisy Images OS X in Xcode
2. Product -> Archive
3. Export
4. Export as a Mac Application
5. Next
6. Choose where you want the folder exported to
  * The folder will contain the application
7. Drag the application wherever you want it
  * If you want it on your launchpad, drag it to your launchpad
8. Open Finder
9. Shift+Command+G
  * (Or Go -> Go to Folder)
10. Enter ~/Library and click Go
11. If the Frameworks folder does not exist, create it.
12. Download [OmniSwiftX](https://github.com/CooperCorona/OmniSwiftX)
13. Open OmniSwiftX in Xcode
14. Product -> Build (or Command+B)
15. Open the Project Navigator (Command+1)
16. Scroll to the Products Folder
17. Control Click on OmniSwiftX.framework
18. Show in Finder
19. Copy OmniSwiftX.framework to ~/Library/Frameworks
20. NoisyImagesOSX should now open!

### Troubleshooting
If you are getting a message that says Noisy Images OS X could not be opened (and prompts you to contact the developer or update it), make sure you have the OmniSwiftX.framework file in ~/Library/Frameworks directory.

## Conclusion
Thank you for using at Noisy Images OS X! If you'd like to contribute to the project, fork the repository and submit a pull request. Take a look at the [issues page](https://github.com/CooperCorona/Noisy-Images-OS-X/issues) to see what needs to be done, add an issue that's been missed, or a request for useful functionality.
