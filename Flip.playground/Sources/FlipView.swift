import SpriteKit

/// The view that holds the canvas were we draw. Each pixel is an instance of `SKShapeNode` that changes it's color on each frame.
public class FlipView: SKView {
  
  let gridSize: Int!
  
  var currentFrameIndex: Int!
  var totalFrames: Int!
  
  var nodes: [PixelNode] = []
  let colorPalette: [NSColor]!
  
  let gutterSize: CGFloat = 2
  let pixelSize: CGFloat
  
  var changedNodes: Set<PixelNode> = []
  var currentColor: Int!
  let emptyColor: Int = 0
  
  var currentTool: Tool
  var copiedFrame: [Int]?
  
  var isPlaying = false
  var frameRate: Int
  
  var userHasClicked = false
  
  public init(gridSize: Int, pixelSize: Int = 13, withColorPalette palette: [NSColor] = NSColor.normal, frameRate: Int = 8) {
    self.frameRate = frameRate
    self.gridSize = gridSize
    self.colorPalette = palette
    self.pixelSize = CGFloat(pixelSize)
    self.currentFrameIndex = 0
    self.totalFrames = 1
    self.currentColor = 1
    self.currentTool = .pencil
    
    let gutterSum = CGFloat(gridSize - 1) * gutterSize
    let pixelSum = self.pixelSize * CGFloat(gridSize)
    let totalSize = gutterSum + pixelSum
    super.init(frame: NSRect(x: 0, y: 0, width: totalSize, height: totalSize))
    
    let scene = SKScene()
    scene.backgroundColor = NSColor.clear
    scene.scaleMode = .resizeFill
    scene.physicsWorld.gravity = CGVector.zero
    self.presentScene(scene)
    
    self.populateScene(withGridSize: gridSize)
    // Play start sound
    let firstNode = nodes.first!
    firstNode.run(SKAction.playSoundFileNamed("start.wav", waitForCompletion: false))
  }
  
  required public init?(coder decoder: NSCoder) {
    self.colorPalette = nil
    self.gridSize = 0
    self.currentTool = .pencil
    self.pixelSize = 13
    self.frameRate = 8
    super.init(coder: decoder)
  }
  
  func populateScene(withGridSize gridSize: Int) {
    
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
    // Avoid drawing on first click
    if !userHasClicked {
      userHasClicked = true
      return
    }
    if let touchedNode = self.scene?.nodes(at: event.locationInWindow).first,
      let node = touchedNode as? PixelNode  {
      
      if currentTool == .pencil {
        node.setFrame(color: self.currentColor, atIndex: self.currentFrameIndex)
        self.changedNodes.insert(node)
      } else {
        if let nodeIndex = self.nodes.firstIndex(of: node) {
          self.propagateColor(originIndex: nodeIndex, color: self.currentColor)
        }
      }
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
    switch event.keyCode {
      case 49: self.isPlaying ? self.stop() : self.play()
      case 51: self.emtpyNodes()
      case 0: self.colorAll()
      case 2: self.duplicateFrame()
      case 30: self.newFrame()
      case 123: self.displayPreviousFrame()
      case 124: self.displayNextFrame()
      case 1: self.printAnimation()
      case 37:  self.load(animation: DefaultAnimation.test)
      case 8: self.copyCurrentFrame()
      case 9: self.pasteInCurrentFrame()
      case 14: self.deleteCurrentFrame()
      default: break
    }
  }
  
  
  // MARK: Frames
  
  func play() {
    self.allNodes { (node) in
      let fr = TimeInterval(self.frameRate)
      node.play(frameDuration: 1/fr)
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
  
  func propagateColor(originIndex origin: Int, color: Int) {
    let originNode = self.nodes[origin]
    let originalColor = originNode.fillColor
    
    var changedIndexes: Set<Int> = []
    
    func paintAdjacentPixels(origin: Int) {
      let adjacentIndexes: [Int] = [
        origin,
        origin - self.gridSize,
        origin - 1,
        origin + 1,
        origin + self.gridSize
      ]
      
      for index in adjacentIndexes {
        if self.nodes.indices.contains(index) &&
          nodes[index].fillColor == originalColor &&
          !changedIndexes.contains(index) { // If pixel exists, it is the original color and has not been changed already
          nodes[index].setFrame(color: color, atIndex: self.currentFrameIndex)
          changedIndexes.insert(index)
          paintAdjacentPixels(origin: index)
        }
      }
    }
    paintAdjacentPixels(origin: origin) //Start propagation
  }
  
  func newFrame() {
    self.currentFrameIndex += 1
    self.totalFrames += 1
    self.emtpyNodes()
  }
  
  func deleteCurrentFrame() {
    if self.totalFrames > 1 {
      self.allNodes { (node) in
        if node.frames.contains(self.currentFrameIndex) {
          node.frames.remove(at: self.currentFrameIndex)
          node.displayFrame(index: 0)
        }
      }
      self.currentFrameIndex = 0
      self.totalFrames -= 1
    }
  }
  
  func duplicateFrame() {
    self.allNodes { (node) in
      if let color = node.colorIndex(atFrame: self.currentFrameIndex) {
        node.setFrame(color: color, atIndex: self.currentFrameIndex + 1)
      }
    }
    self.currentFrameIndex += 1
    self.totalFrames += 1
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
  
  func copyCurrentFrame() {
    self.copiedFrame = self.nodes.map { $0.colorIndex(atFrame: self.currentFrameIndex)!}
  }
  
  func pasteInCurrentFrame() {
    for (index, color) in self.copiedFrame!.enumerated() {
      if self.nodes.indices.contains(index) {
        let node = self.nodes[index]
        node.setFrame(color: color, atIndex: self.currentFrameIndex)
      }
    }
  }
  
  /// Loads an predefined animation on the current canvas.
  ///
  /// - Parameter animation: An array containing an array of Int representing the color indexes (of a color palette) that each PixelNode in the canvas will go through.
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


