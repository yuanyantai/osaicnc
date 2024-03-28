(*[[
    UserText1= "V15.7",
]]*)
(*
F *******************************************************************************************
F * File name	: F_Gestop_Close.st															*
F * Description	: request the EMERGENCYSTOPCLOSE and set to one the configured fast output	*
F *******************************************************************************************
F * Product line : OpenControl                                                          	*
F * Enviroment   : PLC Application                                                      	*
F * Component    :                                                                      	*
F * ----------------------------------------------------------------------------------------*
F *   Author        date        comments                                                	*
F *   Scapolan      19-05-16    Function creation                                       	*
F * ----------------------------------------------------------------------------------------*
F * Input        :	none																	*
F *******************************************************************************************
*)

FUNCTION F_Gestop_Close

	#IMPORT  "Gv_AllProcess.gvl"
	#IMPORT  "Gv_InputOutput.gvl"

var
	li_FastOutStatus	: word;
	ll_RetCode			: dword;
end_var

(* Close the emergency contact - fast output 1 *)
ll_Retcode := EmergencyStopClose(0);

if (gSt_PlcCfg.Second_Estop_Signal <> 0) then
	if (gSt_PlcCfg.Second_Estop_Signal > 0) and (gSt_PlcCfg.Second_Estop_Signal < 4) then
		li_FastOutStatus := SHL(1, gSt_PlcCfg.Second_Estop_Signal-1);
		ll_RetCode	:= FastOutputWrite(li_FastOutStatus, li_FastOutStatus);
	end_if;
end_if;

O_AuxGestop := 1;
M_SpepnOpen	:= false;

END_FUNCTION
