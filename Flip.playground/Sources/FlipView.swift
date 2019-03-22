import SpriteKit

public class FlipView: SKView {
  
  var currentFrameIndex: Int!
  var totalFrames: Int!
  
  var nodes: [PixelNode] = []
  let colorPalette: [NSColor]!
  
  let gutterSize: CGFloat = 2
  let pixelSize: CGFloat = 28
  let gridSize: Int
  
  let squareNodes: [SKShapeNode] = []
  var changedNodes: Set<PixelNode> = []
  var currentColor: Int!
  let emptyColor: Int = 0
  
  var isPlaying = false
  
  public init(gridSize: Int, withColorPalette palette: [NSColor] = NSColor.def) {
    self.gridSize = gridSize
    self.colorPalette = palette
    self.currentFrameIndex = 0
    self.totalFrames = 1
    self.currentColor = 1
    
    let gutterSum = CGFloat(gridSize - 1) * gutterSize
    let pixelSum = pixelSize * CGFloat(gridSize)
    let totalSize = gutterSum + pixelSum
    super.init(frame: NSRect(x: 0, y: 0, width: totalSize, height: totalSize))
    
    let scene = SKScene()
    scene.backgroundColor = NSColor.clear
    scene.scaleMode = .resizeFill
    scene.physicsWorld.gravity = CGVector.zero
    self.presentScene(scene)
    
    self.populateScene()
  }
  
  required public init?(coder decoder: NSCoder) {
    self.gridSize = 0
    self.colorPalette = nil
    super.init(coder: decoder)
  }
  
  func populateScene() {
    
    for index in 0...(gridSize * gridSize) - 1 {
      let positionX = CGFloat(index % gridSize) * (pixelSize + gutterSize)
      let positionY = CGFloat(index / gridSize) * (pixelSize + gutterSize)
      
      let node = PixelNode(rect: CGRect(x: positionX, y: positionY, width: pixelSize, height: pixelSize))
      node.colorPalette = self.colorPalette

      node.setFrame(color: emptyColor, atIndex: 0)
      self.scene!.addChild(node)
      self.nodes.append(node)
    }
  }
  
  // MARK: - Pixel Drawing
  
  override public func mouseDown(with event: NSEvent) {
    if let touchedNode = self.scene?.nodes(at: event.locationInWindow).first,
      let node = touchedNode as? PixelNode  {
      node.setFrame(color: self.currentColor, atIndex: self.currentFrameIndex)
      self.changedNodes.insert(node)
    }
  }

  override public func mouseDragged(with event: NSEvent) {
    if let touchedNode = self.scene?.nodes(at: event.locationInWindow).first,
      let node = touchedNode as? PixelNode  {

      if !self.changedNodes.contains(node) {
        node.setFrame(color: self.currentColor, atIndex: self.currentFrameIndex)
        self.changedNodes.insert(node)
      }
    }
  }
  
  override public func mouseUp(with event: NSEvent) {
    self.changedNodes = []
  }
  
  /// Erases all pixels on backspace keypress
  override public func keyDown(with event: NSEvent) {
    print(event.keyCode)
    
    switch event.keyCode {
      case 49: self.isPlaying ? self.stop() : self.play()
      case 51: self.emtpyNodes()
      case 0: self.colorAll()
      case 30: self.newFrame()
      case 123: self.displayPreviousFrame()
      case 124: self.displayNextFrame()
      case 1: self.printAnimation()
      case 37:  self.load(animation: DefaultAnimation.test)
      default: break
    }
  }
  
  
  // MARK: Frames
  
  func play(withFrameRate rate: Double = 8) {
    self.allNodes { (node) in
      node.play(frameDuration: 1/rate)
    }
    self.isPlaying = true
  }
  
  func stop() {
    self.allNodes { (node) in
      node.removeAllActions()
    }
    self.isPlaying = false
    self.nodesDisplayFrame(index: self.currentFrameIndex)
  }
  
  func newFrame() {
    self.currentFrameIndex += 1
    self.totalFrames += 1
    self.emtpyNodes()
  }
  
  func nodesDisplayFrame(index: Int) {
    self.allNodes { (node) in
      node.displayFrame(index: index)
    }
  }
  
  func displayNextFrame() {
    let nextFrame = self.currentFrameIndex + 1
    self.currentFrameIndex = (self.totalFrames > nextFrame) ? nextFrame : 0
    self.nodesDisplayFrame(index: self.currentFrameIndex)
  }
  
  func displayPreviousFrame() {
    let prevFrame = self.currentFrameIndex - 1
    self.currentFrameIndex = (prevFrame < 0) ? self.totalFrames - 1 : prevFrame
    self.nodesDisplayFrame(index: self.currentFrameIndex)
  }
  
  func colorAll() {
    allNodes { (node) in
      node.setFrame(color: currentColor, atIndex: currentFrameIndex)
    }
  }
  
  //  MARK: - Helpers
  func allNodes(_ action: (PixelNode)->Void) {
    for node in nodes {
      action(node)
    }
  }
  
  func emtpyNodes() {
    self.allNodes { (node) in
      node.setFrame(color: emptyColor, atIndex: self.currentFrameIndex)
    }
  }
  
  func printAnimation() {
    let mappedColors = self.nodes.map { (node) -> [Int] in
      return node.frames
    }
    print(mappedColors)
  }
  
  public func load(animation: [[Int]]) {
    if animation.isEmpty { return }
    for (index, node) in nodes.enumerated() {
      node.frames = animation[index]
    }
    self.totalFrames = animation.first!.count
    self.currentFrameIndex = 0
    self.nodesDisplayFrame(index: self.currentFrameIndex)
  }

}


