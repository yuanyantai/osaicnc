(*[[
    UserText1= "V15.7",
]]*)
FUNCTION_BLOCK Fb_AuxSpindle

	#IMPORT  "Gv_AllProcess.gvl"
	#IMPORT  "Gv_Functionblock.gvl"

(*
F ***************************************************************************************
F * File name    : Fb_AuxSpindle.st                                                     *
F * Description  : PLC single digital spindle handling 									*
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author       date      comments                                                   *
F *                                                                                     *
F *   Scapolan     24-10-16  Creation                                                   *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iFbEnable           BOOL                                            *
F *                     Function block enable                                           *
F *                                                                                     *
F *                 iReset              BOOL                                            *
F *                     Reset error request                                             *
F *                                                                                     *
F *                                                                                     *
F *                 iiOverPerc          INT                                             *
F *                     Feed override percent                                           *
F *                                                                                     *
F *                 iiAxisID            INT                                             *
F *                     Auxiliary axis identifier                                       *
F *                                                                                     *
F *                 iiProc              INT                                             *
F *                     Process number                                                  *
F *                                                                                     *
F *                 iw_Tasksts			word				                            *
F *                     PLC inerpolator status			                                *
F *                                                                                     *
F *                 iiInterpID          INT                                             *
F *                     Interpolator number                                             *
F *                                                                                     *
F *                                                                                     *
F * Input/Output :  ioReqMove           BOOL                                            *
F *                     Movement request                                                *
F *                                                                                     *
F *                 iodPosition         LREAL                                           *
F *                     Requested position                                              *
F *                                                                                     *
F *                 ioiAck              INT                                             *
F *                     Event task need acknowledge:                                    *
F *                         1 M function at movement end,                               *
F *                         2 M function starting movement,                             *
F *                         3 Pseudo axes at movement end.                              *
F *                         4 Pseudo axes starting movement,                            *
F *                                                                                     *
F * Output       :  oEndSignal          BOOL                                            *
F *                     Movement completed                                              *
F *                                                                                     *
F *                 oMoving             BOOL                                            *
F *                     Auxiliary axis is moving                                        *
F *                                                                                     *
F *                 oHoming             BOOL                                            *
F *                     Auxiliary axis is homing                                        *
F *                                                                                     *
F *                 gSt_AxisInfo[iiAxisID].        AxisInfo_Struct                                 *
F *                     Axis info structure                                             *
F *                                                                                     *
F *                 oiPhase             INT                                             *
F *                     Movement sequential cycle phase number                          *
F *                                                                                     *
F *                 olRetCode           DWORD                                           *
F *                     Function block return code                                      *
F *                                                                                     *
F * Global used  :      Not used                                                        *
F *                                                                                     *
F * Attention    :  Use this FB directly in the logic program, don't inside a cycle     *
F *                 (IF, FOR, etc.), is the same for all the macro function block with  *
F *                 the iFbEnable input.                                                *
F *                                                                                     *
F ***************************************************************************************
*)

(* Example for program use
VAR
	Fb_1AuxAxis	:Fb_AuxAxis;	\* PLC single axis handling */
END_VAR

\* PLC single axis handling */
Fb_1AuxAxis(
	iFbEnable		:= M_EnabDone,		\* IN	BOOL	Function block enable */
	iReset			:= M_Reset?,		\* IN	BOOL	Reset error request */
	iiOverPerc		:= SI_?Rap,			\* IN	INT		Feed override percent */
	iiAxisID		:= GI_Id_?,			\* IN	INT		Auxiliary axis identifier */
	iw_Tasksts		:= gSt_InterpInfo[MI_InterpId_?].TaskSts,	\* IN  InterpInfo_Struct	PLC inerpolator info structure */
	iiInterpID		:= MI_InterpId_?,	\* IN	INT		Interpolator number */

	oEndSignal		=> ,					\* OUT	BOOL	Movement completed */
	oMoving			=> M_AxesMovC[GI_Id_?],	\* OUT	BOOL	Auxiliary axis is moving */
	oHoming			=> M_Home_?,			\* OUT	BOOL	Auxiliary axis is homing */
	oiPhase			=> ,					\* OUT	INT		Movement sequential cycle phase number */
	olRetCode		=> llRetCode?);			\* OUT	DWORD	Function block return code *)



