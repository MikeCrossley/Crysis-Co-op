#pragma once

#ifndef IMAGEEXTENSIONHELPER_H
#define IMAGEEXTENSIONHELPER_H



// Crytek specific image extensions
//
// usually added to the end of DDS files

class CImageExtensionHelper
{
public:
	struct DDS_PIXELFORMAT
	{
		DWORD dwSize;
		DWORD dwFlags;
		DWORD dwFourCC;
		DWORD dwRGBBitCount;
		DWORD dwRBitMask;
		DWORD dwGBitMask;
		DWORD dwBBitMask;
		DWORD dwABitMask;
	};

	struct DDS_HEADER
	{
		DWORD dwSize;
		DWORD dwHeaderFlags;
		DWORD dwHeight;
		DWORD dwWidth;
		DWORD dwPitchOrLinearSize;
		DWORD dwDepth; // only if DDS_HEADER_FLAGS_VOLUME is set in dwHeaderFlags
		DWORD dwMipMapCount;
		DWORD dwAlphaBitDepth;
		DWORD dwReserved1[10];
		DDS_PIXELFORMAT ddspf;
		DWORD dwSurfaceFlags;
		DWORD dwReserved2[3];
		DWORD dwTextureStage;
	};

	// chunk identifier
	const static uint32 FOURCC_CExt							= MAKEFOURCC('C','E','x','t');		// Crytek extension start
	const static uint32 FOURCC_AvgC							= MAKEFOURCC('A','v','g','C');		// average color
	const static uint32 FOURCC_CEnd							= MAKEFOURCC('C','E','n','d');		// Crytek extension end
	const static uint32 FOURCC_AttC							= MAKEFOURCC('A','t','t','C');		// Chunk Attached Channel
	const static uint32 FOURCC_Flgs							= MAKEFOURCC('F','l','g','s');		// Chunk flags (1=cubemap, 2=volume, 4=decal)

	// flags to propagate from the RC to the engine through GetImageFlags()
	// 32bit bitmask, numbers should not change as engine relies on those numbers and rc_presets_pc.ini as well
	const static uint32 EIF_Cubemap							= 0x01;
	const static uint32 EIF_Volumetexture				= 0x02;
	const static uint32 EIF_Decal								= 0x04;			// this is usually set through the preset
	const static uint32 EIF_Greyscale						= 0x08;			// hint for the engine (e.g. greyscale light beams can be applied to shadow mask), can be for DXT1 because compression artfacts don't count as color
	const static uint32 EIF_SupressEngineReduce	= 0x10;			// info for the engine: don't reduce texture resolution on this texture
	const static uint32 EIF_DontStream					= 0x20;			// info for the engine: don't stream this texture
	const static uint32 EIF_FileSingle					= 0x40;			// info for the engine: no need to search for other files (e.g. DDNDIF) (only used for build)
/*
	// Arguments:
	//   pMem - usually first byte behind DDS file data, can be 0 (e.g. in case there no more bytes than DDS file data)
	// Returns:
	//   Chunk flags (combined from EIF_Cubemap,EIF_Volumetexture,EIF_Decal,...)
	static uint32 GetImageFlags( uint8 *pMem )
	{
		pMem=FindChunkStart(pMem,FOURCC_Flgs);

		if(pMem)
			return SwapEndianValue(*(uint32 *)pMem);

		return 0;	// chunk does not exist
	}
*/
	// Arguments:
	//   pDDSHeader - must not be 0
	// Returns:
	//   Chunk flags (combined from EIF_Cubemap,EIF_Volumetexture,EIF_Decal,...)
	static uint32 GetImageFlags( DDS_HEADER *pDDSHeader )
	{
		assert(pDDSHeader);

		// non standardized way to expose some features in the header (same information is in attached chunk but then
		// streaming would need to find this spot in the file)
		// if this is causing problems we need to change it 
		if(pDDSHeader->dwSize>=sizeof(DDS_HEADER))
		if(pDDSHeader->dwTextureStage == 'CRYF')
			return pDDSHeader->dwReserved1[0];
		return 0;
	}


	// Arguments:
	//   pMem - usually first byte behind DDS file data, can be 0 (e.g. in case there no more bytes than DDS file data)
	static ColorF GetAverageColor( uint8 *pMem )
	{
		pMem=FindChunkStart(pMem,FOURCC_AvgC);

		if(pMem)
		{
			ColorF ret = ColorF(SwapEndianValue(*(uint32 *)pMem));
			//flip red and blue
			const float cRed = ret.r;
			ret.r = ret.b;
			ret.b = cRed;
			return ret;
		}

		return Col_White;	// chunk does not exist
	}

	// Arguments:
	//   pMem - usually first byte behind DDS file data, can be 0 (e.g. in case there no more bytes than DDS file data)
	// Returns:
	//   pointer to the DDS header
	static DDS_HEADER *GetAttachedImage( uint8 *pMem, uint32 &dwOutSize )
	{
		pMem=FindChunkStart(pMem,FOURCC_AttC);

		if(pMem)
		{
			dwOutSize = SwapEndianValue(*(uint32 *)(&pMem[8]));
			return (DDS_HEADER *)(pMem + 4);
		}

		dwOutSize=0;
		return 0;	// chunk does not exist
	}

private: // -----------------------------------------------------------------------------------
	
	// Arguments:
	//   pMem - usually first byte behind DDS file data, can be 0 (e.g. in case there no more bytes than DDS file data)
	// Returns:
	//   0 if not existing
	static uint8 *FindChunkStart( uint8 *pMem, const uint32 dwChunkName )
	{
		if(pMem)
		if(*(uint32 *)pMem == SwapEndianValue(FOURCC_CExt))
		{
			pMem+=4;	// jump over chunk name
			while(*(uint32 *)pMem != SwapEndianValue(FOURCC_CEnd))
			{
				if(*(uint32 *)pMem == SwapEndianValue(dwChunkName))
				{
					pMem+=8;	// jump over chunk name and size
					return pMem;
				}
				
				pMem += 8 + SwapEndianValue(*(uint32 *)(&pMem[4]));		// jump over chunk
			}
		}

		return 0;	// chunk does not exist
	}

};


#endif // IMAGEEXTENSIONHELPER