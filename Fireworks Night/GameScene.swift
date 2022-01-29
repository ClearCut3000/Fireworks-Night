//
//  GameScene.swift
//  Fireworks Night
//
//  Created by Николай Никитин on 27.01.2022.
//

import SpriteKit

class GameScene: SKScene {

  //MARK: - Properties
  var gameTimer: Timer?
  var fireworks = [SKNode]()
  var scoreLabel: SKLabelNode!
  var roundLabel: SKLabelNode!

  let leftEdge = -22
  let bottomEdge = -22
  let rightEdge = 1024 + 22

  var score = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  var round = 1 {
    didSet {
      roundLabel.text = "Round: \(round)"
    }
  }

  //MARK: - UIScene
  override func didMove(to view: SKView) {
    let background = SKSpriteNode(imageNamed: "background")
    background.position = CGPoint(x: 512, y: 384)
    background.blendMode = .replace
    background.zPosition = -1
    addChild(background)

    scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    scoreLabel.horizontalAlignmentMode = .left
    scoreLabel.position = CGPoint(x: 50, y: 50)
    scoreLabel.text = "Score: 0"
    addChild(scoreLabel)

    roundLabel = SKLabelNode(fontNamed: "Chalkduster")
    roundLabel.horizontalAlignmentMode = .left
    roundLabel.position = CGPoint(x: 800, y: 50)
    roundLabel.text = "Round: 1"
    addChild(roundLabel)

    gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
  }

  //MARK: - UIMethods
  func createFirework(xMovement:CGFloat, x: Int, y: Int) {
    let node = SKNode()
    node.position = CGPoint(x: x, y: y)

    let firework = SKSpriteNode(imageNamed: "rocket")
    firework.colorBlendFactor = 1
    firework.name = "firework"
    node.addChild(firework)

    switch Int.random(in: 0...2) {
    case 0:
      firework.color = .cyan
    case 1:
      firework.color = .green
    default:
      firework.color = .red
    }

    let path = UIBezierPath()
    path.move(to: .zero)
    path.addLine(to: CGPoint(x: xMovement, y: 1000))
    let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
    node.run(move)

    if let emitter = SKEmitterNode(fileNamed: "fuse") {
      emitter.position = CGPoint(x: 0, y: -22)
      node.addChild(emitter)
    }
    fireworks.append(node)
    addChild(node)
  }

  @objc func launchFireworks() {
    if round >= 10 {
      gameOver()
    } else {
      round += 1
    }
    let movementAmount: CGFloat = 1800
    switch Int.random(in: 0...3) {
    case 0:
      createFirework(xMovement: 0, x: 512, y: bottomEdge)
      createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
      createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
      createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
      createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
    case 1:
      createFirework(xMovement: 0, x: 512, y: bottomEdge)
      createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
      createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
      createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
      createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
    case 2:
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
      createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
    case 3:
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
      createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
    default:
      break
    }
  }

  func gameOver() {
    gameTimer?.invalidate()
    let alert = UIAlertController(title: "Game Over, bro!", message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: "Restart Game", style: .default, handler: { [self] (_) in
      score = 0
      round = 1
      fireworks.removeAll()
      gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }))
    DispatchQueue.main.async {
      self.view?.window?.rootViewController?.present(alert, animated: true)
    }
  }

  func explode(firework: SKNode) {
    if let emitter = SKEmitterNode(fileNamed: "explode") {
      emitter.position = firework.position
      addChild(emitter)
      let removeAction = SKAction.run { emitter.removeFromParent() }
      let waitAction = SKAction.wait(forDuration: 2.0)
      emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    firework.removeFromParent()
  }

  func explodeFireworks() {
    var numExploded = 0
    for (index, fireworkContainer) in fireworks.enumerated().reversed() {
      guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
      if firework.name == "selected" {
        explode(firework: fireworkContainer)
        fireworks.remove(at: index)
        numExploded += 1
      }
    }
    switch numExploded {
    case 0:
      break
    case 1:
      score += 100
    case 2:
      score += 500
    case 3:
      score += 1500
    case 4:
      score += 2500
    default:
      score += 4000
    }
  }

  //MARK: - UITouches methods
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    chechTouches(touches)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    chechTouches(touches)
  }

  override func update(_ currentTime: TimeInterval) {
    for (index, firework) in fireworks.enumerated().reversed() {
      if firework.position.y > 900 {
        fireworks.remove(at:index)
        firework.removeFromParent()
      }
    }
  }

  func chechTouches(_ touches: Set<UITouch>) {
    guard let touch = touches.first else { return }

    let location = touch.location(in: self)
    let nodesAtPoint = nodes(at: location)

    for case let node as SKSpriteNode in nodesAtPoint {
      guard node.name == "firework" else { continue }

      for parent in fireworks {
        guard let firework = parent.children.first as? SKSpriteNode else { continue }
        if firework.name == "selected" && firework.color != node.color {
          firework.name = "firework"
          firework.colorBlendFactor = 1
        }
      }
      node.name = "selected"
      node.colorBlendFactor = 0
    }
  }
}
