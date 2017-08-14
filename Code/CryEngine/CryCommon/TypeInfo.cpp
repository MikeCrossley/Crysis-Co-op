
//////////////////////////////////////////////////////////////////////
//
//	Crytek CryENGINE Source	code
//
//	File:Endian.cpp
//	Description: Implementation	of endian	conversion routines.
//
//	History:
//
//////////////////////////////////////////////////////////////////////

#include "CryTypeInfo.h"
#include "Cry_Math.h"

//#define TEST_TYPEINFO

STRUCT_INFO_EMPTY(SSerializeString)
#if defined(LINUX)

#undef CVTDIGITHEX
#undef CVTDIGITDEC
#define CVTDIGITHEX(VALUE, P, STRING) \
{ \
	if (VALUE) \
{ \
	unsigned int _digit = (VALUE % 16); \
	_digit += (_digit > 10) ? 'a' - 10 : '0'; \
	*P++ = (char)_digit; \
} \
	else \
{ \
	*P = 0; \
	return STRING; \
} \
	VALUE /= 16; \
}
#define CVTDIGITDEC(VALUE, P, STRING) \
{ \
	if (VALUE) \
	*P++ = '0' + (char)(VALUE % 10); \
	else \
{ \
	*P = 0; \
	return STRING; \
} \
	VALUE /= 10; \
}

char* _i64toa( int64 value, char *string, int32 radix )
{
	if( 10 == radix )
		sprintf( string, "%llu", (unsigned long long)value );
	else
		sprintf( string, "%llx", (unsigned long long)value );
	return( string );
}

char* ultoa( uint32 value, char *string, int32 radix )
{
	if( 10 == radix )
		sprintf( string, "%.d", value );
	else
		sprintf( string, "%.x", value );
	return( string );
}

#undef CVTDIGITDEC
#undef CVTDIGITHEX

#endif // LINUX

//////////////////////////////////////////////////////////////////////
// Case-insensitive comparison helpers.

class NoCase
{
public:
	inline NoCase(cstr str) : m_Str(str) {}
	inline bool operator == (cstr str) const		{ return strcmpi(m_Str, str) == 0; }
	inline bool operator != (cstr str) const		{ return strcmpi(m_Str, str) != 0; }
private:
	cstr	m_Str;
};

//////////////////////////////////////////////////////////////////////
// Basic TypeInfo implementations.

// Basic type infos.

TYPE_INFO_BASIC(bool)
TYPE_INFO_BASIC(char)
TYPE_INFO_BASIC(wchar_t)

TYPE_INFO_BASIC(signed char)
TYPE_INFO_BASIC(unsigned char)
TYPE_INFO_BASIC(short)
TYPE_INFO_BASIC(unsigned short)
TYPE_INFO_BASIC(int)
TYPE_INFO_BASIC(unsigned int)
TYPE_INFO_BASIC(long)
TYPE_INFO_BASIC(unsigned long)
TYPE_INFO_BASIC(int64)
TYPE_INFO_BASIC(uint64)

TYPE_INFO_BASIC(float)
TYPE_INFO_BASIC(double)

TYPE_INFO_BASIC(string)

TYPE_INFO_PLAIN(void*)

//////////////////////////////////////////////////////////////////////
// Basic type info implementations.

// String conversion functions needed by TypeInfo.

template<class T>
inline bool NoString(T const& val, int flags)
{
	return (flags & CTypeInfo::WRITE_SKIP_DEFAULT) && val == T(0);
}

// bool
string ToString(bool const& val, int flags)
{
	if (val)
		return "true";
	else if (flags & CTypeInfo::WRITE_SKIP_DEFAULT)
		return string();
	else
		return "false";
}

bool FromString(bool& val, const char *s)
{
	if (!strcmp(s,"0") || !strcmpi(s,"false"))
	{
		val = false;
		return true;
	}
	if (!strcmp(s,"1") || !strcmpi(s,"true"))
	{
		val = true;
		return true;
	}
	return false;
}

// int64
string ToString(int64 const& val, int flags)
{
	if (NoString(val, flags))
		return string();
	char buffer[64];
	_i64toa(val, buffer, 10);
	return buffer;
}
bool FromString(int64& val, const char* s)
{
#if defined(__GNUC__)
	long long val_ll = (long long)val;
	bool rv = sscanf(s, "%lld", &val_ll) == 1;
	val = (int64)val_ll;
	return rv;
#else
	return sscanf(s, "%I64d", &val) == 1;
#endif
}

