#pragma once

// Summary:
//	Fakes client behavior for the current scope.
class CDedicatedServerHackScope
{
public:
	static void Enter();

	static void Exit();
};