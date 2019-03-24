import SpriteKit

public class PixelNode: SKShapeNode {
  
  var frames:[Int] = []
  
  var colorPalette: [NSColor] = []
  
  var colorIndex: Int!

  init(rect: CGRect) {
    super.init()
    self.path = CGPath(rect: rect, transform: nil)
    self.strokeColor = .clear
    self.colorIndex = 0
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public func setFrame(color: Int, atIndex index: Int) {
    if frames.indices.contains(index) {
      frames[index] = color
    } else {
      frames.append(color)
    }
    self.displayFrame(index: index)
  }
  
  public func displayFrame(index: Int) {
    if !frames.indices.contains(index) { return }
    
    let colorIndex = frames[index]
    var color = colorPalette[colorIndex]
    
    if colorIndex == 0 && index > 0 {
      let prevColorIndex = frames[index - 1]
      color = (prevColorIndex > 0) ? colorPalette[prevColorIndex].withAlphaComponent(0.3) : color
    }
    self.fillColor = color
  }
  
  public func play(frameDuration: TimeInterval) {
    
    let colorActions = frames.map { (color) -> SKAction in
      return SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
        if let node  = node as? PixelNode {
          node.fillColor = self.colorPalette[color]
        }
      })
    }
    
    let colorSequences = colorActions.map {SKAction.sequence([
      SKAction.wait(forDuration: frameDuration), $0 ])}
    
   
    let sequence = SKAction.sequence(colorSequences)
    let forever = SKAction.repeatForever(sequence)
    self.run(forever)
  }
  
  public func colorIndex(atFrame frame: Int) -> Int? {
    if frames.indices.contains(frame) {
      return frames[frame]
    }
    return nil
  }
}