// uint64
string ToString(uint64 const& val, int flags)
{
	if (NoString(val, flags))
		return string();
	char buffer[64];
	_ui64toa(val, buffer, 10);
	return buffer;
}

bool FromString(uint64& val, const char* s)
{
# if defined(__GNUC__)
	unsigned long long val_ull = (unsigned long long)val;
	bool rv = sscanf(s, "%llu", &val_ull) == 1;
	val = (uint64)val_ull;
	return rv;
# else
	return sscanf(s, "%I64u", &val) == 1;
# endif
}

// long
string ToString(long const& val, int flags)
{
	if (NoString(val, flags))
		return string();
	char buffer[64];
	ltoa(val, buffer, 10);
	return buffer;
}

// ulong
string ToString(unsigned long const& val, int flags)
{
	if (NoString(val, flags))
		return string();
	char buffer[64];
	ultoa(val, buffer, 10);
	return buffer;
}

// Other ints
template<class T>
bool IntFromString(T& val, const char* s)
{
	// Read long value, convert with possible truncation, check for range.
	long lval;
	if (sscanf(s, "%ld", &lval) != 1)
		return false;
	val = (T)lval;
	return val == lval;
}
template<class T>
bool UIntFromString(T& val, const char* s)
{
	// Read long value, convert with possible truncation, check for range.
	unsigned long lval;
	if (sscanf(s, "%lu", &lval) != 1)
		return false;
	val = (T)lval;
	return val == lval;
}

bool FromString(long& val, const char* s)							{ return IntFromString(val, s); }
bool FromString(unsigned long& val, const char* s)		{ return UIntFromString(val, s); }

string ToString(int const& val, int flags)						{ return ToString(long(val), flags); }
bool FromString(int& val, const char* s)							{ return IntFromString(val, s); }

string ToString(unsigned int const& val, int flags)		{ return ToString((unsigned long)(val), flags); }
bool FromString(unsigned int& val, const char* s)			{ return UIntFromString(val, s); }

string ToString(short const& val, int flags)					{ return ToString(long(val), flags); }
bool FromString(short& val, const char* s)						{	return IntFromString(val, s); }

string ToString(unsigned short const& val, int flags)	{ return ToString((unsigned long)(val), flags); }
bool FromString(unsigned short& val, const char* s)		{	return UIntFromString(val, s); }

string ToString(char const& val, int flags)						{ return ToString(long(val), flags); }
bool FromString(char& val, const char* s)							{	return IntFromString(val, s); }

string ToString(wchar_t const& val, int flags)				{ return ToString(long(val), flags); }
bool FromString(wchar_t& val, const char* s)					{	return IntFromString(val, s); }

string ToString(signed char const& val, int flags)		{ return ToString(long(val), flags); }
bool FromString(signed char& val, const char* s)			{	return IntFromString(val, s); }

string ToString(unsigned char const& val, int flags)	{ return ToString((unsigned long)(val), flags); }
bool FromString(unsigned char& val, const char* s)		{	return UIntFromString(val, s); }

// double
string ToString(double const& val, int flags)
{
	if (NoString(val, flags))
		return string();
	char buffer[64];
	sprintf(buffer, "%.16g", val);
	return buffer;
}
bool FromString(double& val, const char* s)
{
	return sscanf(s, "%lg", &val) == 1;
}

// float
string ToString(float const& val, int flags)
{
	if (NoString(val, flags))
		return string();
	char buffer[64];
	sprintf(buffer, "%.7g", val);
	return buffer;
}
bool FromString(float& val, const char* s)
{
	return sscanf(s, "%g", &val) == 1;
}

// string
string ToString(string const& val, int flags)
{
	return val;
}
bool FromString(string& val, const char* s)
{
	val = s;
	return true;
}

template <>
size_t TTypeInfo<string>::GetMemoryUsage(ICrySizer* pSizer, void const* data) const
{
// CRAIG: just a temp workaround to try and get things working
#ifndef LINUX
	pSizer->AddString(*(string*)data);
#endif
	return 0;
}

#if TEST_TYPEINFO

// Unit test
template<class T>
void TestType(T val)
{
	string s = ToString(val, 0);
	T val2;
	assert(FromString(val2, s));
	assert(val2 == val);
}

