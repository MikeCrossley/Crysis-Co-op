//////////////////////////////////////////////////////////////////////
//
//	Crytek Common Source code
//
//	File:Cry_Math.h
//	Description: Common math class
//
//	History:
//	-Feb 27,2003: Created by Ivo Herzeg
//
//////////////////////////////////////////////////////////////////////

#ifndef CRYMATH_H
#define CRYMATH_H

#if _MSC_VER > 1000
# pragma once
#endif

//========================================================================================

#include <platform.h>
#include MATH_H
#include "Cry_ValidNumber.h"

#ifdef LINUX
#include <values.h>
#endif

///////////////////////////////////////////////////////////////////////////////
// Forward declarations                                                      //
///////////////////////////////////////////////////////////////////////////////
template <typename F> struct Vec2_tpl;
template <typename F> struct Vec3_tpl;
template <typename F> struct Vec4_tpl;

template <typename F> struct Ang3_tpl;
template <typename F> struct Plane_tpl;
template <typename F> struct Quat_tpl;
template <typename F> struct QuatT_tpl;
template <typename F> struct QuatTS_tpl;

template <typename F> struct Diag33_tpl;
template <typename F> struct Matrix33_tpl;
template <typename F> struct Matrix34_tpl;
template <typename F> struct Matrix44_tpl;

template <typename F> struct AngleAxis_tpl;





///////////////////////////////////////////////////////////////////////////////
// Definitions                                                               //
///////////////////////////////////////////////////////////////////////////////
const f32 gf_PI  =  3.14159265358979323846264338327950288419716939937510f; // pi
const f32 gf_PI2 =  3.14159265358979323846264338327950288419716939937510f*2; // 2*pi

const f64 g_PI  =  3.14159265358979323846264338327950288419716939937510; // pi
const f64 g_PI2 =  3.14159265358979323846264338327950288419716939937510*2; // 2*pi

const f64 sqrt2	= (f64)1.4142135623730950488016887242097;
const f64 sqrt3	= (f64)1.7320508075688772935274463415059;


#define MAX(a,b)    (((a) > (b)) ? (a) : (b))
#define MIN(a,b)    (((a) < (b)) ? (a) : (b))

#define	VEC_EPSILON	( 0.05f )
#define DEG2RAD( a ) ( (a) * (gf_PI/180.0f) )
#define RAD2DEG( a ) ( (a) * (180.0f/gf_PI) )

// 32/64 Bit versions.
#define SIGN_MASK(x) ((intptr_t)(x) >> ((sizeof(size_t)*8)-1))

//////////////////////////////////////////////////////////////////////////
// Define min/max
//////////////////////////////////////////////////////////////////////////
#ifdef min
#undef min
#endif //min

#ifdef max
#undef max
#endif //max


template<class T> inline void Limit(T& val, const T& min, const T& max)
{
	if (val < min) val = min;
	else if (val > max)	val = max;
}

template<class T> ILINE T clamp_tpl( T X, T Min, T Max ) 
{	
	return X<Min ? Min : X<Max ? X : Max; 
}


ILINE f32 clamp( f32 X, f32 Min, f32 Max ) 
{	
	X = (X+Max-fabsf(X-Max))*0.5f;  //return the min
	X = (X+Min+fabsf(X-Min))*0.5f;  //return the max 
	return X;
}
ILINE f64 clamp( f64 X, f64 Min, f64 Max ) 
{	
	X = (X+Max-fabs(X-Max))*0.5;  //return the min
	X = (X+Min+fabs(X-Min))*0.5;  //return the max 
	return X;
}


#ifdef __GNUC__
// GCC generates very bad (slow) code for the template versions of min() and
// max() below, so we'll provided overloads for all primitive types.
#define _MINMAXFUNC(TYPE) \
	ILINE TYPE min(TYPE a, TYPE b) { return a < b ? a : b; } \
	ILINE TYPE max(TYPE a, TYPE b) { return b < a ? a : b; }

_MINMAXFUNC(int)
_MINMAXFUNC(unsigned)
_MINMAXFUNC(float)
_MINMAXFUNC(double)
_MINMAXFUNC(uint64)

