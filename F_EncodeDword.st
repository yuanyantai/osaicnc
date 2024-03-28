(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_EncodeDword : int

	#IMPORT  "Gv_AllProcess.gvl"
	
(*
F ***************************************************************************************
F * File name    : F_EncodeDword.st                                                     *
F * Description  : Calculate the position of a single bit into the input variable, from *
F *                1 to 15, the function give zero if more then one bit is true, if the *
F *                most significative bit is true, if all the bits are false.           *
F *                Especially thinked to convert the SW31 S_1PROMOD variable in the     *
F *                SetProcessMode function block format.                                *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author        date        comments                                                *
F *                                                                                     *
F *   Scapolan      19-04-16    Creation F_BitPosition                                  *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iiVariable          INT                                             *
F *                     Input variable with only one bit true, except the most          *
F *                     significative bit                                               *
F *                                                                                     *
F * Return       :  INT                                                                 *
F *                     Position of a single bit into the input variable, from 1 to 15, *
F *                     the function give zero if more then one bit or the most         *
F *                     significative bit is true                                       *
F *                                                                                     *
F * Global used  :      Not used                                                        *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* F_BitPosition function calculate the position of a single bit into the input variable, from
	1 to 15, the function give zero if more then one bit is true, if the most significative bit
	is true, if all the bits are false */
liNewValue	:= F_BitPosition(iiVariable);
*)


VAR_INPUT
	il_Variable	: dword;	(* Input variable with only one bit true, except the most significative bit *)
END_VAR

var
	li_Position	: int;
	ll_RetCode	: dword;
end_var

ll_RetCode := SearchData(0, 33, il_Variable, GL_varfound[0], li_Position);
if li_Position = -1 then
	F_EncodeDword := 0;
else
	F_EncodeDword := li_Position;
end_if;


END_FUNCTION
