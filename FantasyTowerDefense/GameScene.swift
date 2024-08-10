import SpriteKit
import SwiftUI

class GameScene: SKScene {
    
    let startPosition = CGPoint(x: 100, y: 100)
    let pathDuration: TimeInterval = 5.0
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.green
        createPath()
        createEnemy()
    }
    
    func createPath() {
        // Create a simple path for enemies to follow
        let path = UIBezierPath()
        path.move(to: startPosition)
        path.addLine(to: CGPoint(x: 300, y: 100))
        path.addLine(to: CGPoint(x: 300, y: 300))
        path.addLine(to: CGPoint(x: 100, y: 300))
        path.close()
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.strokeColor = .red
        shapeNode.lineWidth = 5
        shapeNode.name = "path"  // Name the path so it can be referenced
        addChild(shapeNode)
    }
    
    func createEnemy() {
        // Create a simple circular enemy
        let enemy = SKShapeNode(circleOfRadius: 20)
        enemy.fillColor = .blue
        
        // Position the enemy at the start of the path
        if let pathNode = childNode(withName: "path") as? SKShapeNode,
           let path = pathNode.path {
            enemy.position = startPosition
            addChild(enemy)
            
            // Define the movement along the path
            let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: pathDuration)
            enemy.run(moveAction)
        } else {
            print("Error: Path not found or invalid.")
        }
    }
}