ILINE int min(int a, unsigned b) { return min(a, static_cast<int>(b)); }
ILINE int min(unsigned a, int b) { return min(static_cast<int>(a), b); }
ILINE unsigned max(int a, unsigned b) { return max(static_cast<unsigned>(a), b); }
ILINE unsigned max(unsigned a, int b) { return max(a, static_cast<unsigned>(b)); }
ILINE uint64 min(uint32 a, uint64 b) { return min(static_cast<uint64>(a), b); }
ILINE uint64 min(uint64 a, uint32 b) { return min(a, static_cast<uint64>(b)); }
ILINE uint64 max(uint32 a, uint64 b) { return max(static_cast<uint64>(a), b); }
ILINE uint64 max(uint64 a, uint32 b) { return max(a, static_cast<uint64>(b)); }

#undef _MINMAXFUNC
#endif//__GNUC__

// Bring min and max from std namespace to global scope.
template <class T>
inline const T& min( const T& a, const T& b )
{
	return b < a ? b : a;
}

template <class T>
inline const T& max( const T& a, const T& b )
{
	return  a < b ? b : a;
}

template <class T, class _Compare>
inline const T& min( const T& a, const T& b, _Compare comp)
{
	return comp(b,a) ? b : a;
}

template <class T, class _Compare>
inline const T& max( const T& a, const T& b, _Compare comp)
{
	return comp(a,b) ? b : a;
}

// Perform a safe division, with specified maximum quotient.
// Returns min( n/d, m )
template<class T>
inline T div_min( T n, T d, T m )
{
	// Multiply both sides additionally by d to reverse sense when negative.
	return n*d < m*d*d ? n/d : m;
}

ILINE float CorrectInvSqrt(float fNum, float fInvSqrtEst)
{
	// Newton-Rhapson method for improving estimated inv sqrt.
	/*
		f(x) = x^(-1/2)
		f(n) = f(a) + (n-a)f'(a)
				 = a^(-1/2) + (n-a)(-1/2)a^(-3/2)
				 = a^(-1/2)*3/2 - na^(-3/2)/2
				 = e*3/2 - ne^3/2
	*/
	return fInvSqrtEst * (1.5f - fNum * fInvSqrtEst * fInvSqrtEst * 0.5f);
}

//////////////////////////////////////////////////////////////////////////

//-------------------------------------------
//-- the portability functions for AMD64
//-------------------------------------------
#if defined(WIN64) &&  defined(_CPU_AMD64) && !defined(LINUX)
/*
extern "C" void fastsincosf(f32 x, f32 * sincosfx);
extern "C" f32 fastsinf(f32 x);
extern "C" f32 fastcosf(f32 x);

ILINE void cry_sincosf (f32 angle, f32* pCosSin) {	fastsincosf(angle,pCosSin);	}
ILINE void cry_sincos  (f64 angle, f64* pCosSin) {	pCosSin[0] = cos(angle);	pCosSin[1] = sin(angle); }
ILINE f32 cry_sinf(f32 x) {return fastsinf(x); }
ILINE f32 cry_cosf(f32 x) {return fastcosf(x); }

ILINE f32 cry_fmod(f32 x, f32 y) {return (f32)fmod((f64)x,(f64)y);}

ILINE f32 cry_asinf(f32 x) {return f32(   asin( clamp((f64)x,-1.0,+1.0) )    );}
ILINE f32 cry_acosf(f32 x) {return f32(   acos( clamp((f64)x,-1.0,+1.0) )    );}
ILINE f32 cry_atanf(f32 x) {return (f32)atan((f64)x);}
ILINE f32 cry_atan2f(f32 y, f32 x) {return (f32)atan2((f64)y,(f64)x);}

ILINE f32 cry_tanhf(f32 x) {	f64 expz = exp(f64(x)), exp_z = exp(-f64(x));	return (f32)((expz-exp_z)/(expz+exp_z)); }
ILINE f32 cry_tanf(f32 x) {return (f32)tan((f64)x);}

ILINE f32 cry_sqrtf(f32 x) {return (f32)sqrt((f64)x);}
ILINE f32 cry_isqrtf(f32 x) {return 1.f/cry_sqrtf(x);}
ILINE f32 cry_isqrtf_fast(f32 x) {return 1.f/cry_sqrtf(x);}
ILINE f32 cry_fabsf(f32 x) {return (f32)fabs((f64)x);}
ILINE f32 cry_expf(f32 x) {return (f32)exp((f64)x);}
ILINE f32 cry_logf(f32 x) {return (f32)log((f64)x);}
ILINE f32 cry_powf(f32 x, f32 y) {return (f32) pow((f64)x,(f64)y);}

ILINE f32 cry_ceilf(f32 x) {return (f32)ceil((f64)x);}
ILINE f32 cry_floorf(f32 x) {return (f32)floor((f64)x);}

ILINE f64 cry_sinh(f64 z) {return (exp (z) - exp (-z)) * 0.5;}
ILINE f64 cry_cosh(f64 z) {return (exp (z) + exp (-z)) * 0.5;}
*/
#endif



