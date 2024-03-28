(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_HoldOFF : DWORD
(*
F ***************************************************************************************
F * File name    : F_HoldOFF.st                                                         *
F * Description  : Hold OFF request from PLC, works like the system function block with *
F *                two more possibility: the request can be applyed to all processes,   *
F *                have one more flag to decide if the request is comparable to an      *
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
F *   Scapolan      06-07-16    Function creation                                       *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iiProc              INT                                             *
F *                     Process number 1..24 or -1 (ciProcAll) to request to all        *
F *                     processes.                                                      *
F *                                                                                     *
F *                 iOpConsole          BOOL                                            *
F *                     Console flag, the request is comparable to an operator console, *
F *                     can be rfeused by filter task                                   *
F *                                                                                     *
F * Return       :  DWORD                                                               *
F *                     HoldOFF function block return code                              *
F *                                                                                     *
F * Global used  :  gPlcConHOF          array [0..ciMaxProc] of bool                    *
F *                     HoldOFF request from Plc console ambient memory                 *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* Hold OFF request from PLC, works like the system function block with two more possibility:
	the request can be applyed to all processes, have one more flag to decide if the request
	is comparable to an operator request (like a console) and can be refused by the filter task. */

llRetCode	:= F_HoldOFF(
	iiProc,			\* IN	INT		Process number 1..24 or -1 (ciProcAll) to request to all processes */
	iOpConsole);	\* IN	BOOL	Console flag, the request is comparable to an operator console, can be rfeused by filter task */

\* Example to apply the request to every existing process, with the filter enabled */
llRetCode	:= F_HoldOFF(ciProc, true \*iOpConsole*/);
*)


	#IMPORT  "GvU_Variable.gvl"
	#IMPORT  "Gv_Allprocess.gvl"

VAR_INPUT
	iiProc		: int;	(* Process number 1..24 or -1 (ciProcAll) to request to all processes *)
	iOpConsole	: bool;	(* Console flag, the request is comparable to an operator console, can be rfeused by filter task *)
END_VAR

VAR
	llExecStatus	: dword;	(* Function block execution status, not used *)
END_VAR;


gPlcConHOF[iiProc]	:= iOpConsole;	(* Plc console ambient memory *)
F_HoldOFF	:= HoldOFF(MODE_NOWAIT, llExecStatus, iiProc);

END_FUNCTION
