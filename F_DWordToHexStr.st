(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_DWordToHexStr : STRING
(*
F ***************************************************************************************
F * File name    : F_DWordToHexStr.st                                                   *
F * Description  : Convert a DWORD value into a hexadecimal string                      *
F *                                                                                     *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author        date        comments                                                *
F *                                                                                     *
F *   T. Hall       23-09-12    Function creation                                       *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  ilInpVal            DWORD                                           *
F *                     Value to convert                                                *
F *                                                                                     *
F *                 iLdgZero            BOOL                                            *
F *                     FALSE=No leading 0's, TRUE=Include leading 0's                  *
F *                                                                                     *
F * Return       :  STRING                                                              *
F *                 String containing the hexadecimal value of ilInpVal                 *
F *                 Depending on the value of iLdgZero leading 0's may be present       *
F *                                                                                     *
F * Global used  :      Not used                                                        *
F *                                                                                     *
F ***************************************************************************************

   Example for program use

\* Convert dword value into hexadecinal string (without leading 0's)
   E.G. 196616 -> '30008' */
MyStr := F_DWordToHexStr( llMyDWrd, FALSE );
*)

VAR_INPUT
   ilInpVal	: dword;  (* Value to convert *)
   iLdgZero : bool;   (* TRUE=return leading 0's *)
END_VAR

VAR
   lChFnd   : bool;
   liShift  : int;
   liChar   : int;
   lsChar   :STRING;
   lsStr    :STRING;
END_VAR

(* Force non-0 found if leading 0's req'd *)
lChFnd := iLdgZero;

(* Loop for 8 chars *)
FOR liShift := 28 TO 0 BY -4 do
   liChar := DWORD_TO_INT( SHR( ilInpVal, liShift ) and 16#F );

   (* Set non-0 found *)
   if liChar <> 0 or liShift = 0 then
      lChFnd := TRUE;
   end_if;

   CASE liChar OF
      10: lsChar := 'A';
      11: lsChar := 'B';
      12: lsChar := 'C';
      13: lsChar := 'D';
      14: lsChar := 'E';
      15: lsChar := 'F';
   else
      lsChar := INT_TO_STRING( liChar );
   END_CASE;

   (* Append Hex char. *)
   if lChFnd then
      lsStr := CONCAT( lsStr, lsChar );
   end_if;
   
END_FOR;

(* Return Hex string *)
F_DWordToHexStr := lsStr;

END_FUNCTION