//-------------------------------------------
//-- the portability functions for CPU_X86
//-------------------------------------------
#if defined(_CPU_X86) && defined(_MSC_VER) && !defined(_DEBUG) && !defined(LINUX)


// calculates the cosine and sine of the given angle in radians 
ILINE void cry_sincosf (f32 angle, f32* pSin, f32* pCos) {
	__asm {
		FLD         DWORD PTR       angle
			FSINCOS
			MOV         eAX,pCos
			MOV         eDX,pSin
			FSTP        DWORD PTR [eAX]	//store cosine
			FSTP        DWORD PTR [eDX]	//store sine
	}
}

// calculates the cosine and sine of the given angle in radians 
ILINE void cry_sincos (f64 angle, f64* pSin, f64* pCos) {
	__asm {
		FLD         QWORD PTR       angle
			FSINCOS
			MOV         eAX,pCos
			MOV         eDX,pSin
			FSTP        QWORD PTR [eAX]	//store cosine
			FSTP        QWORD PTR [eDX]	//store sine
	}
}

#include <xmmintrin.h>

ILINE f32 cry_sqrtf(f32 x) 
{
	__m128 s = _mm_sqrt_ss(_mm_set_ss(x));
	float r; _mm_store_ss(&r, s); 
	return r;
}
ILINE f32 cry_sqrtf_fast(f32 x)
{
	__m128 s = _mm_rcp_ss(_mm_rsqrt_ss(_mm_set_ss(x)));
	float r; _mm_store_ss(&r, s); 
	return r;
}
ILINE f32 cry_isqrtf(f32 x) 
{
	__m128 s = _mm_rsqrt_ss(_mm_set_ss(x));
	float r; _mm_store_ss(&r, s);
	return CorrectInvSqrt(x, r);
}
ILINE f32 cry_isqrtf_fast(f32 x) 
{
	__m128 s = _mm_rsqrt_ss(_mm_set_ss(x));
	float r; _mm_store_ss(&r, s);
	return r;
}

#else // #if defined(_CPU_X86) && defined(_MSC_VER) && !defined(LINUX)

//-------------------------------------------
//-- Portable version.
//-------------------------------------------

ILINE void cry_sincosf (f32 angle, f32* pSin, f32* pCos) {	*pSin = f32(sin(angle));	*pCos = f32(cos(angle));	}
ILINE void cry_sincos  (f64 angle, f64* pSin, f64* pCos) {	*pSin = f64(sin(angle));  *pCos = f64(cos(angle));	}
ILINE f32 cry_sqrtf(f32 x) {return sqrtf(x);}
ILINE f32 cry_sqrtf_fast(f32 x) {return sqrtf(x);}
ILINE f32 cry_isqrtf(f32 x) {return 1.f/sqrtf(x);}
ILINE f32 cry_isqrtf_fast(f32 x) {return 1.f/sqrtf(x);}

#endif

