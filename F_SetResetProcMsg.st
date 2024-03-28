(*[[
    UserText1= "V15.7",
]]*)
(*
F ***************************************************************************************
F * File name	: F_SetResetProcMsg.st													*
F * Description	: Set/Reset second Gestop												*
F *				  When the Gestop signal ( fast output 1) is set or reset also the 		*
F *				  selected output will be set/reset										*
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F * ----------------------------------------------------------------------------------- *
F *   Author        date        comments                                                *
F *   Scapolan      19-05-16    Function creation                                       *
F * ----------------------------------------------------------------------------------- *
F * Input        :																		*
F *                 	bool															*
F ***************************************************************************************
*)
FUNCTION F_SetResetProcMsg

	#IMPORT  "Gv_AllProcess.gvl"

var_input
	ii_proc		: int;
	ii_MsgNum	: int;
	i_setreset	: bool;
end_var

var
	li_MWIndex		: int;
	li_procindex	: int;
	li_MsgIndex		: int;
	li_msg_num		: int;
	li_MsgBit		: int;
	li_mask			: word;
	li_value		: word;
end_var

(* the messagges start from 1 , the msg001 go to bit 0 of first mw *)
li_procindex := ii_proc - 1;
li_msg_num := ii_MsgNum - 1;

li_MsgIndex := li_msg_num / 16;
li_MsgBit := MOD(li_msg_num, 16);
li_mask := shl(1,li_MsgBit);
if i_setreset then
	li_value := li_mask;
else
	li_value := 0;
end_if;

if ii_proc = Current_Process then
	li_MWIndex := ciCurrProcMWMsg + li_procindex * ciNumProcMsgW + li_MsgIndex;
else
	li_MWIndex := ciFirstProcMWMsg + li_procindex * ciNumProcMsgW + li_MsgIndex;
end_if;

ArrMW[li_MWIndex] := (ArrMW[li_MWIndex] and not li_mask) or li_value;

END_FUNCTION
