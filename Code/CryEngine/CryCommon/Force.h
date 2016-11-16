////////////////////////////////////////////////////////////////////////////
//
//  Crytek Engine Source File.
//  Copyright (C), Crytek Studios, 2006
// -------------------------------------------------------------------------
//  File name:   Force.h
//  Version:     v1.00
//  Created:     2006.1.10 by Scott
//  Compilers:   Visual Studio.NET
//  Description: 
// -------------------------------------------------------------------------
//  History:
//
////////////////////////////////////////////////////////////////////////////

#ifndef __force_h__
#define __force_h__
#pragma once

/*
			F = force magnitude & dir
			C = force center
			s = object affinity
			P,P',P" = object position, velocity, accel

		Force types:

			Constant (gravity): Force on object
				P" = F s
				P' = P0' + F t
				P  = P0 + P0' t + F/2 t^2
				Directions: constant, point (f = 1/r^2 - 1/R^2), line (f = 1/r - 1/R)

			Flow (wind): Attracts velocity asymtotically to flow
				P" = (F-P') s
				P' = (P0'-F) e^(-s t) + F
				P  = P0 + (P0'-F)/s (1 - e^(-s t)) + F t
				Directions: constant, point, line, plane, vortex line ??

			Barrier: Halts approaching objects asymtotically
				In force space (C = 0),
				P" = (-P' * (P-C)) (P-C) / |P-C|^3
				P = P0 + P0'/s (1 - e^(-s t)),  s = P0'/(C-P0)
				P = P0 + (C-P0) (1 - e^(-P0'/(C-P0) t))
				Directions: plane, line, point (acts on parallel component)

			Hard attractor: Applies a variable force, forcing object to reach target
				Speed-preserving: applies perpendicular forces to simply turn objects w/o magnitude acceleration
					Force is sufficient to let object reach target when it would have passed it at closest point
				Time limit:

					P = P0 + P0' T + P"/2 T^2 = 0
					P" = (-P0 - P0' T) 2/T^2
				
*/

struct ForceObject
{
	enum EForceType
	{
		eF_Attract,							// x'' = F c
		eF_Target,							// x'' = 2 x'^2 (x-C).p / (x-C).t^2
		eF_Flow,								// x'' = (F-x') c
		eF_Barrier,							// x'' = -(x'*F) / (x*F)
	};
	EForceType eType;
	enum EForceAffinity
	{
		eA_All,
		eA_Mass,
		eA_Drag,
	};
	EForceAffinity eAffinity;
	enum EGeometry
	{
		eG_Point,
		eG_Line,
		eG_Plane,
		eG_Volume,
	};
	EGeometry eGeometry;
	float		fInnerRadius;		// Fractional radius of max strength;

	float		fStrength;			// Const,Flow only
	QuatTS	qLocation;			// Pos = trans, Dir = Y axis, Radius = scale

	AUTO_STRUCT_INFO
};


#endif