struct STypeInfoTest
{
	STypeInfoTest()
	{
		TestType(true);
		TestType(int8(-0x12));
		TestType(uint8(0x87));
		TestType(int16(-0x1234));
		TestType(uint16(0x8765));
		TestType(int32(-0x12345678));
		TestType(uint32(0x87654321));
		TestType(int64(-0x123456789ABCDEF0));
		TestType(uint64(0xFEDCBA9876543210));

		TestType(float(1234.5678));
		TestType(float(12345678));
		TestType(float(12345678e-20));
		TestType(float(12345678e20));

		TestType(double(987654321.0123456789));
		TestType(double(9876543210123456789.0));
		TestType(double(9876543210123456789e-40));
		TestType(double(9876543210123456789e40));
	}
};
static STypeInfoTest _Test;

#endif //TEST_TYPEINFO

//////////////////////////////////////////////////////////////////////
// CTypeInfo implementation

bool CTypeInfo::CVarInfo::GetAttr(cstr name, float& num, cstr& str) const
{
	for (int i = 0; i < (int)Attrs.size(); i++)
		if (NoCase(name) == Attrs[i].Name)
		{
			num = Attrs[i].fValue;
			str = Attrs[i].sValue;
			return true;
		}
	return false;
}

//////////////////////////////////////////////////////////////////////
// CStructInfo implementation

inline size_t Align(size_t num, size_t align)
{
	return (num + align-1) & ~(align-1);
}

template<class T> void binary_swap(T& a, T& b)
{
	char c[sizeof(T)];
	memcpy(&c, &a, sizeof(T));
	memcpy(&a, &b, sizeof(T));
	memcpy(&b, &c, sizeof(T));
}

CStructInfo::CStructInfo( cstr name, size_t size, size_t num_vars, CVarInfo* vars )
: CTypeInfo(name, size), Vars(num_vars, vars)
{
	// Process and validate offsets and sizes.
	if (Vars.size() > 0)
	{
		size = 0;
		int bitoffset = 0;

		for (int i = 0; i < (int)Vars.size(); i++)
		{
			CStructInfo::CVarInfo& var = Vars[i];
			if (var.bBitfield)
			{
				if (bitoffset > 0)
				{
					// Continuing bitfield.
					var.Offset = Vars[i-1].Offset;
					var.BitWordWidth = Vars[i-1].BitWordWidth;
					var.bUnionAlias = 1;

					if (bitoffset + var.ArrayDim > var.GetSize()*8)
					{
						// Overflows word, start on next one.
						bitoffset = 0;
						size += var.GetSize();
					}
				}

				if (bitoffset == 0)
				{
					var.Offset = size;
					var.bUnionAlias = 0;

					// Detect real word size of bitfield, from offset of next field.
					size_t next_offset = Size;
					for (int j = i+1; j < (int)Vars.size(); j++)
					{
						if (!Vars[j].bBitfield)
						{
							next_offset = Vars[j].Offset;
							break;
						}
					}
					assert(next_offset > size);
					size_t wordsize = min(next_offset - size, var.Type.Size);
					size = next_offset;
					switch (wordsize)
					{
						case 1: var.BitWordWidth = 0; break;
						case 2: var.BitWordWidth = 1; break;
						case 4: var.BitWordWidth = 2; break;
						case 8: var.BitWordWidth = 3; break;
						default: assert(0);
					}
				}

				assert(var.ArrayDim <= var.GetSize()*8);
				var.BitOffset = bitoffset;
				bitoffset += var.ArrayDim;
			}
			else
			{
				bitoffset = 0;
				if (var.Offset < size)
					var.bUnionAlias = 1;
				else
				{
					size_t var_size = var.GetSize();
					
					// Handle anomalous case of zero-size base class that compiler misreports as size 1.
					if (var.bBaseClass && !var.Type.HasSubVars() && var_size == 1)
						var_size = 0;
					size = var.Offset + var_size;
				}
			}
		}
		assert(size <= Size && Align(size, 8) >= Size);
	}
}

// Parse structs as comma-separated values.

/*									,				1,		,2		1,2

		Top											1			,2		1,2				; strip trail commas
		Child	Named							1			(,2)	(1,2)			; strip trail commas, paren if internal commas
					Nameless	,				1,		,2		1,2				; 
*/

static void StripCommas(string& str)
{
	int nLast = str.size();
	while (nLast > 0 && str[nLast-1] == ',')
		nLast--;
	str.resize(nLast);
}

static const int WRITE_SUB	= 8;

