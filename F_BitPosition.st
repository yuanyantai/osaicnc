(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_BitPosition : INT
(*
F ***************************************************************************************
F * File name    : F_BitPosition.st                                                     *
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
F *   Mazzocco      19-03-10    Creation F_BitPosition                                  *
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
	iiVariable	: int;	(* Input variable with only one bit true, except the most significative bit *)
END_VAR

	

case iiVariable of
	1:		F_BitPosition	:= 1;
	2:		F_BitPosition	:= 2;
	4:		F_BitPosition	:= 3;
	8:		F_BitPosition	:= 4;
	16:		F_BitPosition	:= 5;
	32:		F_BitPosition	:= 6;
	64:		F_BitPosition	:= 7;
	128:	F_BitPosition	:= 8;
	256:	F_BitPosition	:= 9;
	512:	F_BitPosition	:= 10;
	1024:	F_BitPosition	:= 11;
	2048:	F_BitPosition	:= 12;
	4096:	F_BitPosition	:= 13;
	8192:	F_BitPosition	:= 14;
	16384:	F_BitPosition	:= 15;
	-32768:	F_BitPosition	:= 16;
else
    F_BitPosition	:= 0;
end_case;


END_FUNCTION
