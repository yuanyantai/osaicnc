(*[[
    UserText1= "V15.7",
]]*)
FUNCTION_BLOCK Fb_AnalogDigital
VAR_INPUT
	iiMaxInp	: int;	(* Maximum input value *)
	iiMinInp	: int;	(* Minimum input value *)
	iiNumStep	: int;	(* Maximum output value *)
	idValue		:lreal;	(* Input value (analog potentiometer) *)
END_VAR

VAR_OUTPUT
	oiValue		: int;	(* Output value (new override) *)
END_VAR

VAR
	ld_valPerStep	: lreal;
	ld_valPerStep_2	: lreal;
	ld_valfiltered	: lreal;
	ld_valmemory	: lreal := -1.0;
	li_value		: int;
	li_output		: int;
	l_Init			: bool := true;
END_VAR

if l_Init then
	l_init := false;
	(* Scale calculation, only when the configuration change *)
	(* The number of step is increase by 1 because the consolle array start from 0 to NMax value *)
	ld_valPerStep := int_to_lreal(iiMaxInp - iiMinInp) / int_to_lreal(iiNumStep + 1);
	ld_valPerStep_2 := ld_valPerStep / 2.0;
end_if;

li_value := lreal_to_int(idValue);
if li_value <= iiMinInp then
	ld_valmemory := 0.0;
	li_output := 0;
elsif  li_value >= iiMaxInp then 
	li_output := iiNumStep;
	ld_valmemory := int_to_lreal(iiMaxInp);
else
	ld_valfiltered := abs(idValue) - int_to_lreal(iiMinInp);
	if ld_valmemory <> ld_valfiltered then
		if  abs(ld_valmemory - ld_valfiltered) >= (ld_valPerStep_2) then
			li_output := trunc(ld_valfiltered / ld_valPerStep);
			ld_valmemory := ld_valfiltered;
		end_if;
	end_if;
end_if;

oiValue := li_output;
END_FUNCTION_BLOCK
