//: # Flip 👾
//:  by [Lalo](https://github.com/lalomts) 
/*:
 The creativiy needed to represent a moving character with just a few pixels intrigues me, so I decided to create a pixel art flipbook animator.
 
 You just need to draw your animation in each frame, until your character moves!
 
 1. Show the Assistant Editor with the LiveView selected
 2. Run the Playground
 2. Click on the canvas to show the controls
 
 * Important:
 Make sure you click on the canvas to start interacting
 
 
 
 
 
 ---
 
 ### Controls
 ![TouchBar controls](touchbar_controls.png)
 ⬅️ ➡️ Use your  arrow keys to navigate through your frames
 
 *If your device does not have a TouchBar, just press:
 ⌘ + ⇧ + 8*
 
 ### Let's start with a demo!
 */

import PlaygroundSupport
import SpriteKit

// We create a FlipView  instance that will act as our drawing canvas.
let flipView = FlipView(gridSize: 25, pixelSize: 18, withColorPalette: NSColor.marioBros, frameRate: 12)

// For the demo, we load an animation I created previously with DefaultAnimation.
flipView.load(animation: DefaultAnimation.marioBros)

let vc = FlipViewController()
vc.view = flipView
PlaygroundPage.current.liveView = vc.view
vc.view.becomeFirstResponder()

/*:
 It's your turn now!
 [Try it yourself](@next)
 */
