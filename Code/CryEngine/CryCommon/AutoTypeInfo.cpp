#include <platform.h>

#ifdef ENABLE_TYPE_INFO

#include "TypeInfo_impl.h"

// Includes needed for Auto-defined types.
#include "Cry_Math.h"
#include "primitives.h"
using namespace primitives;
#include "physinterface.h"
#include "CryHeaders.h"
#include "IXml.h"
#include "I3DEngine.h"
#include "ISystem.h"
#include "CryName.h"
#include "IRenderAuxGeom.h"
#include "IEntityRenderState.h"
#include "IIndexedMesh.h"
#include "CGFContent.h"
#include "Force.h"
#include "I3DSampler.h"
#include "XMLBinaryHeaders.h"

#include "../CrySystem/ZipFileFormat.h"
#include "../Cry3DEngine/dds.h"
#include "../Cry3DEngine/VoxMan.h"
#include "../Cry3DEngine/LMSerializationManager.h"
#include "../Cry3DEngine/SkyLightNishita.h"
#include "../CryPhysics/bvtree.h"
#include "../CryPhysics/aabbtree.h"
#include "../CryPhysics/obbtree.h"
#include "../CryPhysics/geoman.h"
#include "../CryAction/IAnimationGraph.h"
#include "../CryAction/AnimationGraph/StateIndex.h"
#include "../CryAISystem/AutoTypeStructs.h"
#include "../CrySoundSystem/MusicSystem/Decoder/ADPCMDecoder.h"
#include "../CrySoundSystem/MusicSystem/Decoder/PatternDecoder.h"
#include "../RenderDll/Common/ResFile.h"

#ifndef NULL_RENDERER
	#define NULL_RENDERER
#endif
#undef STATS
#define STATS 0
#include "../RenderDll/Common/CommonRender.h"
#include "../RenderDll/Common/Shaders/Shader.h"
#include "../RenderDll/Common/Shaders/CShaderBin.h"
#include "../CryAction/PlayerProfiles/RichSaveGameTypes.h"

// The auto-generated info file.
#include "../../Solutions/AutoTypeInfo.h"


// Manually implement type infos as needed.

TYPE_INFO_PLAIN(primitives::getHeightCallback)
TYPE_INFO_PLAIN(primitives::getSurfTypeCallback)

STRUCT_INFO_T_INSTANTIATE(Color_tpl, <float>)
STRUCT_INFO_T_INSTANTIATE(Ang3_tpl, <float>)
STRUCT_INFO_T_INSTANTIATE(Plane_tpl, <float>)

#endif
