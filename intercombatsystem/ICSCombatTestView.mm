//
//  ICSCombatTestView.m
//  intercombatsystem
//
//  Created by Uli Kusterer on 18.08.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

#import "ICSCombatTestView.h"
#import "intercombatsystem.hpp"


@interface ICSCombatTestView ()
{
	intercombatactor _player;
	intercombatactor _target;
	NSTimeInterval _startTime;
}

@property BOOL shooting;
@property BOOL didHit;
@property BOOL showHealth;
@property NSTimer * replenishTimer;

@end


@implementation ICSCombatTestView

-(void)	dealloc
{
	[self.replenishTimer invalidate];
}


-(void)	awakeFromNib
{
	_startTime = NSDate.timeIntervalSinceReferenceDate;
	
	__weak typeof(self) weakSelf = self;
	
	_target.set_buff_changed_handler([weakSelf](intercombatactor& inTarget, buff& inBuff)
	{
		static double lastNotifiedValue = 100.0;
		
		typeof(self) strongSelf = weakSelf;
		if (strongSelf && truncf(inBuff.get_amount()) != lastNotifiedValue)
		{
			strongSelf.showHealth = YES;
			[strongSelf refreshDisplay];
			[NSRunLoop.currentRunLoop cancelPerformSelector: @selector(removeShot:) target: strongSelf argument: nil];
			[strongSelf performSelector: @selector(removeShot:) withObject: nil afterDelay: 0.5];
			lastNotifiedValue = truncf(inBuff.get_amount());
		}
	});
	_player.set_y( -50 );
	buff shield( 1, 100.0, 100.0, -M_PI, M_PI * 2, -1.0, 0.0, 0.0, 5.0, timestamp(30), 0.5, false );
	_target.add_buff( shield );
	buff plasma_resistance( 1, 100.0, 100.0, -M_PI, M_PI * 2, -1.0, 0.0, 0.0, 0.0, timestamp(30), 0.0, true );
	_target.add_buff( plasma_resistance );
	_target.set_health( 100.0 );
	
	[self.window makeFirstResponder: self];
	
	self.replenishTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
		typeof(self) strongSelf = weakSelf;
		if (strongSelf)
		{
			timestamp currentTime = strongSelf.currentTime;
			strongSelf->_player.replenish_buffs(true, currentTime);
			strongSelf->_target.replenish_buffs(true, currentTime);
		}
	}];
}


-(timestamp)	currentTime
{
	return timestamp((NSDate.timeIntervalSinceReferenceDate - _startTime) * 10.0);
}


/**
 Draw our view contents, i.e. a player, a target, direction indicators etc.
 */
