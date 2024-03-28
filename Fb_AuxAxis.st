(*[[
    UserText1= "V15.7",
]]*)
FUNCTION_BLOCK Fb_AuxAxis
	#IMPORT  "Gv_AllProcess.gvl"
(*
F ***************************************************************************************
F * File name    : Fb_AuxAxis.st                                                        *
F * Description  : PLC single axis handling, tipically a rollover rotary tool magazine  *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author       date      comments                                                   *
F *                                                                                     *
F *   Mazzocco     17-03-10  Creation Fb_AuxAxis                                        *
F *   Mazzocco     06-10-10  Add sequential cycle phase number in output for diagnostic *
F *   Mazzocco     22-06-11  Add feed-hold management.                                  *
F *   Mazzocco     09-09-11  Add moving property specification, change requested        *
F *                          position variable type from input to input/output,         *
F *                          modified override scale to adapt at new release 2.1        *
F *                          (100%=10000 and not 100), remove included interpolator     *
F *                          management                                                 *
F *   Paglia L.	   13-10-11  Added Input "iiValFeed" for "Work" type movement           *
F *   Mazzocco     26-04-12  Optimized property and override management.                *
F *   Scapolan     08-03-18  Optimized use of gst_axisinfo                              *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iFbEnable           BOOL                                            *
F *                     Function block enable                                           *
F *                                                                                     *
F *                 iReset              BOOL                                            *
F *                     Reset error request                                             *
F *                                                                                     *
F *                 ibProperty          BYTE                                            *
F *                     Axis movement property definition: bit 0 MODE_INCR incremental, *
F *                     bit 1 MODE_ROLLOPT rollover optimized, bit 2 MODE_NOFEED don't  *
F *                     considerate in feed calculation                                 *
F *                                                                                     *
F *                 iiTypeFeed          INT                                             *
F *                     Feed type: 0 MODE_RAPID, 1 MODE_WORK, 2 MODE_FEED_t,            *
F *                     3 MODE_FEED_1T                                                  *
F *                                                                                     *
F *                 idValue             LREAL                                           *
F *                     Feed Value: units pe minut. Only for working movement           *
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
F *                 iSt_InterpInfo      InterpInfo_Struct                               *
F *                     PLC inerpolator info structure                                  *
F *                                                                                     *
F *                 iiInterpID          INT                                             *
F *                     Interpolator number                                             *
F *                                                                                     *
F *                 iForceHome          BOOL                                            *
F *                     Homing cycle forced at every movement                           *
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
F *                 oSt_AxisInfo        AxisInfo_Struct                                 *
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
	ibProperty		:= MODE_?,			\* IN	BYTE	Axis movement property definition: bit 0 MODE_INCR incremental, bit 1 MODE_ROLLOPT rollover optimized, bit 2 MODE_NOFEED don't considerate in feed calculation */
	iiTypeFeed		:= MODE_?,			\* IN	INT		Feed type: 0 MODE_RAPID, 1 MODE_WORK, 2 MODE_FEED_t, 3 MODE_FEED_1T */
	idValue			:= 0.0,				\* IN	LREAL	Feed value for working movement */
	iiOverPerc		:= SI_?Rap,			\* IN	INT		Feed override percent */
	iiAxisID		:= GI_Id_?,			\* IN	INT		Auxiliary axis identifier */
	iiProc			:= ciProc_?,		\* IN	INT		Process number */
	iSt_InterpInfo  := gSt_InterpInfo[MI_InterpId_?],	\* IN  InterpInfo_Struct	PLC inerpolator info structure */
	iiInterpID		:= MI_InterpId_?,	\* IN	INT		Interpolator number */
	iForceHome		:= gSt_PlcCfg.Ah_Aux_Home,			\* IN	BOOL	Homing cycle forced at every movement */

	ioReqMove		:= M_Req_Mov_?,		\* I/O	BOOL	Movement request */
	iodPosition		:= MD_ReqPos_?,		\* I/O	LREAL	Requested position */
	ioiAck			:= MI_Ack_Mov_?,	\* I/O	INT		Event task need acknowledge: 1 M function at movement end, 2 M function starting movement, 3 Pseudo axes at movement end, 4 Pseudo axes starting movement */

	oEndSignal		=> ,					\* OUT	BOOL	Movement completed */
	oMoving			=> M_AxesMovC[GI_Id_?],	\* OUT	BOOL	Auxiliary axis is moving */
	oHoming			=> M_Home_?,			\* OUT	BOOL	Auxiliary axis is homing */
	oSt_AxisInfo	=> gSt_AxisInfo[GI_Id_?],			\* OUT	AxisInfo_Struct		Axis info structure */
	oiPhase			=> ,					\* OUT	INT		Movement sequential cycle phase number */
	olRetCode		=> llRetCode?);			\* OUT	DWORD	Function block return code *)



