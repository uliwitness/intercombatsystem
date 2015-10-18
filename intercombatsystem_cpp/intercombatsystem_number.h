//
//  intercombatsystem_number.h
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
#endif


class intercombatsystem CP2SCLASS
{
public:
	intercombatsystem() CP2SINIT : ivar(1234)	{}
	
	void	method( int theNum ) CP2SMETHOD	{ printf("ivar = %d\n", ivar); }
	
protected:
	int	ivar;
};

