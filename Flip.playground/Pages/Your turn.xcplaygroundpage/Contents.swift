/*:
 # Your turn!
 ### Same instructions as before:
 
 1. Show the Assistant Editor with the LiveView selected
 2. Run the Playground
 2. Click on the canvas to show the controls
 
 ### Controls
 ![TouchBar controls](touchbar_controls.png)
 
 *If your device does not have a TouchBar, just press:
 ⌘ + ⇧ + 8*
 
 ⬅️ ➡️ Use your  arrow keys to navigate through your frames
  */

import PlaygroundSupport
import Cocoa
/*:
 * Experiment:
 Try changing the `gridSize` and the `pixelSize` to create your own canvas.
 
 You can also add a new colorPalette (an array of `NSColor`) to work with.
 */
let flipView = FlipView(gridSize: 25, pixelSize: 18)

// Finally, we add it to the Playground live view
let vc = FlipViewController()
vc.view = flipView
PlaygroundPage.current.liveView = vc.view
