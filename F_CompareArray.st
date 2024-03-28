(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_CompareArray : BOOL
(*
F ***************************************************************************************
F * File name    : F_CompareArray.st                                                    *
F * Description  : Compare two array with NUM_OF_AX fields, to check if they countain   *
F *                the same value, in the same or in different order.                   *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author        date        comments                                                *
F *                                                                                     *
F *   Mazzocco      18-05-10    Function creation                                       *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iiArray1            Array [0..NUM_OF_AX-1] of INT                   *
F *                     First array                                                     *
F *                                                                                     *
F *                 iiArray2            Array [0..NUM_OF_AX-1] of INT                   *
F *                     Second array                                                    *
F *                                                                                     *
F * Return       :  BOOL                                                                *
F *                     True value if both arrays countain the same value in any order  *
F *                                                                                     *
F * Global used  :      Not used                                                        *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* Compare two array with NUM_OF_AX fields, to check if they countain the same value, in the
	same or in different order */
lEqual	:= F_CompareArray(iiArray1, iiArray2);
*)


VAR_INPUT
	iiArray1	:Array [0..NUM_OF_AX-1] of int;	(* First array *)
	iiArray2	:Array [0..NUM_OF_AX-1] of int;	(* Second array *)
END_VAR

VAR
	liInd		: int;	(* Array field scrolling *)
END_VAR



for liInd := 0 to (NUM_OF_AX-1) by 1 do

	(* check if the second array countain all the value of the first array *)
	if iiArray1[liInd]=iiArray2[0] or iiArray1[liInd]=iiArray2[1] or
	iiArray1[liInd]=iiArray2[2] or iiArray1[liInd]=iiArray2[3] or
	iiArray1[liInd]=iiArray2[4] or iiArray1[liInd]=iiArray2[5] or
	iiArray1[liInd]=iiArray2[6] or iiArray1[liInd]=iiArray2[7] or
	iiArray1[liInd]=iiArray2[8] or iiArray1[liInd]=iiArray2[9] or
	iiArray1[liInd]=iiArray2[10] or iiArray1[liInd]=iiArray2[11] then
		F_CompareArray	:= true;
	else
		F_CompareArray	:= false;
		exit;
	end_if;

	(* check if the first array countain all the value of the second array *)
	if iiArray2[liInd]=iiArray1[0] or iiArray2[liInd]=iiArray1[1] or
	iiArray2[liInd]=iiArray1[2] or iiArray2[liInd]=iiArray1[3] or
	iiArray2[liInd]=iiArray1[4] or iiArray2[liInd]=iiArray1[5] or
	iiArray2[liInd]=iiArray1[6] or iiArray2[liInd]=iiArray1[7] or
	iiArray2[liInd]=iiArray1[8] or iiArray2[liInd]=iiArray1[9] or
	iiArray2[liInd]=iiArray1[10] or iiArray2[liInd]=iiArray1[11] then
		F_CompareArray	:= true;
	else
		F_CompareArray	:= false;
		exit;
	end_if;

end_for;



END_FUNCTION