-(void) drawRect:(NSRect)dirtyRect
{
	[NSColor.whiteColor set];
	[NSBezierPath fillRect: self.bounds];
	
	[NSGraphicsContext saveGraphicsState];
	
	// Make our coordinate system centered in window to make for more sensible resizing:
	NSAffineTransform * tf = [NSAffineTransform transform];
	[tf translateXBy: self.bounds.size.width / 2 yBy: self.bounds.size.height / 2];
	[tf set];
	
	// Draw target:
	CGFloat		targetSize = 32.0;
	CGFloat		targetSizeSixth = targetSize / 6.0;
	CGFloat		targetSizeHalf = targetSize / 2.0;
	NSRect		box = NSMakeRect( -targetSizeHalf, -targetSizeHalf, targetSize, targetSize);
	[NSColor.whiteColor set];
	[[NSBezierPath bezierPathWithOvalInRect: box] fill];
	[NSColor.blackColor set];
	[[NSBezierPath bezierPathWithOvalInRect: box] stroke];
	[NSColor.redColor set];
	[[NSBezierPath bezierPathWithOvalInRect: NSInsetRect(box, targetSizeSixth,  targetSizeSixth) ] stroke];
	[[NSBezierPath bezierPathWithOvalInRect: NSInsetRect(box, targetSizeSixth * 2,  targetSizeSixth * 2) ] stroke];
	[NSBezierPath strokeLineFromPoint:  NSMakePoint( -targetSizeHalf, 0 ) toPoint:  NSMakePoint( targetSizeHalf, 0 ) ];
	[NSBezierPath strokeLineFromPoint:  NSMakePoint( 0, -targetSizeHalf ) toPoint:  NSMakePoint( 0, targetSizeHalf ) ];
	
	[NSGraphicsContext saveGraphicsState];
	NSAffineTransform * tf2 = [NSAffineTransform transform];
	[tf2 rotateByRadians: _target.get_angle()];
	[tf2 concat];
	
	[[NSColor colorWithCalibratedRed: 1 green: 0 blue: 0 alpha: 0.6] set];
	NSBezierPath * triangle = [NSBezierPath bezierPath];
	[triangle moveToPoint: NSMakePoint( -6.0, targetSizeHalf )];
	[triangle lineToPoint: NSMakePoint( -0.0, targetSizeHalf + 8.0 )];
	[triangle lineToPoint: NSMakePoint( 6.0, targetSizeHalf )];
	[triangle lineToPoint: NSMakePoint( -6.0, targetSizeHalf )];
	[triangle fill];
	[NSGraphicsContext restoreGraphicsState];
	
	// Draw player:
	CGFloat	playerSize = 32.0;
	CGFloat	playerSizeHalf = playerSize / 2.0;
	NSRect playerBox = NSMakeRect( _player.get_x() - playerSizeHalf, _player.get_y() - playerSizeHalf, playerSize, playerSize );
	[[NSColor colorWithCalibratedRed: 0 green: 0 blue: 1 alpha: 0.6] set];
	[[NSBezierPath bezierPathWithOvalInRect: playerBox] fill];
	[NSColor.blueColor set];
	[[NSBezierPath bezierPathWithOvalInRect: playerBox] stroke];
	
	[NSGraphicsContext saveGraphicsState];
	NSAffineTransform * tf3 = [NSAffineTransform transform];
	[tf3 translateXBy: _player.get_x() yBy: _player.get_y()];
	[tf3 rotateByRadians: _player.get_angle()];
	[tf3 concat];
	
	[[NSColor colorWithCalibratedRed: 0 green: 0 blue: 1 alpha: 0.6] set];
	NSBezierPath * triangle2 = [NSBezierPath bezierPath];
	[triangle2 moveToPoint:  NSMakePoint( -6.0, playerSizeHalf  ) ];
	[triangle2 lineToPoint:  NSMakePoint( -0.0, playerSizeHalf + 8.0  ) ];
	[triangle2 lineToPoint:  NSMakePoint( 6.0, playerSizeHalf  ) ];
	[triangle2 lineToPoint:  NSMakePoint( -6.0, playerSizeHalf  ) ];
	[triangle2 fill];
	[NSGraphicsContext restoreGraphicsState];
	
	if( self.showHealth )
	{
		CGFloat health = _target.get_health();
		if( health > 0)
		{
			CGFloat	shieldHealth = _target.get_value( 1 );
			if( shieldHealth > 0 )
			{
				[[NSString stringWithFormat: @"%.0f", shieldHealth] drawAtPoint: NSMakePoint( _target.get_x(), _target.get_y( ) + playerSizeHalf + 48.0 ) withAttributes: @{ NSForegroundColorAttributeName: NSColor.cyanColor, NSFontAttributeName: [NSFont systemFontOfSize: 18 weight: 500] }];
			}
			[[NSString stringWithFormat: @"%.0f", health] drawAtPoint: NSMakePoint( _target.get_x(), _target.get_y( ) + playerSizeHalf + 24.0 ) withAttributes: @{ NSForegroundColorAttributeName: NSColor.blackColor, NSFontAttributeName: [NSFont systemFontOfSize: 18 weight: 500] }];
		}
		else
		{
			[@"X" drawAtPoint: NSMakePoint( _target.get_x(), _target.get_y() + playerSizeHalf + 24.0 ) withAttributes: @{ NSForegroundColorAttributeName: NSColor.redColor, NSFontAttributeName: [NSFont systemFontOfSize: 48 weight: 500] }];
		}
	}

	// Draw shot, if any:
	if( self.shooting )
	{
		NSPoint playerPos = NSMakePoint( _player.get_x(), _player.get_y() );
		NSPoint startPos = [self pointAtAngleInRadians: _player.get_angle() distance: playerSizeHalf fromPoint: playerPos];
		[NSColor.redColor set];
		if( self.didHit )
		{
			[NSBezierPath strokeLineFromPoint: startPos toPoint: NSMakePoint( _target.get_x(), _target.get_y() )];
		}
		else	// No hit? Shoot straight ahead and stop in emptiness:
		{
			CGFloat	attackRange = [self attackWithCurrentWeapon].get_max_distance();
			NSPoint startPos = [self pointAtAngleInRadians: _player.get_angle() distance: playerSizeHalf fromPoint: playerPos];
			NSPoint targetPos = [self pointAtAngleInRadians: _player.get_angle() distance: attackRange fromPoint: playerPos];
			[NSBezierPath strokeLineFromPoint: startPos toPoint: targetPos];
		}
	}
	
	[NSGraphicsContext restoreGraphicsState];
}