ILINE f32 cry_sinf(f32 x) {return sinf(x);}
ILINE f32 cry_cosf(f32 x) {return cosf(x);}
ILINE f32 cry_fmod(f32 x, f32 y) {return (f32)fmodf(x,y);}
ILINE f32 cry_ceilf(f32 x) {return ceilf(x);}
ILINE f32 cry_asinf(f32 x) {return asinf( clamp(x,-1.0f,+1.0f) );}
ILINE f32 cry_acosf(f32 x) {return acosf( clamp(x,-1.0f,+1.0f) );}
ILINE f32 cry_atanf(f32 x) {return atanf(x);}
ILINE f32 cry_atan2f(f32 y, f32 x) {return atan2f(y,x);}
ILINE f32 cry_tanhf(f32 x) {return tanhf(x);}
ILINE f32 cry_fabsf(f32 x) {return fabsf(x);}
ILINE f32 cry_expf(f32 x) {return expf(x);}
ILINE f32 cry_logf(f32 x) {return logf(x);}
ILINE f32 cry_floorf(f32 x) {return floorf(x);}
ILINE f32 cry_tanf(f32 x) {return tanf(x);}
ILINE f32 cry_powf(f32 x, f32 y) {return powf(x,y);}


//-----------------------------------------------------------------------

ILINE void sincos_tpl(f64 angle, f64* pSin,f64* pCos) { cry_sincos(angle,pSin,pCos); }
ILINE void sincos_tpl(f32 angle, f32* pSin,f32* pCos) { cry_sincosf(angle,pSin,pCos); }

ILINE f64 cos_tpl(f64 op) { return cos(op); }
ILINE f32 cos_tpl(f32 op) { return cry_cosf(op); }

ILINE f64 sin_tpl(f64 op) { return sin(op); }
ILINE f32 sin_tpl(f32 op) { return cry_sinf(op); }

ILINE f64 acos_tpl(f64 op) { return acos( clamp(op,-1.0,+1.0) ); }
ILINE f32 acos_tpl(f32 op) { return cry_acosf(op); }

ILINE f64 asin_tpl(f64 op) { return asin( clamp(op,-1.0,+1.0) ); }
ILINE f32 asin_tpl(f32 op) { return cry_asinf(op); }

ILINE f64 atan_tpl(f64 op) { return atan(op); }
ILINE f32 atan_tpl(f32 op) { return cry_atanf(op); }

ILINE f64 atan2_tpl(f64 op1,f64 op2) { return atan2(op1,op2); }
ILINE f32 atan2_tpl(f32 op1,f32 op2) { return cry_atan2f(op1,op2); }

ILINE f64 exp_tpl(f64 op) { return exp(op); }
ILINE f32 exp_tpl(f32 op) { return cry_expf(op); }

ILINE f64 log_tpl(f64 op) { return log(op); }
ILINE f32 log_tpl(f32 op) { return cry_logf(op); }

ILINE f64 sqrt_tpl(f64 op) { return sqrt(op); }
ILINE f32 sqrt_tpl(f32 op) { return cry_sqrtf(op); }

// Only f32 version implemented, as it's approximate.
ILINE f32 sqrt_fast_tpl(f32 op) { return cry_sqrtf_fast(op); }

ILINE f64 isqrt_tpl(f64 op) { return 1.0/sqrt(op); }
ILINE f32 isqrt_tpl(f32 op) { return cry_isqrtf(op); }

ILINE f32 isqrt_fast_tpl(f32 op) { return cry_isqrtf_fast(op); }

ILINE f64 isqrt_safe_tpl(f64 op) { return 1.0/sqrt(op + DBL_MIN); }
ILINE f32 isqrt_safe_tpl(f32 op) { return cry_isqrtf(op + FLT_MIN); }

ILINE f64 fabs_tpl(f64 op) { return fabs(op); }
ILINE f32 fabs_tpl(f32 op) { return cry_fabsf(op); }
ILINE int32 fabs_tpl(int32 op) { int32 mask=op>>31; return op+mask^mask; }

ILINE int32 floor_tpl(int32 op) {return op;}
ILINE f32 floor_tpl(f32 op) {return cry_floorf(op);}
ILINE f64 floor_tpl(f64 op) {return floor(op);}

ILINE int32 ceil_tpl(int32 op) {return op;}
ILINE f32 ceil_tpl(f32 op) {return cry_ceilf(op);}
ILINE f64 ceil_tpl(f64 op) {return ceil(op);}

ILINE f32 tan_tpl(f32 op) {return cry_tanf(op);}
ILINE f64 tan_tpl(f64 op) {return tan(op);}

