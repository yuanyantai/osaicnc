(*[[
    UserText1= "V15.7",
]]*)
(*
F *******************************************************************************************
F * File name	: F_Gestop_Open.st															*
F * Description	: request the EMERGENCYSTOPOPEN and set to ZERO the configured fast output	*
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
FUNCTION F_Gestop_Open

	#IMPORT  "Gv_AllProcess.gvl"
	#IMPORT  "Gv_InputOutput.gvl"
	
var
	li_OutMask			: word;
	ll_RetCode			: dword;
end_var

(* Open the emergency contact - fast output 1 = 0 *)
ll_RetCode := EmergencyStopOpen(0, 0);

if (gSt_PlcCfg.Second_Estop_Signal <> 0) then
	if (gSt_PlcCfg.Second_Estop_Signal > 0) and (gSt_PlcCfg.Second_Estop_Signal < 4) then
		li_OutMask := SHL(1, gSt_PlcCfg.Second_Estop_Signal-1);
		ll_RetCode	:= FastOutputWrite(0, li_OutMask);
	end_if;
end_if;

O_AuxGestop := 0;
M_SpepnOpen	:= true;
I_AuxOn := false;

END_FUNCTION
