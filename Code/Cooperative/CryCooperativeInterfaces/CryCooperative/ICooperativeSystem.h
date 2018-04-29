////---------------------------------------------------------------------------------------------------------------------
// Crysis Co-op Source Code File
////---------------------------------------------------------------------------------------------------------------------
// File:
//	- CryCooperative\ICooperativeSystem.h
// Description:
//	- Cooperative System interface declaration.
////---------------------------------------------------------------------------------------------------------------------

#pragma once

// Summary:
//	Interface to access the Cooperative System.
struct ICooperativeSystem
{
public:
	// Summary:
	//	Creates and initializes the system.
	// Returns:
	//	True if succeeded or already initialized, false otherwise.
	virtual bool Initialize(struct ISystem* pSystem) = 0;

	// Summary:
	//	Shuts down and destroys the system.
	virtual void Shutdown() = 0;

	// Summary:
	//	Updates the system.
	virtual void Update(float fFrameTime) = 0;

	// Summary:
	//	Gets a boolean indicating whether or not the current gamemode is multiplayer.
	virtual bool IsMultiplayer() const = 0;

	// Summary:
	//	Gets a boolean indicating whether or not the current gamemode is cooperative multiplayer.
	virtual bool IsCooperative() const = 0;

	// Summary:
	//	Gets a boolean indicating whether or not the current engine instance is a dedicated server.
	virtual bool IsDedicated() const = 0;
};