VAR_INPUT
	iFbEnable		: bool;	(* Function block enable *)
	iReset			: bool;	(* Function block reset error request *)
	iiOverPerc		: int;	(* Feed override percent *)
	iiAxisID		: int;	(* Auxiliary axis identifier *)
	ii_proc			: int;	(* Auxiliary axis identifier *)
	iw_TaskSts		: word; (* PLC inerpolator status *)
	iiInterpID		: int;	(* Interpolator number *)
END_VAR


VAR_OUTPUT
	oMoving			: bool;	(* Auxiliary axis is moving *)
	olRetCode		: dword;	(* Return code of the function block *)
END_VAR

VAR
	ll_RetCode		: dword;
	llExecStatus	: dword;	(* Function block execution status not used *)
	liMemOver		: array [0..MAX_ASSI] of int;	(* Feed override memory *)

	li_Phase		: int;
	li_Phases		: array [0..MAX_ASSI] of int;
	l_enabrun		: array [0..MAX_ASSI] of bool;
	l_EndSignal		: array [0..MAX_ASSI] of bool;
	l_init			: bool := 1;
END_VAR


if iFbEnable or iReset then

	oMoving	:= true; 

	(* Set override *)
	if (iiOverPerc <> liMemOver[iiAxisID]) or l_init then
		l_init := false;
		liMemOver[iiAxisID] := iiOverPerc;
		ll_RetCode := GMC_SetFeedOverride(MODE_NOWAIT, llExecStatus, iiInterpID, iiAxisID, liMemOver[iiAxisID]);
	end_if;

	li_Phase := li_Phases[iiAxisID];
	case li_Phase of

		0:
			(* Only if the axis spindle is released from process we can move it *)
			if iReset then
				if l_enabrun[iiAxisID] then
					Fb_Enab_One_Axis(iFbEnable := False, ii_AxId := iiAxisID,ii_proc := ii_proc);
					l_enabrun[iiAxisID] := false;
				end_if;
				li_Phase := li_Phase + 1;
				oMoving	:= false; 

			elsif gSt_AxisInfo[iiAxisID].SharingProc <> 0 and iFbEnable then

				if not M_AxisEnabDisab[iiAxisID] or l_enabrun[iiAxisID] then
					Fb_Enab_One_Axis(iFbEnable := true, ii_AxId := iiAxisID, ii_proc := ii_proc );
					l_enabrun[iiAxisID] := true;
					if Fb_Enab_One_Axis.oDone then
						Fb_Enab_One_Axis(iFbEnable := False, ii_AxId := iiAxisID, ii_proc := ii_proc );
						l_enabrun[iiAxisID] := false;
					end_if;
				end_if;
				if not l_enabrun[iiAxisID] and iw_TaskSts = INT_ST_IDLE then
					ll_RetCode	:=  GMC_MoveJog(MODE_NOWAIT, llExecStatus, iiInterpID, l_EndSignal[iiAxisID], MAN_HWLIMSTOP, iiAxisID);
					li_Phase := li_Phase + 1;
				end_if;

			else
				oMoving	:= false;
			end_if;

	
		1:
			if iReset then
				if iw_TaskSts = INT_ST_IDLE or iw_TaskSts = INT_ST_ERR or iw_TaskSts = INT_ST_EMG or iw_TaskSts = INT_ST_HOLD then
					if M_AxisEnabDisab[iiAxisID] or l_enabrun[iiAxisID] then
						Fb_Disable_One_Axis(iFbEnable := true, ii_AxId := iiAxisID, ii_proc := ii_proc);
						l_enabrun[iiAxisID] := true;
						if Fb_Disable_One_Axis.oDone then
							Fb_Disable_One_Axis(iFbEnable := false, ii_AxId := iiAxisID, ii_proc := ii_proc);
							l_enabrun[iiAxisID] := false;
							li_Phase := 0;
							oMoving := false;
						end_if;
					end_if;
				end_if;
			else
				li_Phase := 0;
				oMoving := false;
			end_if;
	end_case;
	
	li_Phases[iiAxisID] := li_Phase;
end_if;

(* reset management *)


END_FUNCTION_BLOCK
