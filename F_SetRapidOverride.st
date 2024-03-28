(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_SetRapidOverride : DWORD
(*
F ***************************************************************************************
F * File name    : F_SetRapidOverride.st                                                *
F * Description  : Set Rapid override request from PLC, works like the system function  *
F *                block with three more possibility: the request can be applyed to all *
F *                processes, one flag permit to decide if the request is comparable    *
F *                to an operator request (like a console) and can be refused by the    *
F *                filter task, another flag enable the modification of the override    *
F *                value in the filter task (for example to align at the predefined     *
F *                steps).                                                              *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author        date        comments                                                *
F *                                                                                     *
F *   Scapolan      23-05-16    Function creation                                       *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iiExecMode          INT                                             *
F *                     Command execution modality: MODE_NOWAIT, MODE_WAIT              *
F *                                                                                     *
F *                 iiProc              INT                                             *
F *                     Process number 1..24 or -1 (ciProcAll) to request to all        *
F *                     processes.                                                      *
F *                                                                                     *
F *                 iiLastProc          INT                                             *
F *                     Last process number, used only if the request is for all        *
F *                     processes.                                                      *
F *                                                                                     *
F *                 iiNoProc            INT                                             *
F *                     Process number to skip if the request is for all processes,     *
F *                     0 to apply to every processes.                                  *
F *                                                                                     *
F *                 iiPercent           INT                                             *
F *                     New override value 10000=100%                                   *
F *                                                                                     *
F *                 iOpConsole          BOOL                                            *
F *                     Console flag, the request is comparable to an operator console, *
F *                     can be rfeused by filter task                                   *
F *                                                                                     *
F *                 iOpAdjust           BOOL                                            *
F *                     Enable modification (Adjust) of override value from PLC request *
F *                                                                                     *
F * Return       :  DWORD                                                               *
F *                     SetRapidOverride function block return code                     *
F *                                                                                     *
F * Global used  :  gPlcConOvrR          array [0..ciMaxProc] of bool                          *
F *                     Set Rapid override request from Plc console ambient memory      *
F *                                                                                     *
F *                 gPlcConAdjR          array [0..ciMaxProc] of BOOL                          *
F *                     Enable the modification of the override value in the filter     *
F *                     task (for example to align at the predefined steps)             *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* Set Rapid override request from PLC, works like the system function block with two more possibility:
	the request can be applyed to all processes, one flag permit to decide if the request is comparable
	to an operator request (like a console) and can be refused by the filter task, another flag enable the
	modification of the override value in the filter task (for example to align at the predefined steps). */

llRetCode	:= F_SetRapidOverride(
	iiExecMode,		\* IN	INT		Command execution modality: MODE_NOWAIT, MODE_WAIT */
	iiProc,			\* IN	INT		Process number 1..24 or -1 (ciProcAll) to request to all processes */
	iiLastProc,		\* IN	INT		Last process number, used only if the request is for all processes */
	iiNoProc,		\* IN	INT		Process number to skip if the request is for all processes, 0 to apply to every processes */
	iiPercent,		\* IN	INT		New override value 10000=100% */
	iOpConsole,		\* IN	BOOL	Console flag, the request is comparable to an operator console, can be rfeused by filter task */
	iOpAdjust);		\* IN	BOOL	Enable modification (Adjust) of override value from this PLC request */

\* Example to apply the request only at the selected process with the filter enabled, the 3rd and 4th input data are not used,
	the override value are not modified in the filter task */
llRetCode	:= F_SetRapidOverride(MODE_NOWAIT, SI_PROCSEL, MI_LastProc, 0 \*iiNoProc*/, liOverride, true \*iOpConsole*/, false \*iOpAdjust*/);

\* Example to apply the request to every existing process with the filter enabled,
	but the override value are not modified in the filter task */
llRetCode	:= F_SetRapidOverride(MODE_NOWAIT, ciProcAll, MI_LastProc, 0 \*iiNoProc*/, liOverride, true \*iOpConsole*/, false \*iOpAdjust*/);

\* Example to apply the request to every existing process, except the process number 1, with the filter enabled,
	but the override value are not modified in the filter task */
llRetCode	:= F_SetRapidOverride(MODE_NOWAIT, ciProcAll, MI_LastProc, 1 \*iiNoProc*/, liOverride, true \*iOpConsole*/, false \*iOpAdjust*/);
*)


	#IMPORT  "GvU_Variable.gvl"
	#IMPORT  "Gv_Allprocess.gvl"

VAR_INPUT
	iiProc		: int;	(* Process number 1..24 or -1 (ciProcAll) to request to all processes *)
	iiPercent	: int;	(* New override value 10000=100% *)
	iOpConsole	: bool;	(* Console flag, the request is comparable to an operator console, can be rfeused by filter task *)
	iOpAdjust	: bool;	(* Enable modification (Adjust) of override value from PLC request *)
END_VAR

VAR
	llExecStatus	: dword;	(* Function block execution status, not used *)
END_VAR;


gPlcConOvrR[iiProc]	:= iOpConsole;	(* Plc console ambient memory *)
gPlcConAdjR[iiProc]	:= iOpAdjust;	(* Enable modification (Adjust) of override value from PLC request *)
F_SetRapidOverride	:= SetRapidOverride(MODE_NOWAIT, llExecStatus, iiProc, iiPercent);

END_FUNCTION
