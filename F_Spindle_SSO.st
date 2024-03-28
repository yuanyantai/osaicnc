(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_Spindle_SSO : lreal

	#IMPORT  "Gv_AllProcess.gvl"

var_input
	ist_spin	: St_Spindle;
END_VAR

(* Adjust programmed spindle speed with SSO *)
if ist_spin.SSO_Local > 0 then
	F_Spindle_SSO := ist_spin.MD_SpeedPro * int_to_lreal(ist_spin.SSO_Local) / 10000.0 ;
else
	F_Spindle_SSO := ist_spin.MD_SpeedPro * int_to_lreal(ArrSI[ist_spin.Spindle_process * 20 + 17]) / 10000.0 ;
end_if;

if (F_Spindle_SSO > ist_spin.Spindle_Speedmax) and not ist_spin.M_G96_SPro then
	F_Spindle_SSO := ist_spin.Spindle_Speedmax;
end_if;

END_FUNCTION
