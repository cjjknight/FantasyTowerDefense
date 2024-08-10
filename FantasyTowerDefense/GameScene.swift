import SpriteKit
import SwiftUI

class GameScene: SKScene {
    
    let pathDuration: TimeInterval = 10.0
    let towerRange: CGFloat = 150.0  // Maximum range of the tower
    let enemyInitialHealth: Int = 3  // Initial health for each enemy
    let projectileDamage: Int = 1  // Damage each projectile does to the enemy
    
    var currentLevel: Int = 1
    var currentWave: Int = 0
    var enemiesPerWave: Int = 5
    var enemySpawnInterval: TimeInterval = 1.0  // Time interval between enemy spawns within a wave
    var timeBetweenWaves: TimeInterval = 5.0  // Time interval between waves
    
    var goButton: SKSpriteNode!

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.green
        createPath()
        createTower()
        setupGoButton()
        showGoButton()
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
    
    func setupGoButton() {
        goButton = SKSpriteNode(imageNamed: "go_icon") // Replace with your own Go button icon
        goButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        goButton.zPosition = 10
        goButton.name = "goButton"
        addChild(goButton)
    }
    
    func showGoButton() {
        goButton.isHidden = false
    }
    
    func hideGoButton() {
        goButton.isHidden = true
    }
    
    func startNextWave() {
        hideGoButton()
        currentWave += 1
        let spawnEnemiesAction = SKAction.run { [weak self] in
            self?.spawnEnemies(forWave: self?.currentWave ?? 1)
        }
        let delayAction = SKAction.wait(forDuration: timeBetweenWaves)
        let sequence = SKAction.sequence([spawnEnemiesAction, delayAction])
        run(sequence)
    }
    
    func spawnEnemies(forWave wave: Int) {
        let totalEnemies = enemiesPerWave + (wave - 1) * 2  // Increase number of enemies with each wave
        let healthMultiplier = wave + currentLevel - 1  // Increase enemy health with each level and wave
        let spawnAction = SKAction.run { [weak self] in
            self?.createEnemy(withHealth: (self?.enemyInitialHealth ?? 3) * healthMultiplier)
        }
        let waitAction = SKAction.wait(forDuration: enemySpawnInterval)
        let spawnSequence = SKAction.sequence([spawnAction, waitAction])
        let repeatAction = SKAction.repeat(spawnSequence, count: totalEnemies)
        
        run(repeatAction, completion: { [weak self] in
            self?.waveCompleted()
        })
    }
    
    func waveCompleted() {
        if currentWave >= 3 {
            levelCompleted()
        } else {
            showGoButton()
        }
    }
    
    func levelCompleted() {
        currentLevel += 1
        currentWave = 0
        
        if currentLevel > 3 {
            print("Game Completed!")
            // Show game completed message or transition to a new scene
        } else {
            print("Level \(currentLevel) Completed!")
            // Show level completed message
            showGoButton()
        }
    }
    
    func createEnemy(withHealth health: Int) {
        // Create a simple circular enemy
        let enemy = SKShapeNode(circleOfRadius: 20)
        enemy.fillColor = .blue
        enemy.name = "enemy"
        
        // Initialize and safely set health using userData
        enemy.userData = NSMutableDictionary()
        enemy.userData?["health"] = health
        
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
        projectile.name = "projectile"
        
        addChild(projectile)
        
        // Move towards the target dynamically and faster
        let moveAction = SKAction.customAction(withDuration: 0.5) { [weak self] node, elapsedTime in
            guard let self = self else { return }
            if target.parent != nil {
                let dx = target.position.x - node.position.x
                let dy = target.position.y - node.position.y
                let angle = atan2(dy, dx)
                let velocity: CGFloat = 500.0 // Speed of the projectile
                let vx = cos(angle) * velocity * CGFloat(elapsedTime)
                let vy = sin(angle) * velocity * CGFloat(elapsedTime)
                node.position = CGPoint(x: node.position.x + vx, y: node.position.y + vy)
                
                // Check for collision
                if node.frame.intersects(target.frame) {
                    self.applyDamage(to: target, damage: self.projectileDamage)
                    node.removeFromParent()  // Ensure the projectile is removed after the hit
                }
            } else {
                node.removeFromParent()  // Remove projectile if the target is gone
            }
        }
        
        projectile.run(SKAction.repeatForever(moveAction))
    }
    
    func applyDamage(to enemy: SKNode, damage: Int) {
        // Safely access and modify the enemy's health
        if var health = enemy.userData?["health"] as? Int {
            health -= damage
            if health <= 0 {
                enemy.removeFromParent()
            } else {
                enemy.userData?["health"] = health
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Detect touch on the Go button
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            for node in touchedNodes {
                if node.name == "goButton" {
                    startNextWave()
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Optionally, you can add logic here to remove enemies that reach the end of the path
        // or handle game state updates.
    }
}
