(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_Override : INT
(*
F ***************************************************************************************
F * File name    : F_Override.st                                                        *
F * Description  : Calculate the new override, compare the requested value with the     *
F *                default array, and find the nearest value                            *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author        date        comments                                                *
F *                                                                                     *
F *   Mazzocco      18-03-10    Creation F_Override                                     *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iiValue             array [0..100] of INT                           *
F *                     Default override value array                                    *
F *                                                                                     *
F *                 iiIndMax            INT                                             *
F *                     Maximum array index (min 1, max "ciMaxOvr" constant), is the    *
F *                     number of desired override value                                *
F *                                                                                     *
F *                 iiActValue          INT                                             *
F *                     Actual override value                                           *
F *                                                                                     *
F *                 iiNewValue          INT                                             *
F *                     New override value requested                                    *
F *                                                                                     *
F * Return       :  INT                                                                 *
F *                     New override value, the nearest value at the request searching  *
F *                     into the default array                                          *
F *                                                                                     *
F * Global used  :      Not used                                                        *
F *                                                                                     *
F * Constant used:  ciMaxOvr            INT                                             *
F *                     To knows the dimension of output array used field               *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* Calculate the new override, compare the requested value with the default array, and find the
	nearest value */
liNewValue	:= F_Override(
	iiValue,		\* IN	array INT	Default override value array */
	iiIndMax,		\* IN	INT			Maximum array index (min 1, max "ciMaxOvr" constant), is the number of desired override value */
	iiActValue,		\* IN	INT			Actual override value */
	iiNewValue);	\* IN	INT			New override value requested *)



VAR_INPUT
	iiValue		: array [0..ciMaxOvr] of int;	(* Default override value array *)
	iiIndMax	: int;	(* Maximum array index (min 1, max "ciMaxOvr" constant), is the number of desired override value *)
	iiActValue	: int;	(* Actual override value *)
	iiNewValue	: int;	(* New override value requested *)
END_VAR

VAR
	liIndMax	: int;	(* Maximum array index copy *)
	liInd		: int;	(* Index to scroll the array *)
	liActInd	: int;	(* Actual override value index *)
	liPreInd	: int;	(* New override value index precalculated *)
	liNewInd	: int;	(* New override value index *)
END_VAR

(* Check the maximum array index value *)
liIndMax	:= LIMIT(0, iiIndMax, ciMaxOvr);

(* Search into array the nearest value at the actual value to refresh actual index, is
	necessary if the override can be changed from different ambient *)
for liInd := 0 to liIndMax by 1 do
	if iiValue[liInd] <= iiActValue then
		liActInd	:= liInd;
	else
		(* When the next index override value become bigger of the actual value, exit from the
			for cycle, in this way the override index stored is equal or a little bit lowest of
			the actual override value *)
		exit;
	end_if;
end_for;



(* Calculate the new array index *)
if iiNewValue > iiActValue then
	liPreInd	:= liActInd + 1;
elsif iiNewValue < iiActValue then
	liPreInd	:= liActInd - 1;
else
	liPreInd	:= liActInd;
end_if;



(* Check the new index value *)
liNewInd	:= LIMIT(0, liPreInd, liIndMax);

(* Calculate the new override value *)
F_Override	:= iiValue[liNewInd];


END_FUNCTION
