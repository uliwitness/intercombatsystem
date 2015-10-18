//
//  intercombatsystem.hpp
//  intercombatsystem
//
//  Created by Uli Kusterer on 18/10/15.
//  Copyright © 2015 Uli Kusterer. All rights reserved.
//

#pragma once

#include <stdio.h>


#ifndef CP2SINIT
#define CP2SINIT
#define CP2SMETHOD
#define CP2SCLASS
#define CP2SGETTER
#define CP2SSETTER
#endif


class intercombatactor CP2SCLASS
{
public:
	intercombatactor() CP2SINIT;
	
	void	turn_by_radians( double radians ) CP2SMETHOD;
	double	radian_angle_to_actor( intercombatactor* target ) CP2SMETHOD;
	double	distance_to_actor( intercombatactor* target ) CP2SMETHOD;
	
	double	get_angle() CP2SGETTER	{ return angle; }

	double	get_x() CP2SGETTER					{ return x; }
	void	set_x( double inX ) CP2SSETTER		{ x = inX; }

	double	get_y() CP2SGETTER					{ return y; }
	void	set_y( double inY ) CP2SSETTER		{ y = inY; }

protected:
	double		angle;
	double		x;
	double		y;
};

