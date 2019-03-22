import PlaygroundSupport
import SpriteKit

let flipView = FlipView(gridSize: 20)
let vc = FlipViewController()
vc.view = flipView
PlaygroundPage.current.liveView = vc.view
