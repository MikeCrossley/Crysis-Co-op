//////////////////////////////////////////////////////////////////////
//
//	Crytek Serialization framework
//	
//	File: SerializeFwd.h
//  Description: forward declaration of TSerialize
//
//	History:
//	-12/05/2005: Kirill Bulatsev, Created
//
//////////////////////////////////////////////////////////////////////


template <class T> class CSerializeWrapper;
struct ISerialize;
typedef CSerializeWrapper<ISerialize> TSerialize;
