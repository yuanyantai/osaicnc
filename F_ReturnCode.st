(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_ReturnCode : DWORD
(*
F ***************************************************************************************
F * File name    : F_ReturnCode.st                                                      *
F * Description  : Function block return code management, save into the system history  *
F *                the return code value, the function block and the program name.      *
F *                Return in output the last saved code, to don't save another time the *
F *                same error.                                                          *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author        date        comments                                                *
F *                                                                                     *
F *   Mazzocco      27-03-14    Function creation                                       *
F *   Scapolan      16-06-16    Optimization                                            *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  illRetCode          DWORD                                           *
F *                     Function block return code                                      *
F *                                                                                     *
F *                 iaaFBName           STRING                                          *
F *                     Function block name                                             *
F *                                                                                     *
F *                 iaaProgName         STRING                                          *
F *                     Program name                                                    *
F *                                                                                     *
F * Input/Output :  ioMsg               BOOL                                            *
F *                     Generic function block anomaly message                          *
F *                                                                                     *
F * Return       :  DWORD                                                               *
F *                     Last saved code, to don't save another time the same error      *
F *                                                                                     *
F * Global used  :  not used                                                            *
F *                                                                                     *
F ***************************************************************************************

	Example for program use

\* Function block return code management, save into the system history the return code value,
	the function block and the program name. Return in output the last saved code, to don't
	save another time the same error. */

if llRetCode01<>illRetCode then
	llRetCode01	:= F_ReturnCode(
		illRetCode,		\* IN	DWORD	Function block return code */
		iaaFBName,		\* IN	STRING	Function block name */
		iaaProgName,	\* IN	STRING	Program name */
		ioMsg);			\* I/O	BOOL	Generic function block anomaly message */
end_if;


VAR
	laaProgName	:STRING	:= '';	\* Program name */
	llRetCode01	: dword;	\* Return code management */
END_VAR

if llRetCode01<>llRetCode then
	llRetCode01	:= F_ReturnCode(llRetCode, 'iaaFBName', laaProgName, M_Msg);
end_if;
*)


VAR_INPUT
	illRetCode	: dword;		(* Function block return code *)
	iaaFBName	:STRING;	(* Function block name *)
	iaaProgName	:STRING;	(* Program name *)
END_VAR

VAR_IN_OUT
	ioMsg	: bool;	(* Generic function block anomaly message *)
END_VAR

VAR
	laaMessage		:STRING;	(* MEssage saved in system history *)
	llRetCode		: dword;		(* Warning message function block return code *)
END_VAR


if illRetCode<>0 then
	(* Build the message *)
	laaMessage	:= CONCAT(
							'99-Generic FB anomaly, Code: ',
					    	DWORD_TO_STRING(illRetCode),
					    	', Function: ',
					    	iaaFBName,
					   		', Program: ',
							iaaProgName
						 );

	(* Write message into the system history *)
	llRetCode	:= WarningMessage(laaMessage, 1 (*OnHistory*));

	(* Visualize the standard message *)
	ioMsg	:= true;
end_if;

F_ReturnCode	:= illRetCode;


END_FUNCTION