// Fast float-int rounding functions.
#if defined(WIN32) && defined(_CPU_X86)
  ILINE int32 int_round(f32 f)
  {
    int32 i;
    __asm fld [f]
    __asm fistp [i]
    return i;
  }
	ILINE int32 pos_round(f32 f)  { return int_round(f); }
#else
	ILINE int32 int_round(f32 f)  { return f < 0.f ? int32(f-0.5f) : int32(f+0.5f); }
	ILINE int32 pos_round(f32 f)  { return int32(f+0.5f); }
#endif

ILINE int64 int_round(f64 f)  { return f < 0.0 ? int64(f-0.5) : int64(f+0.5); }
ILINE int64 pos_round(f64 f)  { return int64(f+0.5); }

// Faster than using std ceil().
ILINE int32 int_ceil(f32 f)
{
	int32 i = int32(f);
	return (f > f32(i)) ? i+1 : i;
}
ILINE int64 int_ceil(f64 f)
{
	int64 i = int64(f);
	return (f > f64(i)) ? i+1 : i;
}

// Fixed-int to float conversion.
ILINE float ufrac8_to_float( float u )
{
	return u * (1.f/255.f);
}
ILINE float ifrac8_to_float( float i )
{
	return i * (1.f/127.f);
}
ILINE uint8 float_to_ufrac8( float f )
{
	int i = pos_round(f * 255.f);
	assert(i >= 0 && i < 256);
	return uint8(i);
}
ILINE int8 float_to_ifrac8( float f )
{
	int i = int_round(f * 127.f);
	assert(abs(i) <= 127);
	return int8(i);
}


static int32 inc_mod3[]={1,2,0}, dec_mod3[]={2,0,1};
#ifdef PHYSICS_EXPORTS
#define incm3(i) inc_mod3[i]
#define decm3(i) dec_mod3[i]
#else
inline int32 incm3(int32 i) { return i+1 & (i-2)>>31; }
inline int32 decm3(int32 i) { return i-1 + ((i-1)>>31&3); }
#endif


template<class F> inline F square(F fOp) { return(fOp*fOp); }

//this can easily be confused with square-root?
template<class F> inline F sqr(const F &op) { return op*op; }

template<class F> inline F cube(const F &op) { return op*op*op; }
template<class F> inline F sqr_signed(const F &op) { return op*fabs_tpl(op); }


inline int32 sgnnz(f64 x) {
	union { f32 f; int32 i; } u;
	u.f=(f32)x; return ((u.i>>31)<<1)+1;
}
inline int32 sgnnz(f32 x) {
	union { f32 f; int32 i; } u;
	u.f=x; return ((u.i>>31)<<1)+1;
}
inline int32 sgnnz(int32 x) {
	return ((x>>31)<<1)+1;
}


inline int32 sgn(f64 x) {
	union { f32 f; int32 i; } u;
	u.f=(f32)x; return (u.i>>31)+((u.i-1)>>31)+1;
}
inline int32 sgn(f32 x) {
	union { f32 f; int32 i; } u;
	u.f=x; return (u.i>>31)+((u.i-1)>>31)+1;
}
inline int32 sgn(int32 x) {
	return (x>>31)+((x-1)>>31)+1;
}


inline int32 isneg(f64 x) {
	union { f32 f; uint32 i; } u;
	u.f=(f32)x; return (int32)(u.i>>31);
}
inline int32 isneg(f32 x) {
	union { f32 f; uint32 i; } u;
	u.f=x; return (int32)(u.i>>31);
}
inline int32 isneg(int32 x) {
	return (int32)((uint32)x>>31);
}



inline int32 isnonneg(f64 x) {
	union { f32 f; uint32 i; } u;
	u.f=(f32)x; return (int32)(u.i>>31^1);
}
inline int32 isnonneg(f32 x) {
	union { f32 f; uint32 i; } u;
	u.f=x; return (int32)(u.i>>31^1);
}
inline int32 isnonneg(int32 x) {
	return (int32)((uint32)x>>31^1);
}



