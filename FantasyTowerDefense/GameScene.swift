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
    var enemiesCrossed: Int = 0  // Counter for enemies that successfully cross the screen
    
    var waveLabel: SKLabelNode!
    var goButton: SKSpriteNode!
    var enemyCounterLabel: SKLabelNode!
    var restartButton: SKSpriteNode!
    var isPlacingTowers: Bool = true // Control tower placement phase

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.green
        setupUI()
        createPath()
        setupTowerZones()
        showGoButton()
    }
    
    func createPath() {
        let path = UIBezierPath()
        let screenWidth = self.size.width
        let screenHeight = self.size.height
        
        let margin: CGFloat = 20.0
        
        path.move(to: CGPoint(x: margin, y: screenHeight / 2))
        path.addLine(to: CGPoint(x: screenWidth * 0.25, y: screenHeight * 0.75 - margin))
        path.addLine(to: CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.25 + margin))
        path.addLine(to: CGPoint(x: screenWidth * 0.75, y: screenHeight * 0.75 - margin))
        path.addLine(to: CGPoint(x: screenWidth - margin, y: screenHeight / 2))
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.strokeColor = .red
        shapeNode.lineWidth = 5
        shapeNode.name = "path"
        addChild(shapeNode)
    }
    
    func setupUI() {
        // Wave number label in the bottom left corner
        waveLabel = SKLabelNode(text: "Wave: 1")
        waveLabel.fontSize = 24
        waveLabel.fontColor = .white
        waveLabel.horizontalAlignmentMode = .left
        waveLabel.position = CGPoint(x: 20, y: 20)
        waveLabel.zPosition = 10
        addChild(waveLabel)
        
        // Go button in the bottom right corner
        goButton = SKSpriteNode(imageNamed: "go_icon") // Replace with your own Go button icon
        goButton.position = CGPoint(x: self.size.width - 60, y: 40)
        goButton.zPosition = 10
        goButton.name = "goButton"
        addChild(goButton)
        
        // Enemy counter in the top right corner
        enemyCounterLabel = SKLabelNode(text: "Enemies: 0")
        enemyCounterLabel.fontSize = 24
        enemyCounterLabel.fontColor = .white
        enemyCounterLabel.horizontalAlignmentMode = .right
        enemyCounterLabel.position = CGPoint(x: self.size.width - 20, y: self.size.height - 40)
        enemyCounterLabel.zPosition = 10
        addChild(enemyCounterLabel)
        
        // Restart button in the top left corner
        restartButton = SKSpriteNode(imageNamed: "restart_icon") // Replace with your own restart button icon
        restartButton.position = CGPoint(x: 40, y: self.size.height - 40)
        restartButton.zPosition = 10
        restartButton.name = "restartButton"
        addChild(restartButton)
    }
    
    func setupTowerZones() {
        // Define zones where towers can be placed
        let zones = [
            CGPoint(x: self.size.width * 0.2, y: self.size.height * 0.6),
            CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.3),
            CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.7)
        ]
        
        for zone in zones {
            let zoneNode = SKShapeNode(circleOfRadius: 30)
            zoneNode.fillColor = .gray
            zoneNode.position = zone
            zoneNode.name = "towerZone"
            zoneNode.zPosition = 5
            addChild(zoneNode)
        }
    }
    
    func updateWaveLabel() {
        waveLabel.text = "Wave: \(currentWave)"
    }
    
    func updateEnemyCounter() {
        enemyCounterLabel.text = "Enemies: \(enemiesCrossed)"
    }
    
    func showGoButton() {
        goButton.isHidden = false
        isPlacingTowers = true // Allow tower placement
    }
    
    func hideGoButton() {
        goButton.isHidden = true
        isPlacingTowers = false // Disable tower placement
    }
    
    func startNextWave() {
        hideGoButton()
        currentWave += 1
        updateWaveLabel()
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
            showGoButton()
        }
    }
    
    func createEnemy(withHealth health: Int) {
        let enemy = SKShapeNode(circleOfRadius: 20)
        enemy.fillColor = .blue
        enemy.name = "enemy"
        
        enemy.userData = NSMutableDictionary()
        enemy.userData?["health"] = health
        
        if let pathNode = childNode(withName: "path") as? SKShapeNode,
           let path = pathNode.path {
            enemy.position = CGPoint(x: 20, y: self.size.height / 2)
            addChild(enemy)
            
            let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: pathDuration)
            let removeAction = SKAction.removeFromParent()
            let sequence = SKAction.sequence([moveAction, SKAction.run { [weak self] in
                self?.enemyCrossed()
            }, removeAction])
            
            enemy.run(sequence)
        } else {
            print("Error: Path not found or invalid.")
        }
    }
    
    func enemyCrossed() {
        enemiesCrossed += 1
        updateEnemyCounter()
    }
    
    func createTower(at position: CGPoint) {
        let tower = SKShapeNode(rectOf: CGSize(width: 40, height: 40))
        tower.fillColor = .brown
        tower.position = position
        tower.name = "tower"
        
        addChild(tower)
        
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
        
        let moveAction = SKAction.customAction(withDuration: 0.5) { [weak self] node, elapsedTime in
            guard let self = self else { return }
            if target.parent != nil {
                let dx = target.position.x - node.position.x
                let dy = target.position.y - node.position.y
                let angle = atan2(dy, dx)
                let velocity: CGFloat = 500.0
                let vx = cos(angle) * velocity * CGFloat(elapsedTime)
                let vy = sin(angle) * velocity * CGFloat(elapsedTime)
                node.position = CGPoint(x: node.position.x + vx, y: node.position.y + vy)
                
                if node.frame.intersects(target.frame) {
                    self.applyDamage(to: target, damage: self.projectileDamage)
                    node.removeFromParent()
                }
            } else {
                node.removeFromParent()
            }
        }
        
        projectile.run(SKAction.repeatForever(moveAction))
    }
    
    func applyDamage(to enemy: SKNode, damage: Int) {
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
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            guard let node = touchedNodes.first else { return }

            if node.name == "goButton" && isPlacingTowers {
                startNextWave()
            } else if node.name == "towerZone" && isPlacingTowers {
                if node.children.isEmpty {
                    createTower(at: node.position)
                    node.removeFromParent()
                }
            } else if node.name == "restartButton" {
                restartGame()
            }
        }
    }
    
    func restartGame() {
        currentLevel = 1
        currentWave = 0
        enemiesCrossed = 0
        removeAllChildren()
        setupUI()
        createPath()
        setupTowerZones()
        updateWaveLabel()
        updateEnemyCounter()
        showGoButton()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
}
