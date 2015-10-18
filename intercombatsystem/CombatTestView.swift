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
	
	var	player : intercombatsystem_cpp.intercombatactor = .init()
	var	target : intercombatsystem_cpp.intercombatactor = .init()
	
	override func awakeFromNib() {
		let	shield = intercombatsystem_cpp.buff( type: 1, amount: 100.0, max_amount: 100.0, start_angle: -(M_PI / 4), relative_angle: M_PI * 2, max_distance: -1.0, bleedthrough: 0.0, permanent: false )
		target.add_buff( shield );
		let	plasma_resistance = intercombatsystem_cpp.buff( type: 1, amount: 100.0, max_amount: 100.0, start_angle: -(M_PI / 4), relative_angle: M_PI * 2, max_distance: -1.0, bleedthrough: 0.0, permanent: true )
		target.add_value( plasma_resistance );
		target.set_health( 100.0 )
	}
	
/**
Draw our view contents, i.e. a player, a target, direction indicators etc.
*/
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
		tf2.rotateByRadians( CGFloat(target.get_angle()) )
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
		let		playerSize = 32.0
		let		playerSizeHalf = playerSize / 2.0
		let		playerBox : NSRect = NSRect( x: player.get_x() - playerSizeHalf, y: player.get_y() - playerSizeHalf, width: playerSize, height: playerSize)
		NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 0.6).set()
        NSBezierPath(ovalInRect: playerBox).fill()
		NSColor.blueColor().set()
        NSBezierPath(ovalInRect: playerBox).stroke()
		
		NSGraphicsContext.saveGraphicsState()
		let tf3 : NSAffineTransform = NSAffineTransform()
		tf3.translateXBy( CGFloat(player.get_x()), yBy: CGFloat(player.get_y()) )
		tf3.rotateByRadians( CGFloat(player.get_angle()) )
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
	
/**
Move the player to the position indicated by a click.
*/
	override func mouseDown(theEvent: NSEvent) {
		if( self.window!.firstResponder != self )	// Not yet have keyboard focus? User prolly wants that.
		{
			self.window?.makeFirstResponder( self )	// Focus.
			return;									// Don't move player, user might just want to rotate player.
		}
		var	hitPosition = self.convertPoint( theEvent.locationInWindow, fromView: nil )
		hitPosition.x -= self.bounds.width / 2
		hitPosition.y -= self.bounds.height / 2
		player.set_x( Double(hitPosition.x) )
		player.set_y( Double(hitPosition.y) )
		self.refreshDisplay();
	}

/**
Move the player to the position indicated by a click.
*/
	override func mouseDragged(theEvent: NSEvent) {
		var	hitPosition = self.convertPoint( theEvent.locationInWindow, fromView: nil )
		hitPosition.x -= self.bounds.width / 2
		hitPosition.y -= self.bounds.height / 2
		player.set_x( Double(hitPosition.x) )
		player.set_y( Double(hitPosition.y) )
		self.refreshDisplay();
	}
	
	override func keyDown(theEvent: NSEvent) {
		interpretKeyEvents([theEvent])
	}
	
/**
Handle left arrow key and shift + left arrow key by rotating player or target, respectively.
*/
	override func moveLeft(sender: AnyObject?) {
		if NSApplication.sharedApplication().currentEvent!.modifierFlags.contains( .ShiftKeyMask )
		{
			target.turn_by_radians( (M_PI / 180.0) * 6.0 )
		}
		else
		{
			player.turn_by_radians( (M_PI / 180.0) * 6.0 )
		}
		self.refreshDisplay();
	}
	
/**
Handle right arrow key and shift + right arrow key by rotating player or target, respectively.
*/
	override func moveRight(sender: AnyObject?) {
		if NSApplication.sharedApplication().currentEvent!.modifierFlags.contains( .ShiftKeyMask )
		{
			target.turn_by_radians( -(M_PI / 180.0) * 6.0 )
		}
		else
		{
			player.turn_by_radians( -(M_PI / 180.0) * 6.0 )
		}
		self.refreshDisplay();
	}

	override func moveUp(sender: AnyObject?) {
		let	attack = intercombatsystem_cpp.buff( type: 1, amount: -10, max_amount: -1.0, start_angle: -(M_PI / 4), relative_angle: M_PI / 2, max_distance: 100.0, bleedthrough: 0.0, permanent: false )
		target.hit( attack, currDistance: player.distance_to_actor( target ), currAngle: player.radian_angle_to_actor( target ) )
		self.refreshDisplay();
	}
	
/**
Enable us to handle keypresses.
*/
	override func becomeFirstResponder() -> Bool {
		return true
	}
	
/**
Redraw the view and print out the current state of player and target.
*/
	func refreshDisplay() {
		
		Swift.print("playerTargetAngle (relative): \((self.player.radian_angle_to_actor( target ) * 180.0) / M_PI)")
		Swift.print("playerTargetDistance: \(self.player.distance_to_actor( target ))")
		
		self.setNeedsDisplayInRect( self.bounds );
	}
}
