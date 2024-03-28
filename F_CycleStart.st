(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_CycleStart : DWORD
(*
F ***************************************************************************************
F * File name    : F_CycleStart.st                                                      *
F * Description  : CycleStart request from PLC, works like the system function block    *
F *                with one more flag to decide if the request is comparable to an      *
F *                operator request (like a console) and can be refused by the filter   *
F *                task.                                                                *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author        date        comments                                                *
F *                                                                                     *
F *   Mazzocco      25-11-13    Function creation                                       *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iiExecMode          INT                                             *
F *                     Command execution modality: MODE_NOWAIT, MODE_WAIT              *
F *                                                                                     *
F *                 iiProc              INT                                             *
F *                     Process number 1..24                                            *
F *                                                                                     *
F *                 iOpConsole          BOOL                                            *
F *                     Console flag, the request is comparable to an operator console, *
F *                     can be rfeused by filter task                                   *
F *                                                                                     *
F * Return       :  DWORD                                                               *
F *                     CycleStart function block return code                           *
F *                                                                                     *
F * Global used  :  gPlcConCON        array [0..ciMaxProc] of bool                             *
F *                     Cycle start request from Plc console ambient memory             *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* CycleStart request from PLC, works like the system function block with two more possibility:
	the request can be applyed to all processes, have one more flag to decide if the request
	is comparable to an operator request (like a console) and can be refused by the filter task. */

llRetCode	:= F_CycleStart(
	iiExecMode,		\* IN	INT		Command execution modality: MODE_NOWAIT, MODE_WAIT */
	iiProc,			\* IN	INT		Process number 1..24 or -1 (ciProcAll) to request to all processes */
	iOpConsole);	\* IN	BOOL	Console flag, the request is comparable to an operator console, can be rfeused by filter task */

\* Example to apply the request only at the selected process with the filter enabled */
llRetCode	:= F_CycleStart(MODE_NOWAIT, SI_PROCSEL, true \*iOpConsole*/);
*)


	#IMPORT  "GvU_Variable.gvl"
	#IMPORT  "Gv_AllProcess.gvl"

VAR_INPUT
	iiExecMode	: int;	(* Command execution modality: MODE_NOWAIT, MODE_WAIT *)
	iiProc		: int;	(* Process number 1..24 or -1 (ciProcAll) to request to all processes *)
	iOpConsole	: bool;	(* Console flag, the request is comparable to an operator console, can be rfeused by filter task *)
END_VAR

VAR
	llExecStatus	: dword;	(* Function block execution status, not used *)
END_VAR;


(* Request for a single process *)
gPlcConCON[iiProc]	:= iOpConsole;	(* Plc console ambient memory *)
F_CycleStart	:= CycleStart(iiExecMode, llExecStatus, iiProc);
if F_CycleStart<>0 then
	gPlcConCON[iiProc]	:= false;	(* In case of error reset the Plc console ambient memory *)
end_if;

END_FUNCTION
