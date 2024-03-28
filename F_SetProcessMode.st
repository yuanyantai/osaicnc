(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_SetProcessMode
(*
F ***************************************************************************************
F * File name    : F_SetProcessMode.st                                                  *
F * Description  : Set Process Mode request from PLC, works like the system function    *
F *                block with two more possibility: the request can be applyed to all   *
F *                processes, have one more flag to decide if the request is comparable *
F *                to an operator request (like a console) and can be refused by the    *
F *                filter task.                                                         *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author        date        comments                                                *
F *                                                                                     *
F *   Scapolan      08-02-17    Function creation                                       *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  ii_Proc              INT                                            *
F *                     Process number 1..24 	 										*
F *                 iiProcessMode       INT                                             *
F *                     Requested process mode                                          *
F *                                                                                     *
F *                 iOpConsole          BOOL                                            *
F *                     Console flag, the request is comparable to an operator console, *
F *                     can be rfeused by filter task                                   *
F *                                                                                     *
F * Global used  :  gPlcConSPM          array [0..ciMaxProc] of bool                    *
F *                     Set Process Mode request from Plc console ambient memory        *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* Set Process Mode request from PLC, works like the system function block with two more possibility:
	the request can be applyed to all processes, have one more flag to decide if the request
	is comparable to an operator request (like a console) and can be refused by the filter task. */

llRetCode	:= F_SetProcessMode(
	iiProc,			\* IN	INT		Process number 1..24 or -1 (ciProcAll) to request to all processes */
	iiProcessMode,	\* IN	INT		Requested process mode */
	iOpConsole);	\* IN	BOOL	Console flag, the request is comparable to an operator console, can be rfeused by filter task */

\* Example to apply the request only at the selected process */
llRetCode	:= F_SetProcessMode(ii_proc, liSelMode, false \*iOpConsole*/);

\* Example to apply the request at all the process selected in the station */
llRetCode	:= F_SetProcessMode(ii_proc, liSelMode, false \*iOpConsole*/);
*)


	#IMPORT  "GvU_Variable.gvl"
	#IMPORT  "Gv_Allprocess.gvl"

VAR_INPUT
	ii_Proc			: int;	(* Process number 1..24 or -1 (ciProcAll) to request to all processes *)
	ii_ProcessMode	: int;	(* Requested process mode *)
	i_OpConsole		: bool;	(* Console flag, the request is comparable to an operator console, can be rfeused by filter task *)
END_VAR

VAR
	ll_ExecStatus	: dword;	(* Function block execution status, not used *)
	ll_RetCode		: dword;
END_VAR;

gPlcConSPM[ii_Proc]	:= i_OpConsole;	(* Plc console ambient memory *)
ll_RetCode	:= SetProcessMode(MODE_NOWAIT, ll_ExecStatus, ii_Proc, ii_ProcessMode);

END_FUNCTION
