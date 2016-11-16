#include <StdAfx.h>
#include "CoopCutsceneSystem.h"
#include <IGameFramework.h>
#include <IEntitySystem.h>
 
CCoopCutsceneSystem CCoopCutsceneSystem::s_instance = CCoopCutsceneSystem();
 
CCoopCutsceneSystem::CCoopCutsceneSystem() : m_bPlayingCutscene(0),
    m_pCameraEntity(0),
    //m_pCurrentView(0),
    m_fCameraFOV(0)
{
 
}
 
CCoopCutsceneSystem::~CCoopCutsceneSystem()
{
 
}
 
void CCoopCutsceneSystem::Register()
{
    if (!gEnv->bEditor)
        gEnv->pGame->GetIGameFramework()->GetIViewSystem()->AddListener(this);
}
 
void CCoopCutsceneSystem::Unregister()
{
    if (!gEnv->bEditor)
        gEnv->pGame->GetIGameFramework()->GetIViewSystem()->RemoveListener(this);
}
 
void CCoopCutsceneSystem::Update(float fFrameTime)
{
    if (m_bPlayingCutscene && m_pCameraEntity && !gEnv->bEditor)
    {
        IView* pView = gEnv->pGame->GetIGameFramework()->GetIViewSystem()->GetActiveView();
        if (pView)
        {
            SViewParams* currParams = (SViewParams*)pView->GetCurrentParams();
            if (currParams)
            {
                currParams->position = m_pCameraEntity->GetWorldPos();
                currParams->rotation = m_pCameraEntity->GetWorldRotation();
                currParams->fov = m_fCameraFOV;
 
                if (!m_bPlayingCutsceneLastFrame)
                {
                    m_bCutsceneBlending = currParams->blend;
                    currParams->blend = false;
                }
                else
                {
                    currParams->blend = m_bCutsceneBlending;
                }
            }
        }
    }
 
    m_bPlayingCutsceneLastFrame = m_bPlayingCutscene;
}
 
 
 
 
bool CCoopCutsceneSystem::OnBeginCutScene(IAnimSequence* pSeq, bool bResetFX)
{
    m_bPlayingCutscene = true;
    return true;
}
 
bool CCoopCutsceneSystem::OnEndCutScene(IAnimSequence* pSeq)
{
    m_bPlayingCutscene = false;
    return true;
}
void CCoopCutsceneSystem::OnPlayCutSceneSound(IAnimSequence* pSeq, ISound* pSound)
{
 
}
bool CCoopCutsceneSystem::OnCameraChange(const SCameraParams& cameraParams)
{
    m_pCameraEntity = gEnv->pEntitySystem->GetEntity(cameraParams.cameraEntityId);
    m_fCameraFOV = cameraParams.fFOV;
 
    return true;
}