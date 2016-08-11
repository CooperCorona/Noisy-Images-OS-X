# Noisy Images OS X
Port/Upgrade of Noisy Images for iOS.

Harness the power of Perlin Noise! Noisy Images OS X lets you generate images textured with Perlin Noise. Whether you're making subtle textures or vibrant images, Noisy Images OS X lets you create anything you like.

## Parameters

### Width
The width of the image.

### Height
The height of the image.

### Noise Width
How much noise there is horizontally.

### Noise Height
How much noise there is vertically.

### X Offset
How much the noise is offset in the x-direction (increasing the x-offset shifts the noise left).

### Y Offset
How much the noise is offset in the y-direction (increasing the y-offset shifts the noise down).

### Z Offset
How much the noise is offset in the z-direction (since the images are in 2-D, this has the effect of changing the noise entirely.)

### Noise Type
How the noise is rendered. Options are Default, Fractal, Abs, and Sin.

### Seed
The random seed used to generate the noise. Using the same seed lets you render the same noise. The scramble button randomly generates a new seed.

### Noise Divisor
The noise value calculated at each pixel is divided by this value. Defaults to 0.7. Lower values cause greater vibrancy (cause the noise to use colors closer to the ends of the gradient), higher values cause more muted images (cause the noise to use colors nearer the middle of the gradient).

### Noise Angle
The angle of the noise (only affects images with type Sin).

### Tiled
If checked, the noise is tiled. If you place two copies of the image right next to each other, the noise will transition seamlessly, so it will appear as one image.

### Flip
Flips the width and height and the noise width and noise height. If the width of the image is 256 and the height is 512, Flip will make the width 512 and the height 256. The same applies to the noise width and noise heigth.

### Image
Loads an image that the noise is blended into (the only blending mode is Multiply; the value of each pixel in the noise is directly multiplied into the value of each pixel in the image).

### Square & Circle
Determines the shape of the image. If square is selected, the image is rendered as a square (or rectangle, if the width and height are different). If circle is selected, the image is rendered as a circle (or ellipse, if the width and height are different).

## Gradients
The gradient determines the colors in the image. A gradient can have 16 separate colors. Click on the gradient bar to add a new color anchor. Drag the colors to change their positions.

### Color Tabs
Click on one of the color tabs to automatically set the selected color anchor to that color.

### Sliders
The four sliders beneath the color tabs are Red, Green, Blue, and Alpha. Drag them to change the color of the selected anchor.

### Overlay
The second set of color tabs and sliders control the overlay color. This color is blended over the gradient (it has the effect of placing a rectangle with a given color and opacity over the image). For example, if you decide you want a darker image, instead of changing *all* the anchors, you can adjust the overlay.

### Normalize
The normalize button spaces all the anchors equally. If you have 3 anchors, clicking Normalize causes one at the beginning, one in the middle, and one at the end. The order of the anchors is preserved.

### Delete
Deletes the currently selected color anchor. There must be at least 2 anchors; Delete fails if there are only 2 left.

### Smoothed
If checked, the colors are interpolated with a smoothing function ```(3x^2 - 2x^3)```. Otherwise, the colors are interpolated linearly.

### Saving
Gradients can be saved and reloaded later. File -> Save New Gradient to store a new gradient. File -> Save Gradient to update the currently selected gradient.

## Size Sets
Before exporting an image, you have the opportunity to define size sets. Size sets lets you export the same image at multiple different sizes in a single export. Each size has a defined suffix that is appended to the name of the exported file. Use this to generate retina-sized images, just specify 2x and 3x sized images with the specified @2x and @3x suffixes. To edit size sets, choose File -> Edit Size Sets.
