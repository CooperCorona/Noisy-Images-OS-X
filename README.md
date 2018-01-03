# Noisy Images OS X
Port/Upgrade of Noisy Images for iOS.

Harness the power of Perlin Noise! Noisy Images OS X lets you generate images textured with Perlin Noise. Whether you're making subtle textures or vibrant images, Noisy Images OS X lets you create anything you like.

## Parameters
![](/Readme%20Images/Base%20Image.png)

### Width
The width of the image.

### Height
The height of the image.

### Noise Width
How much noise there is horizontally.

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Noise%20Width.png)

### Noise Height
How much noise there is vertically.

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Noise%20Height.png)

### X Offset
How much the noise is offset in the x-direction (increasing the x-offset shifts the noise left).

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/X%20Offset.png)

### Y Offset
How much the noise is offset in the y-direction (increasing the y-offset shifts the noise down).

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Y%20Offset.png)

### Z Offset
How much the noise is offset in the z-direction (since the images are in 2-D, this has the effect of changing the noise entirely.)

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Z%20Offset.png)

### Noise Type
How the noise is rendered. Options are Default, Fractal, Abs, and Sin.

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Fractal.png)

![](/Readme%20Images/Abs.png) ![](/Readme%20Images/Sin.png)

### Seed
The random seed used to generate the noise. Using the same seed lets you render the same noise. The scramble button randomly generates a new seed.

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Seed.png)

### Noise Divisor
The noise value calculated at each pixel is divided by this value. Defaults to 0.7. Lower values cause greater vibrancy (cause the noise to use colors closer to the ends of the gradient), higher values cause more muted images (cause the noise to use colors nearer the middle of the gradient).

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Noise%20Divisor%20-%20Low.png) ![](/Readme%20Images/Noise%20Divisor%20-%20High.png)

### Noise Angle
The angle of the noise (only affects images with type Sin).

![](/Readme%20Images/Sin.png) ![](/Readme%20Images/Noise%20Angle.png)

### Tiled
If checked, the noise is tiled. If you place two copies of the image right next to each other, the noise will transition seamlessly, so it will appear as one image.

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Tiled.png)

![](/Readme%20Images/Tiled.png)![](/Readme%20Images/Tiled.png)

### Flip
Flips the width and height and the noise width and noise height. If the width of the image is 256 and the height is 512, Flip will make the width 512 and the height 256. The same applies to the noise width and noise heigth.

![](/Readme%20Images/Noise%20Width.png) ![](/Readme%20Images/Noise%20Height.png)

### Image
Loads an image that the noise is blended into (the only blending mode is Multiply; the value of each pixel in the noise is directly multiplied into the value of each pixel in the image).

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Image.png)

### Square & Circle
Determines the shape of the image. If square is selected, the image is rendered as a square (or rectangle, if the width and height are different). If circle is selected, the image is rendered as a circle (or ellipse, if the width and height are different).

![](/Readme%20Images/Base%20Image.png) ![](/Readme%20Images/Circle.png)

## Gradients
The gradient determines the colors in the image. A gradient can have 16 separate colors. Click on the gradient bar to add a new color anchor. Drag the colors to change their positions.

![](/Readme%20Images/Gradient%20Base%20Image.png)

### Color Tabs
Click on one of the color tabs to automatically set the selected color anchor to that color.

### Sliders
The four sliders beneath the color tabs are Red, Green, Blue, and Alpha. Drag them to change the color of the selected anchor.

### Overlay
The second set of color tabs and sliders control the overlay color. This color is blended over the gradient (it has the effect of placing a rectangle with a given color and opacity over the image). For example, if you decide you want a darker image, instead of changing *all* the anchors, you can adjust the overlay.

![](/Readme%20Images/Overlay.png)

### Normalize
The normalize button spaces all the anchors equally. If you have 3 anchors, clicking Normalize causes one at the beginning, one in the middle, and one at the end. The order of the anchors is preserved.

![](/Readme%20Images/Normalize.png)

### Delete
Deletes the currently selected color anchor. There must be at least 2 anchors; Delete fails if there are only 2 left.

### Smoothed
If checked, the colors are interpolated with a smoothing function ```(3x^2 - 2x^3)```. Otherwise, the colors are interpolated linearly.

![](/Readme%20Images/Smoothed.png)

### Saving
Gradients can be saved and reloaded later. File -> Save New Gradient to store a new gradient. File -> Save Gradient to update the currently selected gradient.

## Size Sets
Before exporting an image, you have the opportunity to define size sets. Size sets lets you export the same image at multiple different sizes in a single export. Each size has a defined suffix that is appended to the name of the exported file. Use this to generate retina-sized images, just specify 2x and 3x sized images with the specified @2x and @3x suffixes. To edit size sets, choose File -> Edit Size Sets.

## Export the Application (New instructions)
Instead of running Noisy Images OS X from Xcode, you can export it to your desktop.

1. Open Terminal
2. Navigate to the directory containing Noisy-Images-OS-X (not Noisy-Images-OS-X, but the directory containing it)
3. ```curl https://gist.githubusercontent.com/CooperCorona/fb483eee4b7bac446c914de45ee85a3f/raw/00e352c427dfc80e7e78fa4436ef65b244ae6e5d/exportNoise.sh > exportNoise.sh; chmod 700 exportNoise.sh; ./exportNoise.sh```

Whenever you want to re-export or update Noisy Images OS X, navigate to the directory and run ```./exportNoise.sh```. This automatically builds the dependencies, copies the frameworks to ```~/Library/Frameworks/```, and exports the Mac application.

### Troubleshooting
If you are getting a message that says Noisy Images OS X could not be opened (and prompts you to contact the developer or update it), make sure you have the CoronaConvenience.framework, CoronaStructures.framework, and CoronaGL.framework files in ~/Library/Frameworks directory.

## Conclusion
Thank you for using Noisy Images OS X! If you'd like to contribute to the project, fork the repository and submit a pull request. Take a look at the [issues page](https://github.com/CooperCorona/Noisy-Images-OS-X/issues) to see what needs to be done, add an issue that's been missed, or request useful functionality.
