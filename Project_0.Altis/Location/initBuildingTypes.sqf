/*
Building positions suitable for specific roles.

Each building position is structered:
	[_buildingPosID, _direction]
		_buildingPosID - number of the building position returned by buildingPos command.
		_direction - hte direction where the unit must be heading relative to the building's position.
	OR it can be specified in cylindrical coordinates relative to building's center:
	[_offset, _offsetDirection, _offsetHeight, _direction]
		_offset - the magnitude of the offset projected onto horizontal plane.
		_offsetDirection - the direction of the offset.
		_offsetHeight - the height of the offset.
		_direction - direction where the unit must be heading relative to the building's position.

The structure of each array with positions for specific type is:
	[[_typesArray, _positionArray], [_typesArray, _positionArray], ...]
		_typesArray - the array of types (typeOf ...) of this building sharing the same building positions. For example, different variants of the same watchtower.
		_positioArray - the array of positions in the form [_buildingPosID, _direction] or [_offset, _offsetDirection, _offsetHeight, _direction]
*/

//Positions where a high GMG or a high HMG can be placed and operated from.
location_bp_HGM_GMG_high =
[
	[ //The giant military tower
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F"],
		[[11, 90], [13, 0], [14, 0], [16, 180], [17, 180]]
	],
	[ //The small military watchtower
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"],
		[[1.9, 220, 4.4, 180], [1.9, 130, 4.4, 180]]
	]

	/*
	[ //The military HQ
		["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F"],
		[[4, 90], [5, 0], [6, -45], [7, 225], [8, 180]]
	]
	*/
];

//Positions where soldiers can freely shoot from.
//Note that soldiers can also shoot well from HMG positions.
location_bp_sentry =
[
	[ //The giant military tower
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F"],
		[[0, 0], [1, 0], [10, 180], [12, 0], [15, 270], [2, 0], [4, 180], [7, 90], [8, 270]]
	],
	[ //The small military watchtower
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"],
		[[0, 180], [1, 180]]
	],
	[ //The military HQ
		["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F"],
		[[4, 90], [5, 0], [6, -45], [7, 225], [8, 180]]
	]
];

// Capacities of buildings for infantry
// Typically a building's inf capacity is amount of its buildingPos, however for some buildings we can override that here
location_b_capacity =
[
	[ //The giant military tower
		["Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V2_F", "Land_Cargo_Tower_V3_F"],
		14
	],
	[ //The small military watchtower
		["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"],
		2
	],
	[ //The military HQ
		["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V2_F", "Land_Cargo_HQ_V3_F"],
		10
	],
	[ //The military metal box
		["Land_Cargo_House_V1_F", "Land_Cargo_House_V2_F", "Land_Cargo_House_V3_F"],
		4
	],
	// Tents
	[
		["Land_MedicalTent_01_wdl_generic_inner_F",
		"Land_MedicalTent_01_aaf_generic_inner_F",
		"Land_MedicalTent_01_CSAT_brownhex_generic_inner_F",
		"Land_MedicalTent_01_NATO_generic_inner_F",
		"Land_MedicalTent_01_CSAT_greenhex_generic_inner_F",
		"Land_MedicalTent_01_NATO_tropic_generic_inner_F"],
		8
	]
];

// Positions for cargo boxes
location_bp_cargo_medium =
[
	[
		["Land_i_House_Small_01_V3_F", "Land_i_House_Small_01_V1_F", "Land_i_House_Small_01_V2_F", "Land_u_House_Small_01_V1_F"],
		[[2.07516,262.755,0.29788], [3.47262,218.056,0.29805]]
	],
	[
		["Land_i_House_Big_01_V1_F", "Land_i_House_Big_01_V2_F", "Land_i_House_Big_01_V3_F", "Land_u_House_Big_01_V1_F"],
		[[1.64695,117.933,0.498999], [5.47226,166.207,0.498999]]
	],
	[
		["Land_i_Stone_HouseBig_V1_F", "Land_i_Stone_HouseBig_V2_F", "Land_i_Stone_HouseBig_V3_F", "Land_u_Stone_HouseBig_V3_F"],
		[[0.439735,11.0105,3.059], [3.10748,83.2502,3.059]]
	],
	[
		["Land_i_Stone_HouseSmall_V1_F", "Land_i_Stone_HouseSmall_V2_F", "Land_i_Stone_HouseSmall_V3_F", "Land_u_Stone_HouseSmall_V1_F"],
		[[7.5625,69.7211,1.26548], [4.66482,54.9392,1.2517]]
	],
	[
		["Land_i_House_Small_02_V1_F", "Land_i_House_Small_02_V2_F", "Land_i_House_Small_02_V3_F", "Land_u_House_Small_02_V1_F"],
		[[3.10205,87.7267,0.418344], [5.15135,88.892,0.420984]]
	],
	[
		["Land_i_Shop_01_V1_F", "Land_i_Shop_01_V2_F", "Land_i_Shop_01_V3_F", "Land_u_Shop_01_V1_F"],
		[[1.14865,286.802,0.302086], [3.6354,341.39,0.302084]]
	],
	[
		["Land_i_House_Big_02_V1_F", "Land_i_House_Big_02_V2_F", "Land_i_House_Big_02_V3_F", "Land_u_House_Big_02_V1_F"],
		[[3.55678,42.062,0.258254], [3.1946,326.951,0.258255]]
	]
];

