//
//  CombatTestView.swift
//  intercombatsystem
//
//  Created by Uli Kusterer on 18/10/15.
//  Copyright © 2015 Uli Kusterer. All rights reserved.
//

import Cocoa
import intercombatsystem_cpp

class CombatTestView: NSView {
	
	var playerPosition : NSPoint = NSPoint( x: 0, y: -50 )
	var	playerAngle : Double = 0.0
	var	targetAngle : Double = 0.0
	var playerTargetAngle : Double
	{
		get
		{
			var	playerTargetAngle = atan2( 0.0, 0.0 )
			let	targetPosition = NSZeroPoint
			if( (playerPosition.x > targetPosition.x) )
			{
				playerTargetAngle = atan2( Double(playerPosition.x - targetPosition.x), Double(targetPosition.y - playerPosition.y) );
			}
			else if( (playerPosition.x < targetPosition.x) )
			{
				playerTargetAngle = (M_PI * 2.0) - atan2( Double(targetPosition.x - playerPosition.x), Double(targetPosition.y - playerPosition.y) );
			}
			
			//Swift.print("playerAngle: \(Double(playerAngle * 180.0) / M_PI)")
			//Swift.print("playerTargetAngle: \((playerTargetAngle * 180.0) / M_PI)")
			var	playerTargetAngleRelative = (playerTargetAngle - playerAngle)
			if( -playerTargetAngleRelative > M_PI )
			{
				playerTargetAngleRelative = (M_PI * 2) + playerTargetAngleRelative
			}
			if( playerTargetAngleRelative > M_PI )
			{
				playerTargetAngleRelative = -((M_PI * 2) - playerTargetAngleRelative)
			}
			//Swift.print("playerTargetAngle (relative): \((playerTargetAngleRelative * 180.0) / M_PI)")
			
			return playerTargetAngleRelative
		}
	}
	var playerTargetDistance : CGFloat
	{
		get
		{
			let	targetPosition = NSZeroPoint
			var	distance : CGFloat = 0.0;
			
			let xdiff = playerPosition.x - targetPosition.x;
			let ydiff = playerPosition.y - targetPosition.y;
			distance = sqrt( (xdiff * xdiff) + (ydiff * ydiff) )
			
			return distance;
		}
	}
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
		
		NSGraphicsContext.saveGraphicsState()
		
		// Make our coordinate system centered in window to make for more sensible resizing:
		let	tf : NSAffineTransform = NSAffineTransform()
		tf.translateXBy( self.bounds.width / 2, yBy: self.bounds.height / 2 )
		tf.set()
		
		// Draw target:
		let		targetSize : CGFloat = 32.0
		let		targetSizeSixth = targetSize / 6.0
		let		targetSizeHalf = targetSize / 2.0
		let		box : NSRect = NSRect( x: -targetSizeHalf, y: -targetSizeHalf, width: targetSize, height: targetSize)
		NSColor.whiteColor().set()
        NSBezierPath(ovalInRect: box).fill()
		NSColor.blackColor().set()
        NSBezierPath(ovalInRect: box).stroke()
		NSColor.redColor().set()
        NSBezierPath(ovalInRect: box.insetBy(dx: targetSizeSixth, dy: targetSizeSixth) ).stroke()
        NSBezierPath(ovalInRect: box.insetBy(dx: targetSizeSixth * 2, dy: targetSizeSixth * 2) ).stroke()
		NSBezierPath.strokeLineFromPoint( NSPoint( x: -targetSizeHalf, y: 0), toPoint: NSPoint( x: targetSizeHalf, y: 0) )
		NSBezierPath.strokeLineFromPoint( NSPoint( x: 0, y: -targetSizeHalf), toPoint: NSPoint( x: 0, y: targetSizeHalf) )

		NSGraphicsContext.saveGraphicsState()
		let tf2 : NSAffineTransform = NSAffineTransform()
		tf2.rotateByRadians( CGFloat(targetAngle) )
		tf2.concat()
		
		NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 0.6).set()
		let		triangle = NSBezierPath()
		triangle.moveToPoint( NSPoint( x: -6.0, y: targetSizeHalf ) )
		triangle.lineToPoint( NSPoint( x: -0.0, y: targetSizeHalf + 8.0 ) )
		triangle.lineToPoint( NSPoint( x: 6.0, y: targetSizeHalf ) )
		triangle.lineToPoint( NSPoint( x: -6.0, y: targetSizeHalf ) )
		triangle.fill()
		NSGraphicsContext.restoreGraphicsState()

		// Draw player:
		let		playerSize : CGFloat = 32.0
		let		playerSizeHalf = playerSize / 2.0
		let		playerBox : NSRect = NSRect( x: playerPosition.x - playerSizeHalf, y: playerPosition.y - playerSizeHalf, width: playerSize, height: playerSize)
		NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 0.6).set()
        NSBezierPath(ovalInRect: playerBox).fill()
		NSColor.blueColor().set()
        NSBezierPath(ovalInRect: playerBox).stroke()
		
		NSGraphicsContext.saveGraphicsState()
		let tf3 : NSAffineTransform = NSAffineTransform()
		tf3.translateXBy( playerPosition.x, yBy: playerPosition.y )
		tf3.rotateByRadians( CGFloat(playerAngle) )
		tf3.concat()
		
		NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 0.6).set()
		let		triangle2 = NSBezierPath()
		triangle2.moveToPoint( NSPoint( x: -6.0, y: playerSizeHalf ) )
		triangle2.lineToPoint( NSPoint( x: -0.0, y: playerSizeHalf + 8.0 ) )
		triangle2.lineToPoint( NSPoint( x: 6.0, y: playerSizeHalf ) )
		triangle2.lineToPoint( NSPoint( x: -6.0, y: playerSizeHalf ) )
		triangle2.fill()
		NSGraphicsContext.restoreGraphicsState()
		
		NSGraphicsContext.restoreGraphicsState()
    }
	
	override func mouseDown(theEvent: NSEvent) {
		if( self.window!.firstResponder != self )
		{
			self.window?.makeFirstResponder( self )
			return;
		}
		var	hitPosition = self.convertPoint( theEvent.locationInWindow, fromView: nil )
		hitPosition.x -= self.bounds.width / 2
		hitPosition.y -= self.bounds.height / 2
		playerPosition = hitPosition
		self.refreshDisplay();
	}

	override func mouseDragged(theEvent: NSEvent) {
		var	hitPosition = self.convertPoint( theEvent.locationInWindow, fromView: nil )
		hitPosition.x -= self.bounds.width / 2
		hitPosition.y -= self.bounds.height / 2
		playerPosition = hitPosition
		self.refreshDisplay();
	}
	
	override func keyDown(theEvent: NSEvent) {
		interpretKeyEvents([theEvent])
	}
	
	func normalizeAngle( angle : Double ) -> Double
	{
		if( angle >= (M_PI * 2.0) )
		{
			return angle - (M_PI * 2.0);
		}
		if( angle < 0.0 )
		{
			return angle + (M_PI * 2.0);
		}
		return angle
	}

	override func moveLeft(sender: AnyObject?) {
		if NSApplication.sharedApplication().currentEvent!.modifierFlags.contains( .ShiftKeyMask )
		{
			targetAngle += (M_PI / 180.0) * 6.0
			targetAngle = normalizeAngle(targetAngle)
		}
		else
		{
			playerAngle += (M_PI / 180.0) * 6.0
			playerAngle = normalizeAngle(playerAngle)
		}
		self.refreshDisplay();
	}
	
	override func moveRight(sender: AnyObject?) {
		if NSApplication.sharedApplication().currentEvent!.modifierFlags.contains( .ShiftKeyMask )
		{
			targetAngle -= (M_PI / 180.0) * 6.0
			targetAngle = normalizeAngle(targetAngle)
		}
		else
		{
			playerAngle -= (M_PI / 180.0) * 6.0
			playerAngle = normalizeAngle(playerAngle)
		}
		self.refreshDisplay();
	}
	
	override func becomeFirstResponder() -> Bool {
		return true
	}
	
	func refreshDisplay() {
		
		Swift.print("playerTargetAngle (relative): \((self.playerTargetAngle * 180.0) / M_PI)")
		Swift.print("playerTargetDistance: \(self.playerTargetDistance)")
		
		self.setNeedsDisplayInRect( self.bounds );
		
		let s : intercombatsystem_cpp.intercombatsystem = intercombatsystem_cpp.intercombatsystem()
		s.method()
	}
}
