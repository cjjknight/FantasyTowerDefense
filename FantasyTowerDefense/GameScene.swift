//
//  GameScene.swift
//  FantasyTowerDefense
//
//  Created by Christopher Johnson on 8/10/24.
//

import Foundation
import SpriteKit
import SwiftUI

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.green
        createPath()
    }
    
    func createPath() {
        // Create a simple path for enemies to follow
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 100, y: 100))
        path.addLine(to: CGPoint(x: 300, y: 100))
        path.addLine(to: CGPoint(x: 300, y: 300))
        path.addLine(to: CGPoint(x: 100, y: 300))
        path.close()
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.strokeColor = .red
        shapeNode.lineWidth = 5
        addChild(shapeNode)
    }
}
