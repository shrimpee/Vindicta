#include "common.hpp"
/*
Goal for a garrison to relax
*/

#define pr private

CLASS("GoalGarrisonRebalanceVehicleGroups", "Goal")

	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	// By default returns instrinsic goal relevance
	
	/* virtual */ STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		pr _ws = GETV(_AI, "worldState");
		
		pr _allHaveDrivers = [_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, false] call ws_propertyExistsAndEquals;
		pr _enoughHumansToDrive = [_ws, WSP_GAR_ENOUGH_HUMANS_TO_DRIVE_ALL_VEHICLES, false] call ws_propertyExistsAndEquals;
		pr _allHaveTurretOperators = [_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, false] call ws_propertyExistsAndEquals;
		pr _enoughHumansToTurret = [_ws, WSP_GAR_ENOUGH_HUMANS_TO_TURRET_ALL_VEHICLES, false] call ws_propertyExistsAndEquals;

		if ( ( (!_allHaveDrivers) && _enoughHumansToDrive ) ||
			( (!_allHaveTurretOperators) && _enoughHumansToTurret )) then {
			GET_STATIC_VAR(_thisClass, "relevance");
		} else {
			0
		};
	} ENDMETHOD;

ENDCLASS;