#pragma once

// Summary:
//	Fakes client behavior for the current scope.
class CDedicatedServerHackScope
{
public:
	CDedicatedServerHackScope();
	~CDedicatedServerHackScope();

	void Exit();

private:
	bool m_bActive;
};