// Buildings which can be used as police stations
location_bt_police = 
[
	"Land_i_Shop_01_V2_F",
	"Land_i_Shop_01_V3_F",
	"Land_u_Shop_01_V1_F",
	"Land_i_House_Small_01_V3_F",
	"Land_u_House_Small_01_V1_F",
	"Land_i_House_Small_01_V2_F",
	"Land_u_House_Big_02_V1_F",
	"Land_i_Stone_HouseBig_V3_F",
	"Land_i_Stone_HouseBig_V2_F",
	"Land_i_Stone_HouseBig_V1_F",
	"Land_u_House_Small_02_V1_F",
	"Land_i_House_Small_02_V1_F",
	"Land_i_House_Small_02_V3_F",
	"Land_i_House_Small_02_V2_F",
	"Land_i_House_Big_02_V3_F",
	"Land_i_House_Big_02_V2_F",
	"Land_i_House_Big_02_V1_F",
	"Land_i_Stone_HouseSmall_V3_F",
	"Land_i_Stone_HouseSmall_V1_F",
	"Land_i_Stone_HouseSmall_V2_F",
	"Land_i_House_Big_01_V1_F",
	"Land_i_House_Big_01_V2_F",
	"Land_u_House_Big_01_V1_F",
	"Land_i_House_Big_01_V3_F"
];

location_police_decorations =
[
	[
		["Land_i_Shop_01_V2_F", "Land_u_Shop_01_V1_F"],
		[[4.14646,259.002,1.82516,90],[4.67004,216.463,1.82516,0]]
	],
	[
		["Land_i_Shop_01_V2_F", "Land_u_Shop_01_V1_F"],
		[[4.14646,259.002,1.82516,90],[4.67004,216.463,1.82516,0]]
	]
];

// Buildings which add radio functionality to the location
location_bt_radio =
[
	"Land_TBox_F",				// Transmitter box which can be created through build UI
	// "Land_TTowerSmall_1_F",	// Not sure, looks like some small mobile phone antenna
	"Land_TTowerSmall_2_F",		// Verticall array of small dipoles
	"Land_TTowerBig_1_F",		// A-like transmitter tower
	"Land_TTowerBig_2_F",		// Tall I-like transmitter tower
	"Land_Communication_F"		// Tall tower with antennas on top, often found at military outposts
];

/*
_newdir = direction b + 180;
(vehicle player) setDir _newDir;
vehicle player setPos ((b getPos [1.5, (direction b) + 240]) vectorAdd [0, 0, 4.4]);
*/

/*
// Code to get the coordinates in cylindrical form
_b = gBuilding;
_o = cursorObject;

_bPos = getPosATL _b;
_oPos = getPosATL _o;

_dirRel = (_bPos getDir _oPos) - (direction _b);
_zRel = _oPos#2 - _bPos#2;
_distRel = _bPos distance2D _oPos;

[_distRel, _dirRel, _zRel]
*/

/*
// Same code as above, also gives the direction of object relative to direction of house
_b = gBuilding;
_o = cursorObject;

_bPos = getPosATL _b;
_oPos = getPosATL _o;

_dirRel = (_bPos getDir _oPos) - (direction _b);
_zRel = _oPos#2 - _bPos#2;
_distRel = _bPos distance2D _oPos;

_objDir = (direction _o) - (direction _b);

[_distRel, _dirRel, _zRel, _objDir]
*/


/*
// Code to export texture offsets right from the editor
// Must select house and texture objects

_objects = get3DENSelected "object";
_house = _objects select {_x isKindOf "House"} select 0;
_textures = _objects select {_x isKindOf "UserTexture1m_F"};

_arrayExport = []; // dist, posDir, zrel, dir

{
_b = _house; 
_o = _x; 
 
_bPos = getPosATL _b; 
_oPos = getPosATL _o; 
 
_dirRel = (_bPos getDir _oPos) - (direction _b); 
_zRel = _oPos#2 - _bPos#2; 
_distRel = _bPos distance2D _oPos; 
 
_objDir = (direction _o) - (direction _b); 
 
_arrayExport pushBack [_distRel, _dirRel, _zRel, round _objDir];
} forEach _textures;

_arrayExport
*/



/*
//Code to get class names of all selected eden objects
(get3DENSelected "object") apply {typeof _x}
*/