-(NSPoint) pointAtAngleInRadians: (CGFloat)radians distance: (CGFloat)theDistance fromPoint: (NSPoint)thePoint
{
	CGFloat	angle = radians + (M_PI / 2.0);
	if( angle > (M_PI * 2.0) )
	{
		angle -= M_PI * 2.0;
	}
	return NSMakePoint( thePoint.x + theDistance * cos( angle ), thePoint.y + theDistance * sin( angle ) );
}


/**
 Move the player to the position indicated by a click.
 */
-(void)	mouseDown: (NSEvent *)theEvent
{
	if( self.window.firstResponder != self )	// Not yet have keyboard focus? User prolly wants that.
	{
		[self.window makeFirstResponder: self];	// Focus.
		return;									// Don't move player, user might just want to rotate player.
	}
	NSPoint hitPosition = [self convertPoint: theEvent.locationInWindow fromView: nil];
	hitPosition.x -= self.bounds.size.width / 2;
	hitPosition.y -= self.bounds.size.height / 2;
	_player.set_x( hitPosition.x );
	_player.set_y( hitPosition.y );
	[self refreshDisplay];
}


/**
 Move the player to the position indicated by a click.
 */
-(void)	mouseDragged: (NSEvent *)theEvent
{
	NSPoint hitPosition = [self convertPoint: theEvent.locationInWindow fromView: nil];
	hitPosition.x -= self.bounds.size.width / 2;
	hitPosition.y -= self.bounds.size.height / 2;
	_player.set_x( hitPosition.x );
	_player.set_y( hitPosition.y );
	[self refreshDisplay];
}


-(void)	keyDown: (NSEvent *)theEvent
{
	[self interpretKeyEvents: @[theEvent]];
}


/**
 Handle left arrow key by rotating player.
 */
-(void)	moveLeft: (id)sender
{
	_player.turn_by_radians( (M_PI / 180.0) * 6.0 );
	[self refreshDisplay];
}


/**
 Handle alt + left arrow key by rotating target.
 */
-(void)	moveWordLeft: (id)sender
{
	_target.turn_by_radians( (M_PI / 180.0) * 6.0 );
	[self refreshDisplay];
}


/**
 Handle right arrow key and shift + right arrow key by rotating player or target, respectively.
 */
-(void)	moveRight: (id)sender
{
	_player.turn_by_radians( -(M_PI / 180.0) * 6.0 );
	[self refreshDisplay];
}


/**
 Handle shift + right arrow key by rotating target.
 */
-(void)	moveWordRight: (id)sender
{
	_target.turn_by_radians( -(M_PI / 180.0) * 6.0 );
	[self refreshDisplay];
}


-(buff) attackWithCurrentWeapon
{
	return buff( 1, -10, -1.0, -(M_PI / 4), M_PI / 2, 100.0, 0.0, 0.0, 0.0, timestamp(0), 0.0, false );
}


-(void)	moveUp: (id)sender
{
	buff attack = [self attackWithCurrentWeapon];
	self.shooting = YES;
	self.didHit = _target.hit( attack, self.currentTime, _player );
	if (self.didHit)
	{
		self.showHealth = YES;
	}
	[self refreshDisplay];
	[NSRunLoop.currentRunLoop cancelPerformSelector: @selector(removeShot:) target: self argument: nil];
	[self performSelector: @selector(removeShot:) withObject: nil afterDelay: 0.5];
}


-(void)	removeShot:(id)sender
{
	self.shooting = NO;
	self.showHealth = NO;
	[self setNeedsDisplayInRect: self.bounds];
}


/**
 Enable us to handle keypresses.
 */
-(BOOL) becomeFirstResponder
{
	return YES;
}


/**
 Redraw the view and print out the current state of player and target.
 */
-(void) refreshDisplay
{
	
	NSLog( @"playerTargetAngle (relative): %f", (_player.radian_angle_to_actor( _target ) * 180.0) / M_PI );
	NSLog( @"playerTargetDistance: %f", _player.distance_to_actor( _target ) );
	
	[self setNeedsDisplayInRect: self.bounds];
}

@end