inline int32 iszero(f64 x) {
	union { f32 f; int32 i; } u;
	u.f=(f32)x;
	u.i&=0x7FFFFFFF;
	return -((u.i>>31)^(u.i-1)>>31);
}
inline int32 iszero(f32 x) {
	union { f32 f; int32 i; } u;
	u.f=x; u.i&=0x7FFFFFFF; return -(u.i>>31^(u.i-1)>>31);
}
inline int32 iszero(int32 x) {
	return -(x>>31^(x-1)>>31);
}
inline int32 iszero(long x) {
	return -(x>>31^(x-1)>>31);
}

#if defined(WIN64) || defined(LINUX64)
// AMD64 port: TODO: optimize
inline int64 iszero(__int64 x) 
{
	return -(x>>63^(x-1)>>63);
}
#endif
#if defined(LINUX64)
inline int64 iszero(intptr_t x) 
{
	return (sizeof(x) == 8)?iszero((__int64)x) : iszero((int32)x);
}
#endif



template<class F> int32 inrange(F x, F end1, F end2) {
	return isneg(fabs_tpl(end1+end2-x*(F)2) - fabs_tpl(end1-end2));
}

template<class F> F cond_select(int32 bFirst, F op1,F op2) {
	F arg[2] = { op1,op2 };
	return arg[bFirst^1];
}

template<class F> int32 idxmax3(const F *pdata) {
	int32 imax = isneg(pdata[0]-pdata[1]);
	imax |= isneg(pdata[imax]-pdata[2])<<1;
	return imax & (2|(imax>>1^1));
}
template<class F> int32 idxmin3(const F *pdata) {
	int32 imin = isneg(pdata[1]-pdata[0]);
	imin |= isneg(pdata[2]-pdata[imin])<<1;
	return imin & (2|(imin>>1^1));
}


inline int32 getexp(f32 x) { return (int32)(*(uint32*)&x>>23&0x0FF)-127; }
inline int32 getexp(f64 x) { return (int32)(*((uint32*)&x+1)>>20&0x7FF)-1023; }

inline f32 &setexp(f32 &x,int32 iexp) { (*(uint32*)&x &= ~(0x0FF<<23)) |= (iexp+127)<<23; return x; }
inline f64 &setexp(f64 &x,int32 iexp) { (*((uint32*)&x+1) &= ~(0x7FF<<20)) |= (iexp+1023)<<20; return x; }


template<class dtype> class strided_pointer {
public:
	strided_pointer() { data=0; iStride=sizeof(dtype); }
	strided_pointer(dtype *pdata,int32 stride=sizeof(dtype)) { data=pdata; iStride=stride; }
	strided_pointer(const strided_pointer &src) { data=src.data; iStride=src.iStride; }
	template<class dtype1> strided_pointer(const strided_pointer<dtype1> &src) { data=src.data; iStride=src.iStride; }

	strided_pointer& operator=(dtype *pdata) { data=pdata; return *this; }
	strided_pointer& operator=(const strided_pointer<dtype> &src) { data=src.data; iStride=src.iStride; return *this; }
	template<class dtype1> strided_pointer& operator=(const strided_pointer<dtype1> &src) { data=src.data; iStride=src.iStride; return *this; }

	dtype& operator[](int32 idx) { return *(dtype*)((char*)data+idx*iStride); }
	const dtype& operator[](int32 idx) const { return *(const dtype*)((const char*)data+idx*iStride); }
	strided_pointer<dtype> operator+(int32 idx) const { return strided_pointer<dtype>((dtype*)((char*)data+idx*iStride),iStride); }
	strided_pointer<dtype> operator-(int32 idx) const { return strided_pointer<dtype>((dtype*)((char*)data-idx*iStride),iStride); }
	dtype& operator*() const { return *data; }
	operator void*() const { return (void*)data; }

	dtype *data;
	int32 iStride;
};


typedef struct VALUE16 {
	union {
		struct { unsigned char a,b; } c;
		unsigned short ab;
	};
} VALUE16;

inline unsigned short SWAP16(unsigned short l) {
	VALUE16 l16;
	unsigned char a,b;
	l16.ab=l;
 	a=l16.c.a;  b=l16.c.b;
 	l16.c.a=b; 	l16.c.b=a;
	return l16.ab;
}

//--------------------------------------------

typedef struct VALUE32 {
	union {
		struct { unsigned char a,b,c,d; } c;
		f32 FLOAT;
		unsigned long abcd;
		const void* ptr;
	};
} VALUE32;