VAR_INPUT
	iFbEnable		: bool;		(* Function block enable *)
	iReset			: bool;		(* Function block reset error request *)
	ibProperty		: byte;		(* Axis movement property definition: bit 0 MODE_INCR incremental, bit 1 MODE_ROLLOPT rollover optimized, bit 2 MODE_NOFEED don't considerate in feed calculation *)
	iiTypeFeed		: int;		(* Feed type: 0 MODE_RAPID, 1 MODE_WORK, 2 MODE_FEED_t, 3 MODE_FEED_1T *)
	idValue			: lreal;	(* Feed value *)
	iiOverPerc		: int;		(* Feed override percent *)
	iiAxisID		: int;		(* Auxiliary axis identifier *)
	iiProc			: int;		(* Process number *)
	iSt_InterpInfo  : InterpInfo_Struct;		(* PLC inerpolator info structure *)
	iiInterpID		: int;		(* Interpolator number *)
	iForceHome		: bool;		(* Homing cycle forced at every movement *)
END_VAR

VAR_IN_OUT
	ioReqMove		: bool;		(* Movement request *)
	iodPosition		: lreal;	(* Requested position *)
	ioiAck			: int;		(* Event task need acknowledge: 1 M function at movement end, 2 M function starting movement, 3 Pseudo axes at movement end, 4 Pseudo axes starting movement *)
END_VAR

VAR_OUTPUT
	oEndSignal		: bool;		(* Movement completed *)
	oMoving			: bool;		(* Auxiliary axis is moving *)
	oHoming			: bool;		(* Auxiliary axis is homing *)
	oSt_AxisInfo	: AxisInfo_Struct;		(* axis info structure *)
	oiPhase			: int;		(* Movement sequential cycle phase number *)
	olRetCode		: dword;	(* Return code of the function block *)
END_VAR

VAR
	llRetCodeSAP	: dword;	(* Set axis property function block return code *)
	llRetCodeSFO	: dword;	(* Set feed override function block return code *)
	llRetCodeGM 	: dword;	(* Move function block return code *)
	llRetCodeACK	: dword;	(* Acknowledge strobe function block return code *)
	llExecStatus	: dword;	(* Function block execution status not used *)
	lbMemProp		: BYTE;		(* Axis movement property memory *)
	lbActProp		: BYTE;		(* Axis movement active property *)
	lErrSAP			: BOOL	:= true;	(* Error in setting axis poperty , to generate a refresh request *)
	lErrSFO			: BOOL	:= true;	(* Error in setting axis override, to generate a refresh request *)
	liMemOver		: int;		(* Feed override memory *)
	lAckM			: bool;		(* M function event task need acknowledge at the end of the movement *)
	lAckP			: bool;		(* Pseudo axes event task need acknowledge at the end of the movement *)
	ldPosition		: lreal;	(* Requested position memory *)
	lEndHome		: bool;		(* Homing movement completed *)
	liInterpId		: int;		(* Interpolator number memory *)
	liAxisId		: int;		(* Axis identifier number memory *)

	lSt_Feed		:FeedDescr_Struct;
	(*	TypeFeed	: int;	- Feed type					-
		Value		:lreal;	- Feed value				-
		Accel		:lreal;	- Target acceleration != 0	-
		Decel		:lreal;	- Target deceleration != 0	-
		Jerk		:lreal;	- Target jerk != 0			-
		VelOnlyLin	: bool;	- Vel for linear axes only	-	*)
END_VAR



(* Interpolator reset completed, delete movement flag *)
if iSt_InterpInfo.TaskSts = INT_ST_IDLE or iSt_InterpInfo.TaskSts = INT_ST_ERR or
iSt_InterpInfo.TaskSts = INT_ST_EMG then
	oMoving	:= false;	(* Auxiliary axis is moving *)
	oHoming	:= false;	(* Auxiliary axis is homing *)
end_if;



if iFbEnable then

	(* Refresh axis info *)
	oSt_AxisInfo := Gst_AxisInfo[iiAxisId];
	
	if iiInterpID>0 and iiInterpID<41 and iiAxisId>0 and iiAxisId<65 and olRetCode=0 then

		(* Check axes and interpolator number value *)
		if liInterpId<>iiInterpID or liAxisId<>iiAxisId then
			liInterpID	:= iiInterpID;
			liAxisId	:= iiAxisId;
			lErrSap	:= true;
			lErrSfo	:= true;
		end_if;


		if oiPhase<>0 then
			(* Set axis property *)
			if llRetCodeSAP=0 and (ibProperty<>lbMemProp or lErrSAP) then
				if iSt_InterpInfo.TaskSts = INT_ST_IDLE and not iReset then
					lbMemProp := ibProperty;
	
					if (oSt_AxisInfo.AxType and _AX_ROLLOVER)<>0 then
						lbActProp := lbMemProp;
						llRetCodeSAP := GMC_SetAxisProperty(MODE_NOWAIT, llExecStatus, iiInterpID, lbActProp, iiAxisId);
					else
						(* Delete the rollover optimized bit for not rollover axis *)
						lbActProp	:= lbMemProp and 16#00FD;
						llRetCodeSAP	:= GMC_SetAxisProperty(MODE_NOWAIT, llExecStatus, iiInterpID,
							lbActProp, iiAxisId);
					end_if;
	
					lErrSAP	:= llRetCodeSAP<>0;	(* Refresh request in case of error *)
				end_if;
			end_if;


			(* Set override *)
			if llRetCodeSFO=0 and (iiOverPerc<>liMemOver or lErrSFO) then
				liMemOver		:= iiOverPerc;
				llRetCodeSFO	:= GMC_SetFeedOverride(MODE_NOWAIT, llExecStatus, iiInterpID,
					iiAxisId, liMemOver);
	
				lErrSFO	:= llRetCodeSFO<>0;	(* Refresh request in case of error *)
			end_if;
		end_if;
	
	
	
		(* Movement phase *)
		if llRetCodeGM=0 and iSt_InterpInfo.TaskSts = INT_ST_IDLE and (oiPhase=0 or (lbMemProp=ibProperty and
			oSt_AxisInfo.ProgrMode=lbActProp and iiOverPerc=liMemOver and oSt_AxisInfo.Override=INT_TO_WORD(iiOverPerc) and
			not lErrSap and not lErrSfo)) and
			(oSt_AxisInfo.AxisHwSts and _ZEROASS)=0 and liInterpId=iiInterpID and liAxisId=iiAxisId then
	
			case oiPhase of
	
				00:	(* Wait movement request *)
					if ioReqMove then
						oEndSignal	:= false;	(* Reset end movement flag *)
						ioReqMove	:= false;	(* Reset movement request *)
						ldPosition	:= iodPosition;	(* Store requested position *)
						liMemOver	:= -1;	(* Update override *)
	
						(* Reset acknowledge request memory *)
						lAckM	:= false;
						lAckP	:= false;
						
						case ioiAck of
							01:	(* M function event task need acknowledge at the end of the movement *)
								lAckM	:= true;
	
							02:	(* M function event task need acknowledge at the beginning of the movement *)
								ioiAck			:= 0;
						        llRetCodeACK	:= AckStrobePProgram(iiProc, f_M_FUNCTION, Ack);
	
							03:	(* Pseudo axes event task need acknowledge at the end of the movement *)
								lAckP	:= true;
	
							04:	(* Pseudo axes event task need acknowledge at the beginning of the movement *)
								ioiAck			:= 0;
						        llRetCodeACK	:= AckStrobePProgram(iiProc, f_PSEUDO_AX_FUNCTION, Ack);
						end_case;
	
						ioiAck	:= 0;	(* Reset acknowledge request in any case *)
	
						(* Check axis referred *)
						if (oSt_AxisInfo.AxisHwSts and _HC_DONE)=0 or iForceHome then
							oHoming	:= true;
							oiPhase	:= 1;
						else
							lSt_Feed.TypeFeed	:= iiTypeFeed;
							lSt_Feed.Value	:= idValue;
		
							llRetCodeGM	:= GMC_Move(MODE_NOWAIT, llExecStatus, iiInterpID, oEndSignal,
								lSt_Feed, iiAxisId, ldPosition);
	
							oMoving	:= true;	(* Auxiliary axis is moving *)
							oiPhase	:= 4;	(* Auxiliary axis is homing *)
						end_if;
					end_if;
	
	
				01: (* Homing request *)
					lEndHome	:= false;
					llRetCodeGM	:= GMC_Homing(MODE_NOWAIT, llExecStatus, iiInterpID, lEndHome, iiAxisId);
					oMoving	:= true;	(* Auxiliary axis is moving *)
					oiPhase	:= oiPhase + 1;
	
	
				02:	(* Wait homing movement completed *)
					if lEndHome then
						oMoving	:= false;	(* Auxiliary axis is moving *)
						oHoming	:= false;	(* Auxiliary axis is homing *)
						oiPhase	:= oiPhase + 1;
					end_if;
	
				03:	(* Movement request *)
					if (oSt_AxisInfo.AxisHwSts and _HC_DONE) <> 0 then
						lSt_Feed.TypeFeed := iiTypeFeed;
						lSt_Feed.Value := idValue;
	
						llRetCodeGM	:= GMC_Move(MODE_NOWAIT, llExecStatus, iiInterpID, oEndSignal, lSt_Feed, iiAxisId, ldPosition);

						oMoving	:= true;	(* Auxiliary axis is moving *)
						oiPhase	:= oiPhase + 1;
					end_if;
	
	
				04:	(* Wait movement completed *)
					if oEndSignal then
						if lAckM then	(* Release M function event task *)
							lAckM			:= false;
					        llRetCodeACK	:= AckStrobePProgram(iiProc, f_M_FUNCTION, Ack);
						end_if;
	
						if lAckP then	(* Release pseudo axes event task *)
							lAckP			:= false;
					        llRetCodeACK	:= AckStrobePProgram(iiProc, f_PSEUDO_AX_FUNCTION, Ack);
						end_if;
	
						oMoving	:= false;	(* Auxiliary axis is moving *)
						oiPhase	:= 0;
					end_if;
	
			end_case;
	
		end_if;
	
	end_if;
	
	
	
	(* return code management *)
	if olRetCode=0 then
		if llRetCodeSAP<>0 then
			olRetCode	:= llRetCodeSAP;
		elsif llRetCodeSFO<>0 then
			olRetCode	:= llRetCodeSFO;
		elsif llRetCodeGM<>0 then
			olRetCode	:= llRetCodeGM;
		elsif llRetCodeACK<>0 then
			olRetCode	:= llRetCodeACK;
		end_if;
	end_if;

end_if;



(* reset management *)
if iReset then
	llRetCodeSAP	:= 0;
	llRetCodeSFO	:= 0;
	llRetCodeGM		:= 0;
	llRetCodeACK	:= 0;
	olRetCode		:= 0;
	oEndSignal		:= false;	(* Reset end movement flag *)
	ioReqMove		:= false;	(* Reset movement request *)
	ioiAck			:= 0;
	oiPhase			:= 0;
	lbMemProp		:= 0;
end_if;


END_FUNCTION_BLOCK
