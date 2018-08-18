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
#include <functional>


typedef uint64_t timestamp; // Just an increasing turn counter.
typedef uint64_t timestamp_difference; // difference between two timestamps.


class intercombatactor;


class buff
{
public:
	buff( int type, double amount, double max_amount, double start_angle, double relative_angle, double max_distance, double bleedthrough, double replenishPerTurnInCombat, double replenishPerTurnOutOfCombat, timestamp timeToConsiderLull, double replenishPerTurnInLull, bool permanent ) : mType(type), mAmount(amount), mMax_amount(max_amount), mStart_angle(start_angle), mRelative_angle(relative_angle), mMax_distance(max_distance), mBleedthrough(bleedthrough), mPermanent(permanent), mReplenishPerTurnInCombat(replenishPerTurnInCombat), mReplenishPerTurnOutOfCombat(replenishPerTurnOutOfCombat), mTimeToConsiderLull(timeToConsiderLull), mReplenishPerTurnInLull(replenishPerTurnInLull) {}
	
	int		get_type()						{ return mType; }
	void	set_type( int inType )			{ mType = inType; }
	double	get_bleedthrough()				{ return mBleedthrough; }
	void	set_bleedthrough( double n )	{ mBleedthrough = n; }
	double	get_amount()					{ return mAmount; }
	void	set_amount( double n )			{ mAmount = n; }
	double	get_max_amount()				{ return mMax_amount; }
	void	set_max_amount( double n )		{ mMax_amount = n; }
	double	get_start_angle()				{ return mStart_angle; }
	void	set_start_angle( double n )		{ mStart_angle = n; }
	double	get_relative_angle()			{ return mRelative_angle; }
	void	set_relative_angle( double n )	{ mRelative_angle = n; }
	double	get_max_distance()				{ return mMax_distance; }
	void	set_max_distance( double n )	{ mMax_distance = n; }
	bool	get_permanent()					{ return mPermanent; }
	void	set_permanent( bool n )			{ mPermanent = n; }
	void		set_last_time_damage_taken( timestamp n )	{ mLastTimeDamageTaken = n; }
	timestamp	get_last_time_damage_taken()				{ return mLastTimeDamageTaken; }

	void	replenish(bool isInCombat, timestamp currentTime, intercombatactor& owner);

protected:
	int						mType;
	double					mBleedthrough;	// 0.0 ... 1.0, should be 0.0 for attacks.
	double					mAmount;		// Amount of damage/health of this stat.
	double					mMax_amount;	// Maximum amount of health this stat can have before we ignore buffs. Negative means unlimited Only used for values.
	double					mStart_angle;	// Angle in radians where active area starts. (For attacks or directional shields)
	double					mRelative_angle;// Radians relative to this start angle where active area ends. (E.g. for attacks or directional shields)
	double					mMax_distance;	// Max. distance at which this has effect. negative means unlimited (E.g. for shields)
	double					mReplenishPerTurnInCombat;
	double					mReplenishPerTurnOutOfCombat;
	double					mReplenishPerTurnInLull;		// lull == not taken damage since mTimeToConsiderLull.
	timestamp_difference	mTimeToConsiderLull;
	timestamp				mLastTimeDamageTaken = 0;
	timestamp				mLastTimeReplenished = 0;
	bool					mPermanent;		// A permanent buff/debuff maintains its value. A non-permanent buff/debuff can be used up.
};




class intercombatactor
{
public:
	intercombatactor();
	
	void	turn_by_radians( double radians );
	double	radian_angle_to_actor( intercombatactor &target );
	double	distance_to_actor( intercombatactor &target );
	
	double	get_angle()	{ return angle; }

	double	get_x()					{ return x; }
	void	set_x( double inX )		{ x = inX; }

	double	get_y()					{ return y; }
	void	set_y( double inY )		{ y = inY; }

	double	get_health()			{ return health; }
	void	set_health( double n )	{ health = n; }
	
	double	get_value( int buffType );
	
	void	add_buff( buff& inBuff )		{ buffs.push_back( inBuff ); }
	
	bool	hit( buff &inAttack, timestamp currentTime, intercombatactor &attacker );
	
	void	replenish_buffs(bool isInCombat, timestamp currentTime);
	void	buff_changed(buff& inBuff)		{ if (mBuffChangedHandler) { mBuffChangedHandler( *this, inBuff ); } }

	void	set_buff_changed_handler(std::function<void(intercombatactor&,buff&)> inBuffChangedHandler) { mBuffChangedHandler = inBuffChangedHandler; };
	void	set_health_changed_handler(std::function<void(intercombatactor&)> inHealthChangedHandler) { mHealthChangedHandler = inHealthChangedHandler; };

protected:
	double				health;
	double				angle;
	double				x;
	double				y;
	std::vector<buff>	buffs;
	std::function<void(intercombatactor&,buff&)>	mBuffChangedHandler;
	std::function<void(intercombatactor&)> 			mHealthChangedHandler;
};

