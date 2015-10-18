//
//  intercombatsystem.cpp
//  intercombatsystem
//
//  Created by Uli Kusterer on 18/10/15.
//  Copyright © 2015 Uli Kusterer. All rights reserved.
//

#include "intercombatsystem.hpp"
#include <math.h>


intercombatactor::intercombatactor()
 : angle(0.0), x(0.0), y(0.0)
{
	
}


void	intercombatactor::turn_by_radians( double radians )
{
	angle += radians;
	if( angle >= (M_PI * 2.0) )
	{
		angle = angle - (M_PI * 2.0);
	}
	if( angle < 0.0 )
	{
		angle = angle + (M_PI * 2.0);
	}
}


double	intercombatactor::radian_angle_to_actor( intercombatactor* target )
{
	double	playerTargetAngle = atan2( 0.0, 0.0 );
	if( (x > target->x) )
	{
		playerTargetAngle = atan2( x - target->x, target->y - y );
	}
	else if( (x < target->x) )
	{
		playerTargetAngle = (M_PI * 2.0) - atan2( target->x - x, target->y - y );
	}
	
	double	playerTargetAngleRelative = (playerTargetAngle - angle);
	if( -playerTargetAngleRelative > M_PI )
	{
		playerTargetAngleRelative = (M_PI * 2) + playerTargetAngleRelative;
	}
	if( playerTargetAngleRelative > M_PI )
	{
		playerTargetAngleRelative = -((M_PI * 2) - playerTargetAngleRelative);
	}
	
	return playerTargetAngleRelative;
}


double	intercombatactor::distance_to_actor( intercombatactor* target )
{
	double distance = 0.0;
	double xdiff = x - target->x;
	double ydiff = y - target->y;
	distance = sqrt( (xdiff * xdiff) + (ydiff * ydiff) );
	
	return distance;
}


// list of attack/buffs/debuffs/current values
//	each energy type separate entry (+/- for buff/debuff)
//	if energy type's resistance is 0, apply damage to health
//
//	resistance can have a bleedthrough percentage that passes even if we're at 100%


void	intercombatactor::hit( buff* inAttack, double currDistance, double currAngle )
{
	if( inAttack->get_max_distance() >= 0.0 && inAttack->get_max_distance() < currDistance )
		return;	// Out of range, no damage.
	
	double	leftoverDamage = inAttack->get_amount();
	
	for( buff& currBuff : buffs )
	{
		if( inAttack->get_type() == currBuff.get_type() )
		{
			if( currBuff.get_max_distance() < 0.0 || currBuff.get_max_distance() <= currDistance )
			{
				double	nonBleedthrough = currBuff.get_amount() * (1.0 -currBuff.get_bleedthrough());
				if( leftoverDamage <= 0 && nonBleedthrough > -leftoverDamage )
				{
					nonBleedthrough = -leftoverDamage;	// At most subtract as much as we have, don't have strikes add to our health.
				}
				leftoverDamage += nonBleedthrough;
				currBuff.set_amount( currBuff.get_amount() -nonBleedthrough );
			}
		}
	}
	
	health += leftoverDamage;
	
	printf("health = %f\n", health );
	for( buff& currBuff : buffs )
	{
		printf("\t[BUFF]  type = %d amount = %f\n", currBuff.get_type(), currBuff.get_amount() );
	}
}

