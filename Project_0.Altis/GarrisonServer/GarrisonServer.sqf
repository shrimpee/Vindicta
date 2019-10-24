#include "common.hpp"

/*
Class: GarrisonServer
Singleton server-only class.
Collects garrisons which have changed their state and sends periodic updates about garrisons to clients which need the data.

When garrison data updates (composition, etc) many times in a short period of time we don't want to send new data on each update,
but we want to send new data at a specific rate.

Author: Sparker 23 August 2019
*/

#define pr private

#define __JIP_ID_SUFFIX "_srv_update"

CLASS("GarrisonServer", "MessageReceiverEx")

	// Array with all objects
	VARIABLE("objects");

	// Array with garrisons which have just been created
	VARIABLE("createdObjects");

	// Array with garrisons for which update events will be broadcasted at next update cycle
	VARIABLE("outdatedObjects");
	
	// Array with garrisons for which destroyed events will be broadcasted at next update cycle
	VARIABLE("destroyedObjects");

	VARIABLE("timer");
	VARIABLE("timer1");

	STATIC_VARIABLE("instance");

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("outdatedObjects", []);
		T_SETV("destroyedObjects", []);
		T_SETV("createdObjects", []);
		T_SETV("objects", []);

		// Timer to send garrison update messages
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _thisObject];
		_msg set [MESSAGE_ID_SOURCE, ""];
		_msg set [MESSAGE_ID_DATA, []];
		_msg set [MESSAGE_ID_TYPE, "process"];
		pr _processInterval = 1;
		private _args = [_thisObject, _processInterval, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
		private _timer = NEW("Timer", _args);
		SETV(_thisObject, "timer", _timer);

		if (!isNil {GETSV("GarrisonServer", "instance")}) then {
			OOP_ERROR_1("Multiple instances of GarrisonServer are not allowed! %1", _thisObject);
		};
		SETSV("GarrisonServer", "instance", _thisObject);

	} ENDMETHOD;

	// Sends update messages about a garrison(_gar) to _target(same as remoteExecCall target)
	METHOD("_sendUpdate") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar"), "_target"];

		// Create a GarrisonRecord to serialize it (to deserialize it at the client machine)
		pr _tempRecord = NEW("GarrisonRecord", [_gar]);
		CALLM1(_tempRecord, "initFromGarrison", _gar);
		pr _serArray = SERIALIZE(_tempRecord);
		DELETE(_tempRecord);

		OOP_INFO_2("SEND UPDATE Garrison: %1, target: %2", _gar, _target);
		OOP_INFO_1("  data: %1", _serArray);

		// Now we can send the serialized array
		pr _jipid = _gar + __JIP_ID_SUFFIX;
		REMOTE_EXEC_CALL_STATIC_METHOD("GarrisonDatabaseClient", "update", [_serArray], _target, _jipid); // classNameStr, methodNameStr, extraParams, targets, JIP
	} ENDMETHOD;

	// We only receive messages from timer now, so we don't care about the message type
	// - - - - Processing of garrisons - - - - -
	METHOD("process") {
		params [P_THISOBJECT];

		// Broadcast update messages
		// This also corresponds to just created garrisons as they are outdated
		pr _outdatedGarrisons = T_GETV("outdatedObjects") + T_GETV("createdObjects");
		if (count _outdatedGarrisons > 0) then { OOP_INFO_1("OUTDATED: %1", _outdatedGarrisons); };
		{
			pr _gar = _x;
			if (IS_OOP_OBJECT(_gar)) then {
				if (CALLM0(_gar, "isAlive")) then { // We only serve update events here
					pr _side = GETV(_gar, "side");
					T_CALLM2("_sendUpdate", _gar, _side); // Send data to all clients of same side as this garrison
				};
			};
		} forEach _outdatedGarrisons;

		// Broadcast destroyed events
		pr _destroyedGarrisons = T_GETV("destroyedObjects");
		if (count _destroyedGarrisons > 0) then { OOP_INFO_1("DESTROYED: %1", _destroyedGarrisons); };
		// Just send data to everyone, those who don't care about these objects will just ignore them
		{
			pr _sides = [EAST, WEST, INDEPENDENT, CIVILIAN];
			REMOTE_EXEC_CALL_STATIC_METHOD("GarrisonDatabaseClient", "destroy", [_x], _sides, false); // Execute on all machines with interface, don't add to JIP!
			// Remove the message from the JIP queue
			pr _jipid = _x + __JIP_ID_SUFFIX;
			remoteExecCall ["", _jipid];

			// Remove from our array of objects
			pr _objects = T_GETV("objects");
			pr _index = _objects find _x;
			_objects deleteAt _index;

			// Unref if we have ever referenced it
			if (_index != -1) then {
				UNREF(_x);
			};
		} forEach _destroyedGarrisons;

		// Reset the arrays of garrisons to broadcast
		T_SETV("outdatedObjects", []);
		T_SETV("destroyedObjects", []);
		T_SETV("createdObjects", []);

	} ENDMETHOD;


	// Called when a client has connected
	METHOD("onClientConnected") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_SIDE("_side")];

		OOP_INFO_2("CLIENT CONNECTED: %1, side: %2", _clientOwner, _side);

		// Transmit data about all garrisons with the same side
		pr _garrisons = CALLSM2("Garrison", "getAllActive", [_side], []);
		{
			T_CALLM2("_sendUpdate", _x, _side); // Send data to all clients of same side as this garrison
		} forEach _garrisons;

	} ENDMETHOD;


	// - - - - Methods to be called by garrison on various events - - - - 

	// Marks the garrison as just created
	METHOD("onGarrisonCreated") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];

		T_GETV("createdObjects") pushBackUnique _gar;
		T_GETV("objects") pushBackUnique _gar;

		// Ref
		REF(_gar);
	} ENDMETHOD;

	// Marks the garrison requiring an update broadcast
	METHOD("onGarrisonOutdated") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];

		T_GETV("outdatedObjects") pushBackUnique _gar;
	} ENDMETHOD;

	// Marks the garrison requiring a destroyed event broadcast
	METHOD("onGarrisonDestroyed") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];

		T_GETV("destroyedObjects") pushBackUnique _gar;

		// Make sure we don't send an update event about it any more
		pr _outdatedObjects = T_GETV("outdatedObjects");
		_outdatedObjects deleteAt (_outdatedObjects find _gar);
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 




	// GarrisonServer is attached to the main message loop
	METHOD("getMessageLoop") {
		gMessageLoopMain
	} ENDMETHOD;

	// Player's requests

	// This runs in the thread
	METHOD("buildFromGarrison") {
		OOP_INFO_1("BUILD FROM GARRISON: %1", _this);
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_OOP_OBJECT("_gar"),
				P_STRING("_catCfgClassNameStr"), P_STRING("_objCfgClassNameStr"),
				P_POSITION("_pos"), P_NUMBER("_dir"), P_BOOL("_checkGarrisonBuildRes")];
		
		// Bail if the garrison isn't registered any more
		if (!(_gar in T_GETV("objects"))) exitWith {
			"We can't build here any more" remoteExecCall ["systemChat", _clientOwner];
		};

		pr _buildRes = CALLM1(_gar, "getBuildResources", true); // Force update

		// Get data from config
		pr _objClass = missionConfigFile >> "BuildObjects" >> "Categories" >> _catCfgClassNameStr >> _objCfgClassNameStr;
		pr _className = getText (_objClass >> "className");
		pr _cost = getNumber (_objClass >> "buildResource");
		pr _catID = getNumber (_objClass >> "templateCatID");
		pr _subcatID = getNumber (_objClass >> "templateSubcatID");
		pr _isRadio = [false, true] select (getNumber (_objClass >> "isRadio"));

		// Bail if there is not enough resources
		if (_buildRes < _cost && _checkGarrisonBuildRes) exitWith {
			pr _objName = getText (configfile >> "CfgVehicles" >> _className >> "displayName");
			pr _text = format ["Not enough resources to build %1", _objName];
			_text remoteExecCall ["systemChat", _clientOwner];
		};

		// Looks like we are able to build it
		CALLM1(_gar, "removeBuildResources", _cost);

		// Create a unit or just a plain object
		pr _hO = _className createVehicle _pos;
		_hO setPos _pos;
		_hO setDir _dir;
		pr _surfaceVectorUp = surfaceNormal _pos;
		_hO setVectorUp _surfaceVectorUp;
		if (_catID != -1) then {
			pr _args = [[], _catID, _subcatID, -1, "", _hO];
			pr _unit = NEW("Unit", _args);
			CALLM1(_gar, "addUnit", _unit);

			// If it's a cargo box, initialize the limited arsenal on it
			if (_catID == T_CARGO) then {
				CALLM1(_unit, "limitedArsenalEnable", true);
			};
		};

		CALL_STATIC_METHOD_2("BuildUI", "setObjectMovable", _hO, true);

		// Add the built object to the location
		pr _loc = CALLM0(_gar, "getLocation");
		if (!IS_NULL_OBJECT(_loc)) then {
			// Add this object to location, if it's not a Unit object but a basic object
			if (_catID == -1) then {
				CALLM1(_loc, "addObject", _hO);
			};

			// Player might have added an object which affects location's player respawn capabilities,
			// so we must update it
			pr _gmdata = CALLM0(_loc, "getGameModeData");
			if (!IS_NULL_OBJECT(_gmdata)) then {
				CALLM0(_gmdata, "updatePlayerRespawn");
			};
		};

		// Send message to player
		pr _objName = getText (configfile >> "CfgVehicles" >> _className >> "displayName");
		pr _text = format ["Object %1 was build successfully!", _objName];
		_text remoteExecCall ["systemChat", _clientOwner];
	} ENDMETHOD;

	// Recruits a unit at this location from one of nearby cities
	METHOD("recruitUnitAtLocation") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_OOP_OBJECT("_loc"), P_SIDE("_side")];

		// Ensure that we can recruit at this place
		pr _pos = CALLM0(_loc, "getPos");
		pr _cities = CALLSM1("CivilWarGameMode", "getRecruitCities", _pos);
		pr _nRecruits = CALLSM1("CivilWarGameMode", "getRecruitCount", _cities);

		// Bail if we can't recruit here any more
		if (_nRecruits < 1) exitWith {
			"Not enough recruits in this area any more!" remoteExecCall ["systemChat", _clientOwner];
		};

		// Remove recruits from any city
		pr _gmdata = GETV(_cities#0, "gameModeData");
		CALLM1(_gmdata, "removeRecruits", 1);

		// Find an existing garrison here or create one
		pr _gars = CALLM1(_loc, "getGarrisons", _side);
		pr _gar = if ((count _gars) > 0) then {
			_gars#0
		} else {
			pr _locPos = CALLM0(_loc, "getPos");
			// Create a new garrison and register it
			_gar = NEW("Garrison", [_side ARG _locPos]);
			CALLM0(_gar, "activate");
			CALLM1(_gar, "setLocation", _loc);
			_activate = true;
			_gar
		};


		// Bail if the infantry capacity of the location has been reached
		pr _capinf = CALLM0(_loc, "getCapacityInf");
		pr _nInf = CALLM0(_gar, "countInfantryUnits");
		if (_nInf >= _capInf) exitWith {
			"Infantry capacity of this location has been reached!" remoteExecCall ["systemChat", _clientOwner];
		};


		// Create a group or pick an existing one
		pr _groupToJoin = "";
		pr _groups = CALLM0(_gar, "getGroups") select {(CALLM0(_x, "getType") == GROUP_TYPE_IDLE) && ((count CALLM0(_x, "getUnits")) < 5)};
		if (count _groups != 0) then {
			_groupToJoin = _groups#0;
		};

		pr _group = NEW("Group", [_side ARG GROUP_TYPE_IDLE]);

		// Create a unit
		pr _subcatid = selectRandom [T_INF_rifleman, T_INF_marksman, T_INF_LMG, T_INF_LAT, T_INF_medic];
		pr _template = ["tGuerilla"] call t_fnc_getTemplate;
		// ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]], ["_hO", objNull]];
		pr _args = [_template, T_INF, _subcatID, -1, _group];
		pr _unit = NEW("Unit", _args);

		// Add its new group to the garrison
		CALLM1(_gar, "addGroup", _group);

		// Join an existing group if it exists
		if (_groupToJoin != "") then {
			CALLM1(_groupToJoin, "addGroup", _group);
		};

		// Send msg back
		pr _name = T_NAMES#T_INF#_subcatID;
		pr _text = format ["We have recruited one %1", _name];
		_text remoteExecCall ["systemChat", _clientOwner];

	} ENDMETHOD;

ENDCLASS;