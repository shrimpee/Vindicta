#include "common.hpp"
/*
Garrison moves on available vehicles
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonMoveMounted"

CLASS(THIS_ACTION_NAME, "ActionGarrison")


	VARIABLE("pos"); // The destination position
	VARIABLE("radius"); // Completion radius

	// ------------ N E W ------------
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		// Unpack position
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		pr _loc = "";
		if (_pos isEqualType []) then {
			T_SETV("pos", _pos); // Set value if array if passed
			pr _locAndDist = CALLSM1("Location", "getNearestLocation", _pos);
			_loc = _locAndDist select 0;
		} else {
			// Otherwise the location object was passed probably, get pos from location object
			_loc = _pos;
			pr _locPos = CALLM0(_loc, "getPos");
			T_SETV("pos", _locPos);
		};
		
		// Unpack radius
		pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_RADIUS);
		if (isNil "_radius") then {
			// Try to figure out completion radius from location
			//pr _radius = CALLM0(_loc, "getBoundingRadius"); // there is no such function
			// Just use 100 meters for now
			T_SETV("radius", 100);
		} else {
			T_SETV("radius", _radius);
		};
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		OOP_INFO_0("ACTIVATE");
		
		// Give waypoint to the vehicle group
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		pr _pos = T_GETV("pos");
		pr _radius = T_GETV("radius");
		
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		if (count _vehGroups > 1) then {
			OOP_ERROR_0("More than one vehicle group in the garrison!");
		};
		
		{
			pr _group = _x;
			pr _groupAI = CALLM0(_x, "getAI");
			
			// Add new goal to move
			pr _args = ["GoalGroupMoveGroundVehicles", 0, [[TAG_POS, _pos], [TAG_RADIUS, _radius]], _AI];
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);			
			
		} forEach _vehGroups;
		
		// Reset current location of this garrison
		// todo redo this crap, it will fail with headless clients
		pr _loc = CALLM0(_gar, "getLocation");
		OOP_INFO_1("Garrison's location: %1", _loc);
		if (_loc != "") then {
			if (CALLM0(_loc, "getGarrisonMilitaryMain") == _gar) then { // If this garrison is the main garrison of its location
				OOP_INFO_0("Posting method");
				CALLM2(_loc, "postMethodAsync", "setGarrisonMilitaryMain", [""]); // This location will no longer control spawning of this garrison
			};
			CALLM1(_gar, "setLocation", ""); // This garrison is no longer attached to its location
		};
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		// Fail if not everyone is in vehicles
		pr _everyoneIsMounted = CALLM0(_thisObject, "isEveryoneInVehicle");
		OOP_INFO_1("Everyone is in vehicles: %1", _everyoneIsMounted);
		if (! _everyoneIsMounted) exitWith {
			OOP_INFO_0("ACTION FAILED because not everyone is in vehicles");
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		scopeName "s0";
		
		if (_state == ACTION_STATE_ACTIVE) then {
		
			pr _gar = T_GETV("gar");
			pr _AI = T_GETV("AI");
			pr _pos = T_GETV("pos");
		
			pr _args = [GROUP_TYPE_VEH_NON_STATIC, GROUP_TYPE_VEH_STATIC];
			pr _vehGroups = CALLM1(_gar, "findGroupsByType", _args);
			
			// Fail if any group has failed
			if (CALLSM3("AI", "anyAgentFailedExternalGoal", _vehGroups, "GoalGroupMoveGroundVehicles", "")) then {
				_state = ACTION_STATE_FAILED;
				breakTo "s0";
			};
			
			// Succede if all groups have completed the goal
			if (CALLSM3("AI", "allAgentsCompletedExternalGoal", _vehGroups, "GoalGroupMoveGroundVehicles", "")) then {
				OOP_INFO_0("All groups have arrived");
				
				// Set pos world state property
				pr _ws = GETV(_AI, "worldState");
				[_ws, WSP_GAR_POSITION, _pos] call ws_setPropertyValue;
				[_ws, WSP_GAR_VEHICLES_POSITION, _pos] call ws_setPropertyValue;
				
				_state = ACTION_STATE_COMPLETED;
				breakTo "s0";
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// Returns true if everyone is in vehicles
	METHOD("isEveryoneInVehicle") {
		params ["_thisObject"];
		pr _AI = T_GETV("AI");
		pr _ws = GETV(_AI, "worldState");
		
		pr _return = 	([_ws, WSP_GAR_ALL_CREW_MOUNTED] call ws_getPropertyValue) &&
						([_ws, WSP_GAR_ALL_INFANTRY_MOUNTED] call ws_getPropertyValue);
		
		_return
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		pr _gar = T_GETV("gar");
		// Terminate given goals
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		{
			pr _group = _x;
			pr _groupAI = CALLM0(_x, "getAI");
			// Delete other goals like this first
			pr _args = ["GoalGroupMoveGroundVehicles", ""];
			CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);			
		} forEach _vehGroups;
		
	} ENDMETHOD;

ENDCLASS;