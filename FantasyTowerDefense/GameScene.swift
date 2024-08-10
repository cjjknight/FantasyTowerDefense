import SpriteKit
import SwiftUI

class GameScene: SKScene {
    
    let pathDuration: TimeInterval = 10.0
    let towerRange: CGFloat = 150.0  // Maximum range of the tower
    let enemySpawnInterval: TimeInterval = 2.0  // Time interval between enemy spawns
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.green
        createPath()
        spawnEnemyLoop()
        createTower()
    }
    
    func createPath() {
        // Create a path that starts from the left side of the screen and ends on the right side
        let path = UIBezierPath()
        let screenWidth = self.size.width
        let screenHeight = self.size.height
        
        // Define safe margins to avoid going off-screen
        let margin: CGFloat = 20.0
        
        path.move(to: CGPoint(x: margin, y: screenHeight / 2))
        path.addLine(to: CGPoint(x: screenWidth * 0.25, y: screenHeight * 0.75 - margin))
        path.addLine(to: CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.25 + margin))
        path.addLine(to: CGPoint(x: screenWidth * 0.75, y: screenHeight * 0.75 - margin))
        path.addLine(to: CGPoint(x: screenWidth - margin, y: screenHeight / 2))
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.strokeColor = .red
        shapeNode.lineWidth = 5
        shapeNode.name = "path"  // Name the path so it can be referenced
        addChild(shapeNode)
    }
    
    func spawnEnemyLoop() {
        let waitAction = SKAction.wait(forDuration: enemySpawnInterval)
        let spawnAction = SKAction.run { [weak self] in
            self?.createEnemy()
        }
        let sequence = SKAction.sequence([waitAction, spawnAction])
        let repeatAction = SKAction.repeatForever(sequence)
        
        run(repeatAction)
    }
    
    func createEnemy() {
        // Create a simple circular enemy
        let enemy = SKShapeNode(circleOfRadius: 20)
        enemy.fillColor = .blue
        enemy.name = "enemy"
        
        // Position the enemy at the start of the path
        if let pathNode = childNode(withName: "path") as? SKShapeNode,
           let path = pathNode.path {
            enemy.position = CGPoint(x: 20, y: self.size.height / 2) // Start slightly within the left side of the screen
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
        // Ensure tower is placed away from the path
        let tower = SKShapeNode(rectOf: CGSize(width: 40, height: 40))
        tower.fillColor = .brown
        tower.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.25) // Position the tower away from the path
        tower.name = "tower"
        
        addChild(tower)
        
        // Shoot at the enemy if within range
        let shootAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            if let enemy = self.closestEnemy(to: tower) {
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
    
    func closestEnemy(to tower: SKNode) -> SKNode? {
        var closestEnemy: SKNode?
        var shortestDistance: CGFloat = towerRange
        
        self.enumerateChildNodes(withName: "enemy") { node, _ in
            let distance = hypot(node.position.x - tower.position.x, node.position.y - tower.position.y)
            if distance < shortestDistance {
                shortestDistance = distance
                closestEnemy = node
            }
        }
        
        return closestEnemy
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
