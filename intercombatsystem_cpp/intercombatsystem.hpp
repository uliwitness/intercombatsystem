//
//  intercombatsystem.hpp
//  intercombatsystem
//
//  Created by Uli Kusterer on 18/10/15.
//  Copyright © 2015 Uli Kusterer. All rights reserved.
//

#pragma once

#include <stdio.h>
#include <vector>


#ifndef CP2SINIT
#define CP2SINIT
#define CP2SMETHOD
#define CP2SCLASS
#define CP2SGETTER
#define CP2SSETTER
#endif


class buff CP2SCLASS
{
public:
	buff( int type, double amount, double max_amount, double start_angle, double relative_angle, double max_distance, double bleedthrough, bool permanent ) CP2SINIT : mType(type), mAmount(amount), mMax_amount(max_amount), mStart_angle(start_angle), mRelative_angle(relative_angle), mMax_distance(max_distance), mBleedthrough(bleedthrough), mPermanent(permanent) {}
	
	int		get_type() CP2SGETTER						{ return mType; }
	void	set_type( int inType ) CP2SSETTER			{ mType = inType; }
	double	get_bleedthrough() CP2SGETTER				{ return mBleedthrough; }
	void	set_bleedthrough( double n ) CP2SSETTER		{ mBleedthrough = n; }
	double	get_amount() CP2SGETTER						{ return mAmount; }
	void	set_amount( double n ) CP2SSETTER			{ mAmount = n; }
	double	get_max_amount() CP2SGETTER					{ return mMax_amount; }
	void	set_max_amount( double n ) CP2SSETTER		{ mMax_amount = n; }
	double	get_start_angle() CP2SGETTER				{ return mStart_angle; }
	void	set_start_angle( double n ) CP2SSETTER		{ mStart_angle = n; }
	double	get_relative_angle() CP2SGETTER				{ return mRelative_angle; }
	void	set_relative_angle( double n ) CP2SSETTER	{ mRelative_angle = n; }
	double	get_max_distance() CP2SGETTER				{ return mMax_distance; }
	void	set_max_distance( double n ) CP2SSETTER		{ mMax_distance = n; }
	bool	get_permanent() CP2SGETTER					{ return mPermanent; }
	void	set_permanent( bool n ) CP2SSETTER			{ mPermanent = n; }

protected:
	int			mType;
	double		mBleedthrough;	// 0.0 ... 1.0, should be 0.0 for attacks.
	double		mAmount;		// Amount of damage/health of this stat.
	double		mMax_amount;	// Maximum amount of health this stat can have before we ignore buffs. Negative means unlimited Only used for values.
	double		mStart_angle;	// Angle in radians where active area starts. (For attacks or directional shields)
	double		mRelative_angle;// Radians relative to this start angle where active area ends. (E.g. for attacks or directional shields)
	double		mMax_distance;	// Max. distance at which this has effect. negative means unlimited (E.g. for shields)
	bool		mPermanent;		// A permanent buff/debuff maintains its value. A non-permanent buff/debuff can be used up.
};




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

	double	get_health() CP2SGETTER				{ return health; }
	void	set_health( double n ) CP2SSETTER	{ health = n; }
	
	void	add_buff( buff * inBuff ) CP2SMETHOD		{ buffs.push_back( *inBuff ); }
	void	add_value( buff * inValue ) CP2SMETHOD		{ values.push_back( *inValue ); }
	
	void	hit( buff* inAttack, double currDistance, double currAngle ) CP2SMETHOD;
	
protected:
	double				health;
	double				angle;
	double				x;
	double				y;
	std::vector<buff>	buffs;
	std::vector<buff>	values;
};