inline unsigned long SWAP32(unsigned long l) {
	VALUE32 l32;
	unsigned char a,b,c,d;
	l32.abcd=l;
 	a=l32.c.a;  b=l32.c.b;  c=l32.c.c;  d=l32.c.d;
 	l32.c.a=d;	l32.c.b=c; 	l32.c.c=b; 	l32.c.d=a;
	return l32.abcd;
}

inline const void* SWAP32(const void* l) {
	VALUE32 l32;
	unsigned char a,b,c,d;
	l32.ptr=l;
 	a=l32.c.a;  b=l32.c.b;  c=l32.c.c;  d=l32.c.d;
 	l32.c.a=d;	l32.c.b=c; 	l32.c.c=b; 	l32.c.d=a;
	return l32.ptr;
}


inline f32 FSWAP32(f32 f) {
	VALUE32 l32;
	unsigned char a,b,c,d;
	l32.FLOAT=f;
	a=l32.c.a;  b=l32.c.b;  c=l32.c.c;  d=l32.c.d;
	l32.c.a=d;	l32.c.b=c; 	l32.c.c=b; 	l32.c.d=a;
	return l32.FLOAT;
}

//////////////////////////////////////////////////////////////////////////
//
// Random functions.
//
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// Random number generator.
#include "MTPseudoRandom.h"
// Random function to be used instead of rand()
extern unsigned int cry_rand();
// Generates random integer in full 32-bit range.
extern unsigned int cry_rand32();
// Generates random floating number in the closed interval [0,1].
extern float cry_frand();
//////////////////////////////////////////////////////////////////////////

// Random float between 0 and 1 inclusive.
inline float Random()
{
	return cry_frand();
}

// Random floats.
inline float Random(float fRange)
{
	return cry_frand() * fRange;
}
inline float Random(float fStart, float fEnd)
{
	return cry_frand() * (fEnd-fStart) + fStart;
}

// Random int from 0..nRange-1.
inline uint32 Random(uint32 nRange)
{
	return uint32((uint64(cry_rand32()) * nRange) >> 32);
}

// Proper overload resolution for ints.
inline uint32 Random(int32 nRange)
{
	assert(nRange >= 0);
	return Random(uint32(nRange));
}

template<class T>
inline T BiRandom(T fRange)
{
	return Random(-fRange, fRange);
}

//////////////////////////////////////////////////////////////////////////
enum type_zero { ZERO };
enum type_min { VMIN };
enum type_max { VMAX };
enum type_identity { IDENTITY };

#include "Cry_Vector2.h"
#include "Cry_Vector3.h"
#include "Cry_Matrix.h"
#include "Cry_Quat.h"




#if (defined(WIN32) || defined (_XBOX))
#include "Cry_XOptimise.h"
#endif

inline f32 sqr(Vec3 op) { return op|op; }
inline f64 sqr(Vec3r op) { return op|op; }

//////////////////////////////////////////////////////////////////////////

/// This function relaxes a value (val) towards a desired value (to) whilst maintaining continuity
/// of val and its rate of change (valRate). timeDelta is the time between this call and the previous one.
/// The caller would normally keep val and valRate as working variables, and smoothTime is normally 
/// a fixed parameter. The to/timeDelta values can change.
template <typename T> inline void SmoothCD(T &val,                ///< in/out: value to be smoothed
																					 T &valRate,            ///< in/out: rate of change of the value
																					 const float timeDelta, ///< in: time interval
																					 const T &to,           ///< in: the target value
																					 const float smoothTime)///< in: timescale for smoothing
{
	if (smoothTime > 0.0f)
	{
		float omega = 2.0f / smoothTime;
		float x = omega * timeDelta;
		float exp = 1.0f / (1.0f + x + 0.48f * x * x + 0.235f * x * x * x);
		T change = (val - to);
		T temp = (valRate + change*omega) * timeDelta;
		valRate = (valRate - temp*omega) * exp;
		val = to + (change + temp) * exp;
	}
	else if (timeDelta > 0.0f)
	{
		valRate = (to - val) / timeDelta;
		val = to;
	}
	else
	{
		val = to;
		valRate -= valRate; // zero it...
	}
}



#endif //math
