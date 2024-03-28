(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_CycleStop : DWORD
(*
F ***************************************************************************************
F * File name    : F_CycleStop.st                                                       *
F * Description  : Cycle stop request from PLC, works like the system function block    *
F *                with two more possibility: the request can be applyed to all         *
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
F *   Mazzocco      25-11-13    Function creation                                       *
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
F *                 iOpConsole          BOOL                                            *
F *                     Console flag, the request is comparable to an operator console, *
F *                     can be rfeused by filter task                                   *
F *                                                                                     *
F * Return       :  DWORD                                                               *
F *                     CycleStop function block return code                            *
F *                                                                                     *
F * Global used  :  gPlcConCOF          array [0..ciMaxProc] of bool                    *
F *                     Cycle Stop request from Plc console ambient memory              *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* Cycle stop request from PLC, works like the system function block with two more possibility:
	the request can be applyed to all processes, have one more flag to decide if the request
	is comparable to an operator request (like a console) and can be refused by the filter task. */

llRetCode	:= F_CycleStop(
	iiExecMode,		\* IN	INT		Command execution modality: MODE_NOWAIT, MODE_WAIT */
	iiProc,			\* IN	INT		Process number 1..24 or -1 (ciProcAll) to request to all processes */
	iiLastProc,		\* IN	INT		Last process number, used only if the request is for all processes */
	iiNoProc,		\* IN	INT		Process number to skip if the request is for all processes, 0 to apply to every processes */
	iOpConsole);	\* IN	BOOL	Console flag, the request is comparable to an operator console, can be rfeused by filter task */

\* Example to apply the request only at the selected process with the filter enabled, the 3rd and 4th input data are not used */
llRetCode	:= F_CycleStop(MODE_NOWAIT, SI_PROCSEL, MI_LastProc, 0 \*iiNoProc*/, true \*iOpConsole*/);

\* Example to apply the request to every existing process with the filter enabled */
llRetCode	:= F_CycleStop(MODE_NOWAIT, ciProcAll, MI_LastProc, 0 \*iiNoProc*/, true \*iOpConsole*/);

\* Example to apply the request to every existing process, except the process number 1, with the filter enabled */
llRetCode	:= F_CycleStop(MODE_NOWAIT, ciProcAll, MI_LastProc, 1 \*iiNoProc*/, true \*iOpConsole*/);
*)


	#IMPORT  "GvU_Variable.gvl"
	#IMPORT  "Gv_Allprocess.gvl"

VAR_INPUT
	iiExecMode	: int;	(* Command execution modality: MODE_NOWAIT, MODE_WAIT *)
	iiProc		: int;	(* Process number 1..24 or -1 (ciProcAll) to request to all processes *)
	iiLastProc	: int;	(* Last process number, used only if the request is for all processes *)
	iiNoProc	: int;	(* Process number to skip, used only if the request is for all processes, 0 to apply to every processes *)
	iOpConsole	: bool;	(* Console flag, the request is comparable to an operator console, can be rfeused by filter task *)
END_VAR

VAR
	llExecStatus	: dword;	(* Function block execution status, not used *)
	liInd			: int;	(* Array index scroll *)
END_VAR;


if iiProc=-1 then	(* Request for all processes *)
	if iiLastProc<1 then
		F_CycleStop	:= 16#00170005;
	end_if;

	for liInd :=1 to iiLastProc by 1 do
		if liInd<>iiNoProc then
			gPlcConCOF[liInd]	:= iOpConsole;	(* Plc console ambient memory *)
			F_CycleStop	:= CycleStop(iiExecMode, llExecStatus, liInd);
			if F_CycleStop<>0 then
				gPlcConCOF[liInd]	:= false;	(* In case of error reset the Plc console ambient memory *)
				exit;
			end_if;
		end_if;
	end_for;
else				(* Request for a single process *)
	gPlcConCOF[iiProc]	:= iOpConsole;	(* Plc console ambient memory *)
	F_CycleStop	:= CycleStop(iiExecMode, llExecStatus, iiProc);
	if F_CycleStop<>0 then
		gPlcConCOF[iiProc]	:= false;	(* In case of error reset the Plc console ambient memory *)
	end_if;
end_if;

END_FUNCTION
