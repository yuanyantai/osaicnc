(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_SetIncJog : DWORD
(*
F ***************************************************************************************
F * File name    : F_SetIncJog.st                                                       *
F * Description  : Set Incremental Jog request from PLC, works like the system function *
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
F *   Scapolan      08-02-2017  Function creation                                       *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iiProc              INT                                             *
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
F *                 idIncLogValue       LREAL                                           *
F *                     New incremental jog value                                       *
F *                                                                                     *
F *                 iOpConsole          BOOL                                            *
F *                     Console flag, the request is comparable to an operator console, *
F *                     can be rfeused by filter task                                   *
F *                                                                                     *
F * Return       :  DWORD                                                               *
F *                     Set Incremental Jog function block return code                  *
F *                                                                                     *
F * Global used  :  gPlcConIJog         array [0..ciMaxProc] of bool                    *
F *                     Set Incremental Jog request from Plc console ambient memory     *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* Set Incremental Jog request from PLC, works like the system function block with two more possibility:
	the request can be applyed to all processes, have one more flag to decide if the request
	is comparable to an operator request (like a console) and can be refused by the filter task. */

llRetCode	:= F_SetIncJog(
	iiProc,			\* IN	INT		Process number 1..24 or -1 (ciProcAll) to request to all processes */
	iiLastProc,		\* IN	INT		Last process number, used only if the request is for all processes */
	iiNoProc,		\* IN	INT		Process number to skip if the request is for all processes, 0 to apply to every processes */
	idIncLogValue,	\* IN	LREAL	New incremental jog value */
	iOpConsole);	\* IN	BOOL	Console flag, the request is comparable to an operator console, can be rfeused by filter task */

\* Example to apply the request only at the selected process with the filter enabled, the 2nd and 3rd input data are not used */
llRetCode	:= F_SetIncJog(SI_PROCSEL, MI_LastProc, 0 \*iiNoProc*/, ldNewIncJog, true \*iOpConsole*/);

\* Example to apply the request to every existing process with the filter enabled */
llRetCode	:= F_SetIncJog(ciProcAll, MI_LastProc, 0 \*iiNoProc*/, ldNewIncJog, true \*iOpConsole*/);

\* Example to apply the request to every existing process, except the process number 1, with the filter enabled */
llRetCode	:= F_SetIncJog(ciProcAll, MI_LastProc, 1 \*iiNoProc*/, ldNewIncJog, true \*iOpConsole*/);
*)


	#IMPORT  "GvU_Variable.gvl"
	#IMPORT  "Gv_Allprocess.gvl"

VAR_INPUT
	iiProc			: int;	(* Process number 1..24 or -1 (ciProcAll) to request to all processes *)
	idIncLogValue	:lreal;	(* New incremental jog value *)
	iOpConsole		: bool;	(* Console flag, the request is comparable to an operator console, can be rfeused by filter task *)
END_VAR

VAR
END_VAR;


gPlcConIJog[iiProc]	:= iOpConsole;	(* Plc console ambient memory *)
F_SetIncJog	:= VAR_Write(iiProc, 0 (*Index*), 0 (*NumChar*), 'JOG', idIncLogValue);

END_FUNCTION
