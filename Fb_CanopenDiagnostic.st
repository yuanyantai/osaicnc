(*[[
    UserText1= "V15.7",
]]*)
FUNCTION_BLOCK Fb_CanopenDiagnostic
(*
F ***************************************************************************************
F * File name    : Fb_CanopenDiagnostic.st                                              *
F * Description  : Canopen field bus diagnostic                                         *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author       date      comments                                                   *
F *                                                                                     *
F *   Mazzocco     15-01-14  Function block creation                                    *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iReset              BOOL                                            *
F *                     Reset error request                                             *
F *                                                                                     *
F *                 iiBoardId           INT                                             *
F *                     Canopen board identifier                                        *
F *                                                                                     *
F * Input/Output :  ioMsgErr            BOOL                                            *
F *                     Canopen board error message                                     *
F *                                                                                     *
F *                 ioiErrNode          INT                                             *
F *                     Canopen bus I/O node in error address                           *
F *                                                                                     *
F * Output       :  oSt_Status          CANopen_StatusType                              *
F *                     CANopen board status structure                                  *
F *                                                                                     *
F *                 olRetCode           DWORD                                           *
F *                     Function block return code                                      *
F *                                                                                     *
F * Global used  :      not used                                                        *
F *                                                                                     *
F * Constant used:      not used                                                        *
F *                                                                                     *
F * Attention    :  This macro function block use wait function                         *
F *                                                                                     *
F ***************************************************************************************
*)

(* Example for program use
VAR
	Fb_0CanopenDiagnostic	:Fb_CanopenDiagnostic;	\* Canopen field bus diagnostic */
END_VAR

\* Canopen field bus diagnostic */
Fb_0CanopenDiagnostic(
	iReset		 := ,	\* IN	BOOL	Reset error request */
	iiBoardId	 := ,	\* IN	INT		Canopen board identifier */
	ioMsgErr	 := ,	\* I/O	BOOL	Canopen board error message */
	ioiErrNode	 := ,	\* I/O	INT		Canopen bus node in error address */
	oSt_Status	=> ,	\* OUT	CANopen_StatusType		CANopen board status structure */
	olRetCode	=> );	\* OUT	DWORD	Function block return code *)


VAR_IN_OUT
	ioMsgErr	: bool;	(* Canopen board error message *)
	ioiErrNode	: int;	(* Canopen bus I/O node in error address *)
	ConfgNode	: array [0..15] of BYTE;	(*--- Configured node		---*)
	ActivNode	: array [0..15] of BYTE;	(*--- Active node 		---*)
END_VAR

VAR
	liNodeId		: int;	(* Node identifier index scroll *)
	lbErrNode0		:BYTE;	(* Compare between configured and active node *)
END_VAR


(* Compare all the configured node with the active node *)
for liNodeId := 0 to 15 by 1 do
	if ConfgNode[liNodeId] <> ActivNode[liNodeId] then
		ioMsgErr	 := true;

		if ioiErrNode=0 then
			lbErrNode0	 := ConfgNode[liNodeId] xor ActivNode[liNodeId];
			if (lbErrNode0 and 2#00000001)<>0 then
				ioiErrNode	 := liNodeId * 8;
			elsif (lbErrNode0 and 2#00000010)<>0 then
				ioiErrNode	 := liNodeId * 8 + 1;
			elsif (lbErrNode0 and 2#00000100)<>0 then
				ioiErrNode	 := liNodeId * 8 + 2;
			elsif (lbErrNode0 and 2#00001000)<>0 then
				ioiErrNode	 := liNodeId * 8 + 3;
			elsif (lbErrNode0 and 2#00010000)<>0 then
				ioiErrNode	 := liNodeId * 8 + 4;
			elsif (lbErrNode0 and 2#00100000)<>0 then
				ioiErrNode	 := liNodeId * 8 + 5;
			elsif (lbErrNode0 and 2#01000000)<>0 then
				ioiErrNode	 := liNodeId * 8 + 6;
			elsif (lbErrNode0 and 2#10000000)<>0 then
				ioiErrNode	 := liNodeId * 8 + 7;
			end_if;
		end_if;
	end_if;
end_for;


END_FUNCTION_BLOCK
