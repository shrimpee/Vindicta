/*

*/

#define DEBUG

params ["_gar", "_stateArray"];

private _state = _stateArray select 0;
private _stateChanged = _stateArray select 1;

private _m = _gar call gar_fnc_getAssignedMission;
private _oTask = _gar call gar_fnc_getTask;
private _failureReason = "";

//State machine
switch (_state) do
{
	case "INIT":
	{
		if (_stateChanged) then
		{
			#ifdef DEBUG
			diag_log format ["INFO: mission\fn_SAD.sqf: mission %1 entered INIT state", _m getVariable "AI_m_name"];
			#endif
			//Switch state
			_stateChanged = true;
			_state = "MOVE";
		};
	};
	
	case "MOVE":
	{
		if (_stateChanged) then
		{
			#ifdef DEBUG
			diag_log format ["INFO: mission\fn_SAD.sqf: mission %1 entered MOVE state", _m getVariable "AI_m_name"];
			#endif
			
			//Read mission parameters
			private _mParams = _m getVariable "AI_m_params";
			_mParams params ["_target"];
			
			//Stop previous task (if it exists)
			_oTask call AI_fnc_task_delete;
			
			//Create the new task
			_oTask = [_gar, "MOVE", [_target, 500], "Move, SAD mission"] call AI_fnc_task_create;
			_oTask call AI_fnc_task_start;
			
			_stateChanged = false;
		};
		
		//Wait until the move task has been finished
		private _taskState = _oTask call AI_fnc_task_getState;
		if (_taskState != "RUNNING") then
		{
			switch (_taskState) do
			{
				case "SUCCESS":
				{
					_state = "SAD";
					_stateChanged = true;
				};
				case "FAILURE":
				{
					_failureReason = _oTask call AI_fnc_task_getFailureReason;
				};
			};
		};
	};
	
	case "SAD":
	{
		if (_stateChanged) then
		{
			#ifdef DEBUG
			diag_log format ["INFO: mission\fn_SAD.sqf: mission %1 entered SAD state", _m getVariable "AI_m_name"];
			#endif
			
			//Stop previous task
			_oTask call AI_fnc_task_delete;
			_stateChanged = false;
			
			//Read mission parameters
			private _mParams = _m getVariable "AI_m_params";
			_mParams params ["_target"];
			
			//Create new task
			_oTask = [_gar, "SAD", [_target, 200, 666666666], "SAD, SAD mission"] call AI_fnc_task_create; //target, radius, time
			//taskSAD = _oTaskSAD;
			_oTask call AI_fnc_task_start;
		};
	};
};

//Return value
[_state, _stateChanged, _failureReason]