string CStructInfo::ToString(const void* data, int flags, const void* def_data) const
{
	string str;						// Return str.

	for (int i = 0; i < (int)Vars.size(); i++)
	{
		// Handling of empty values: Skip trailing empty values. 
		// If there are intermediate empty values, replace them with non-empty ones.
		const CVarInfo& var = Vars[i];
		if (i > 0)
			str += ",";

		if (!var.bBaseClass)
		{
			// Nested named struct.
			string substr = var.Type.ToString((char*)data + var.Offset, flags & ~WRITE_SUB, (def_data ? (char*)def_data + var.Offset : 0));
			if (substr.find(',') != string::npos)
			{
				// Encase nested composite types in parens.
				str += "(";
				str += substr;
				str += ")";
			}
			else
				str += substr;
		}
		else
		{
			// Nameless base struct. Treat children as inline.
			str += var.Type.ToString((char*)data + var.Offset, flags | WRITE_SUB, (def_data ? (char*)def_data + var.Offset : 0));
		}
	}

	if ((flags & (WRITE_SUB|WRITE_TRUNCATE_SUB)) == WRITE_TRUNCATE_SUB)
		StripCommas(str);
	return str;
}

// Retrieve and return one subelement from src, advancing the pointer.
// Use strTemp if necessary.
bool ParseElement(cstr& src, cstr& substr, int& len)
{
	while (*src == ' ')
		src++;
	if (!*src)
		return false;

	// Find end or comma.
	int nest = 0;
	cstr end;
	for (end = src; *end; end++)
	{
		if (*end == '(')
			nest++;
		else if (*end == ')')
			nest--;
		else if (*end == ',' && nest == 0)
			break;
	}

	// Advance src past element.
	substr = src;
	src = end;
	if (*src == ',')
		src++;

	if (*substr == '(' && end[-1] == ')')
	{
		// Remove parens.
		substr++;
		end--;
	}

	len = static_cast<int>(end-substr);
	return true;
}

bool CStructInfo::FromStringParse(void* data, cstr& str, int flags) const
{
	bool bSuccess = true;
	char tempbuf[256];
	string tempstr;

	for (int i = 0; *str && i < int(Vars.size()); i++)
	{
		const CTypeInfo::CVarInfo* pVar = &Vars[i];
		if (pVar->bBaseClass && pVar->Type.HasSubVars())
		{
			// Recurse sub-struct in same string group.
			CStructInfo const& typeSub = static_cast<CStructInfo const&>(pVar->Type);
			if (!typeSub.FromStringParse(pVar->GetAddress(data), str, flags))
				bSuccess = false;
		}
		else
		{
			// Parse 1 element from string.
			cstr substr;
			int len;
			if (!ParseElement(str, substr, len))
				break;
			if (substr[len])
			{
				// Need to make temp copy.
				if (len < sizeof(tempbuf))
				{
					memcpy(tempbuf, substr, len);
					tempbuf[len] = 0;
					substr = tempbuf;
				}
				else
				{
					tempstr.assign(substr, len);
					substr = tempstr;
				}
			}
			if (!pVar->FromString(data, substr, flags))
				bSuccess = false;
		}
	}
	return bSuccess;
}

bool CStructInfo::FromString(void* data, cstr str, int flags) const
{
	if (!Vars.size())
		return false;
	return FromStringParse(data, str, flags);
}

size_t CStructInfo::GetMemoryUsage(ICrySizer* pSizer, void const* data) const
{
	size_t nTotal = 0;
	for (int i = 0; i < (int)Vars.size(); i++)
		nTotal += Vars[i].Type.GetMemoryUsage(pSizer, (char*)data + Vars[i].Offset);
	return nTotal;
}

const CTypeInfo::CVarInfo* CStructInfo::FindSubVar(cstr name) const
{
	// To do: replace this with a map.
	for (int i = 0; i < (int)Vars.size(); i++)
		if (NoCase(Vars[i].GetDisplayName()) == name)
			return &Vars[i];
	return 0;
}

//////////////////////////////////////////////////////////////////////
// CEnumInfo implementation

