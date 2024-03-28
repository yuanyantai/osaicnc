(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_R_TRIG	: bool

VAR_INPUT
	ii_Input	: bool;
END_VAR

VAR_IN_OUT
	ii_Memory	: bool;
END_VAR

if ii_Input and not ii_Memory then
	F_R_TRIG	:= true;
else
	F_R_TRIG	:= false;
end_if;

ii_Memory := ii_Input;

END_FUNCTION
