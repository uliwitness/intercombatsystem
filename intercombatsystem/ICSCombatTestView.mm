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

@property intercombatactor * player;
@property intercombatactor * target;
@property BOOL shooting;
@property BOOL didHit;

@end


@implementation ICSCombatTestView

-(instancetype)	initWithFrame: (NSRect)box
{
	self = [super initWithFrame: box];
	if (self)
	{
		self.player = new intercombatactor;
		self.target = new intercombatactor;
	}
	return self;
}

-(instancetype)	initWithCoder: (NSCoder *)decoder
{
	self = [super initWithCoder: decoder];
	if (self)
	{
		self.player = new intercombatactor;
		self.target = new intercombatactor;
	}
	return self;
}

-(void)	dealloc
{
	delete self.player;
	self.player = nullptr;
	delete self.target;
	self.target = nullptr;
}

-(void)	awakeFromNib
{
	self.player->set_y( -50 );
	buff * shield = new buff( 1, 100.0, 100.0, -M_PI, M_PI * 2, -1.0, 0.0, false );
	self.target->add_buff( shield );
	buff * plasma_resistance = new buff( 1, 100.0, 100.0, -M_PI, M_PI * 2, -1.0, 0.0, true );
	self.target->add_buff( plasma_resistance );
	self.target->set_health( 100.0 );
	
	[self.window makeFirstResponder: self];
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
	[tf2 rotateByRadians: self.target->get_angle()];
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
	NSRect playerBox = NSMakeRect( self.player->get_x() - playerSizeHalf, self.player->get_y() - playerSizeHalf, playerSize, playerSize );
	[[NSColor colorWithCalibratedRed: 0 green: 0 blue: 1 alpha: 0.6] set];
	[[NSBezierPath bezierPathWithOvalInRect: playerBox] fill];
	[NSColor.blueColor set];
	[[NSBezierPath bezierPathWithOvalInRect: playerBox] stroke];
	
	[NSGraphicsContext saveGraphicsState];
	NSAffineTransform * tf3 = [NSAffineTransform transform];
	[tf3 translateXBy: self.player->get_x() yBy: self.player->get_y()];
	[tf3 rotateByRadians: self.player->get_angle()];
	[tf3 concat];
	
	[[NSColor colorWithCalibratedRed: 0 green: 0 blue: 1 alpha: 0.6] set];
	NSBezierPath * triangle2 = [NSBezierPath bezierPath];
	[triangle2 moveToPoint:  NSMakePoint( -6.0, playerSizeHalf  ) ];
	[triangle2 lineToPoint:  NSMakePoint( -0.0, playerSizeHalf + 8.0  ) ];
	[triangle2 lineToPoint:  NSMakePoint( 6.0, playerSizeHalf  ) ];
	[triangle2 lineToPoint:  NSMakePoint( -6.0, playerSizeHalf  ) ];
	[triangle2 fill];
	[NSGraphicsContext restoreGraphicsState];
	
	// Draw shot, if any:
	if( self.shooting )
	{
		if( self.didHit )
		{
			CGFloat health = self.target->get_health();
			if( health > 0)
			{
				CGFloat	shieldHealth = self.target->get_value( 1 );
				if( shieldHealth > 0 )
				{
					[[NSString stringWithFormat: @"%f", shieldHealth] drawAtPoint: NSMakePoint( self.target->get_x(), self.target->get_y( ) + playerSizeHalf + 48.0 ) withAttributes: @{ NSForegroundColorAttributeName: NSColor.cyanColor, NSFontAttributeName: [NSFont systemFontOfSize: 18 weight: 500] }];
				}
				[[NSString stringWithFormat: @"%f", health] drawAtPoint: NSMakePoint( self.target->get_x(), self.target->get_y( ) + playerSizeHalf + 24.0 ) withAttributes: @{ NSForegroundColorAttributeName: NSColor.blackColor, NSFontAttributeName: [NSFont systemFontOfSize: 18 weight: 500] }];
			}
			else
			{
				[@"X" drawAtPoint: NSMakePoint( self.target->get_x(), self.target->get_y() + playerSizeHalf + 24.0 ) withAttributes: @{ NSForegroundColorAttributeName: NSColor.redColor, NSFontAttributeName: [NSFont systemFontOfSize: 48 weight: 500] }];
			}
		}
		
		NSPoint playerPos = NSMakePoint( self.player->get_x(), self.player->get_y() );
		NSPoint startPos = [self pointAtAngleInRadians: self.player->get_angle() distance: playerSizeHalf fromPoint: playerPos];
		[NSColor.redColor set];
		if( self.didHit )
		{
			[NSBezierPath strokeLineFromPoint: startPos toPoint: NSMakePoint( self.target->get_x(), self.target->get_y() )];
		}
		else	// No hit? Shoot straight ahead and stop in emptiness:
		{
			CGFloat	attackRange = [self attackWithCurrentWeapon].get_max_distance();
			NSPoint startPos = [self pointAtAngleInRadians: self.player->get_angle() distance: playerSizeHalf fromPoint: playerPos];
			NSPoint targetPos = [self pointAtAngleInRadians: self.player->get_angle() distance: attackRange fromPoint: playerPos];
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
	self.player->set_x( hitPosition.x );
	self.player->set_y( hitPosition.y );
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
	self.player->set_x( hitPosition.x );
	self.player->set_y( hitPosition.y );
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
	self.player->turn_by_radians( (M_PI / 180.0) * 6.0 );
	[self refreshDisplay];
}

/**
 Handle alt + left arrow key by rotating target.
 */
-(void)	moveWordLeft: (id)sender
{
	self.target->turn_by_radians( (M_PI / 180.0) * 6.0 );
	[self refreshDisplay];
}

/**
 Handle right arrow key and shift + right arrow key by rotating player or target, respectively.
 */
-(void)	moveRight: (id)sender
{
	self.player->turn_by_radians( -(M_PI / 180.0) * 6.0 );
	[self refreshDisplay];
}

/**
 Handle shift + right arrow key by rotating target.
 */
-(void)	moveWordRight: (id)sender
{
	self.target->turn_by_radians( -(M_PI / 180.0) * 6.0 );
	[self refreshDisplay];
}

-(buff) attackWithCurrentWeapon
{
	return buff( 1, -10, -1.0, -(M_PI / 4), M_PI / 2, 100.0, 0.0, false );
}

-(void)	moveUp: (id)sender
{
	buff attack = [self attackWithCurrentWeapon];
	self.shooting = true;
	self.didHit = self.target->hit( &attack, self.player );
	[self refreshDisplay];
	[NSRunLoop.currentRunLoop cancelPerformSelector: @selector(removeShot:) target: self argument: nil];
	[self performSelector: @selector(removeShot:) withObject: nil afterDelay: 0.5];
}


-(void)	removeShot:(id)sender
{
	self.shooting = false;
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
	
	NSLog( @"playerTargetAngle (relative): %f", (self.player->radian_angle_to_actor( self.target ) * 180.0) / M_PI );
	NSLog( @"playerTargetDistance: %f", self.player->distance_to_actor( self.target ) );
	
	[self setNeedsDisplayInRect: self.bounds];
}

@end