CEnumInfo::CEnumInfo( cstr name, size_t size, size_t num_elems, CEnumElem* elems)
	: CTypeInfo(name, size), Elems(num_elems, elems),
		MinValue(0), MaxValue(0), bRegular(true)
{
	// Analyse names and values.
	if (num_elems)
	{
		int nPrefixLength = 0;
		MinValue = MaxValue = Elems[0].Value;
		nPrefixLength = strlen(Elems[0].FullName);
		for (int i = 0; i < (int)Elems.size(); i++)
		{
			if (Elems[i].Value != i)
				bRegular = false;
			MinValue = min(MinValue, Elems[i].Value);
			MaxValue = max(MaxValue, Elems[i].Value);

			// Find common prefix.
			int p = 0;
			while (p < nPrefixLength && Elems[i].FullName[p] == Elems[0].FullName[p])
				p++;
			nPrefixLength = p;
		}

		// Ensure prefix is on underscore boundary.
		while (nPrefixLength > 0 && Elems[0].FullName[nPrefixLength-1] != '_')
			nPrefixLength--;

		for (int i = 0; i < (int)Elems.size(); i++)
		{
			Elems[i].ShortName = Elems[i].FullName + nPrefixLength;
		}		
	}
}

string CEnumInfo::ToString(int val, int flags) const
{
	// Find matching element.
	if (NoString(val, flags))
		return string();
	if (bRegular)
	{
		if (val >= 0 && val < (int)Elems.size())
			return Elems[val].ShortName;
	}
	else
	{
		for (int i = 0; i < (int)Elems.size(); i++)
		{
			if (Elems[i].Value == val)
				return Elems[i].ShortName;
		}
	}

	// Unmatched value, return as number.
	return ::ToString(val, flags);
}

bool CEnumInfo::FromString(int& val, cstr str, int flags) const
{
	if (!*str)
	{
		if (flags & READ_SKIP_EMPTY)
			return false;
		val = 0;
		return true;
	}

	// Match either truncated or full names, case insensitive.
	NoCase istr(str);
	for (int i = 0; i < (int)Elems.size(); i++)
	{
		if (istr == Elems[i].ShortName || istr == Elems[i].FullName)
		{
			val = Elems[i].Value;
			return true;
		}
	}

	// No match, attempt numeric conversion.
	return ::FromString(val, str);
}

//////////////////////////////////////////////////////////////////////
// SwapEndian implementation.

static bool NeedBitfieldSwap()
{
	static struct
	{
		uint32	bit: 2;
	} 
	sBitTest = {1};
	uint32& nInt = *(uint32*)&sBitTest;
	assert(nInt == 1 || nInt == 0x40000000);
	return nInt != 1;
}

void SwapEndian(void* pData, size_t nCount, const CTypeInfo& info, size_t nSize)
{
	if (!info.HasSubVars())
	{
		assert(nSize <= info.Size);

		// Primitive type.
		switch (nSize)
		{
			case 1:
				break;
			case 2:
				{
					while (nCount--)
					{
						uint16& i = *((uint16*&)pData)++;
						i = ((i>>8) + (i<<8) & 0xFFFF);
					}
					break;
				}
			case 4:
				{
					while (nCount--)
					{
						uint32& i = *((uint32*&)pData)++;
						i = (i>>24) + ((i>>8)&0xFF00) + ((i&0xFF00)<<8) + (i<<24);
					}
					break;
				}
			case 8:
				{
					while (nCount--)
					{
						uint64& i = *((uint64*&)pData)++;
						i = (i>>56) + ((i>>40)&0xFF00) + ((i>>24)&0xFF0000) + ((i>>8)&0xFF000000)
							+ ((i&0xFF000000)<<8) + ((i&0xFF0000)<<24) + ((i&0xFF00)<<40) + (i<<56);
					}
					break;
				}
			default:
				assert(0);
		}
	}
	else
	{
		assert(nSize == info.Size);
		while (nCount--)
		{
			uint64 uOrigBits = 0, uNewBits = 0;
			for AllSubVars( pVar, info )
			{
				void* pVarAddr = pVar->GetAddress(pData);
				if (!pVar->bUnionAlias)
					SwapEndian(pVarAddr, pVar->GetDim(), pVar->Type, pVar->GetElemSize());
				if (pVar->bBitfield && NeedBitfieldSwap())
				{
					// Reverse location of all bitfields in word.
					int nWordBits = pVar->GetElemSize()*8;
					assert(nWordBits <= 64);
					if (pVar->BitOffset == 0)
					{
						// Initialise bitfield swapping.
						uOrigBits = ToInt<uint64>(pVar->GetSize(), pVarAddr);
						uNewBits = 0;
					}
					uint64 uVal = (uOrigBits >> pVar->BitOffset) & ((1<<pVar->GetBits())-1);
					uNewBits |= uVal << (nWordBits-pVar->BitOffset);
					FromInt(pVar->GetElemSize(), pVarAddr, uNewBits);
				}
			}
			pData = (char*)pData + info.Size;
		}
	}
}




