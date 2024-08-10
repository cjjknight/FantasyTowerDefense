import SpriteKit
import SwiftUI

class GameScene: SKScene {
    
    let startPosition = CGPoint(x: 100, y: 100)
    let pathDuration: TimeInterval = 5.0
    let towerRange: CGFloat = 150.0  // Maximum range of the tower
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.green
        createPath()
        createTower()
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
        enemy.name = "enemy"
        
        // Position the enemy at the start of the path
        if let pathNode = childNode(withName: "path") as? SKShapeNode,
           let path = pathNode.path {
            enemy.position = startPosition
            addChild(enemy)
            
            // Define the movement along the path
            let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: pathDuration)
            let removeAction = SKAction.removeFromParent()
            let sequence = SKAction.sequence([moveAction, removeAction])
            
            enemy.run(sequence)
        } else {
            print("Error: Path not found or invalid.")
        }
    }
    
    func createTower() {
        // Create a simple square tower
        let tower = SKShapeNode(rectOf: CGSize(width: 40, height: 40))
        tower.fillColor = .brown
        tower.position = CGPoint(x: 200, y: 200) // Position the tower in the middle of the path
        tower.name = "tower"
        
        addChild(tower)
        
        // Shoot at the enemy if within range
        let shootAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            if let enemy = self.childNode(withName: "enemy") {
                let distance = hypot(enemy.position.x - tower.position.x, enemy.position.y - tower.position.y)
                if distance <= self.towerRange {
                    self.shootProjectile(from: tower, to: enemy)
                }
            }
        }
        let waitAction = SKAction.wait(forDuration: 1.0)
        let repeatAction = SKAction.repeatForever(SKAction.sequence([shootAction, waitAction]))
        
        tower.run(repeatAction)
    }
    
    func shootProjectile(from tower: SKShapeNode, to target: SKNode) {
        let projectile = SKShapeNode(circleOfRadius: 10)
        projectile.fillColor = .gray
        projectile.position = tower.position
        
        addChild(projectile)
        
        // Move towards the target dynamically
        let moveAction = SKAction.move(to: target.position, duration: 1.0)
        let checkTargetExistsAction = SKAction.run { [weak self, weak projectile] in
            if target.parent == nil {
                projectile?.removeFromParent()
            }
        }
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, checkTargetExistsAction, removeAction])
        
        projectile.run(sequence)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Optionally, you can add logic here to remove enemies that reach the end of the path
        // or handle game state updates.
    }
}
