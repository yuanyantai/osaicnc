(*[[
    UserText1= "V15.7",
]]*)
FUNCTION_BLOCK Fb_Can_Axis_Parameters

 	#IMPORT  "Gv_Allprocess.gvl"

VAR_INPUT
	CHN			: int;
	Node_index	: int;
	Node_Id		: int;
END_VAR

VAR_OUTPUT
    o_Status   : Dword;	(* Fb output error if 0 all is done correctly	*)
END_VAR

VAR
    la_Sline	: STRING;	(* Singol file line                             *)
    la_FieldName: STRING;   (* CAMPO DI COMANDI DA ESEGUIRE                 *)
    li_Match	: int;      (* mach string output							*)
    li_Match_1	: int;      (* mach string output <NODE_					*)
	li_ind		: int;
    ld_Tmp		: lreal;
	filehnd		: F_SYNC_FILE;
	lb_filestat	: bool;

END_VAR    

(* Found in the file the key 'AXIS PARAM' *)
(* RICERCA DELLA PAROLA CHIAVE 'la_FieldName' *)
la_FieldName := CONCAT('<NODE_',INT_TO_STRING(Node_Id),
						'.',
						INT_TO_STRING(CHN),
						'>'
					   );


filehnd.FILENAME	:= CONCAT(gaIOFilePath, '\cancfg.txt');
filehnd.MODE        := CF_READ;
filehnd.POSITION    := 0;
filehnd.LSTERRCD    := 0;
filehnd.ISOPEN      := 0;

lb_filestat := F_SYNC_OPENFILE(filehnd);
if lb_filestat then
    o_Status := 1;
    RETURN;
end_if;

(* found the key <NODE_n.chn> *)
REPEAT
	lb_filestat := F_SYNC_READLINE(filehnd, la_Sline);
 
    if filehnd.POSITION = -1 then
        o_Status := 1;
		lb_filestat := F_SYNC_CLOSEFILE(filehnd);
        RETURN;
    end_if;

    li_Match := FIND(la_Sline, la_FieldName);
    UNTIL li_Match <> 0 
end_repeat;



REPEAT 
	lb_filestat := F_SYNC_READLINE(filehnd, la_Sline);
    if (filehnd.POSITION = -1) or (li_Match_1 = 0) then
        o_Status := 1;
		lb_filestat := F_SYNC_CLOSEFILE(filehnd);
        RETURN;
    end_if;
    li_Match := FIND(la_Sline, '<AXIS PARAM>');
	li_Match_1 := FIND(la_Sline, '<NODE_');
    UNTIL li_Match <> 0 
end_repeat;

(* Increment the numbers of canopen motors *)
li_ind := Gi_Can_Num_Motor + 1;
GI_Can_CobidMotor[li_ind] := Node_index;
Gst_CanMotor[Node_index].CHN := CHN;
Gst_CanMotor[Node_index].NODE_ID := Node_Id;

(* Set requet to initialize the motor *)
Gst_CanMotor[Node_index].INIT := TRUE;


(* Until the key 'END' is not found analize the file *)
while (TRUE) do
    li_Match := 0;
	lb_filestat := F_SYNC_READLINE(filehnd, la_Sline);
    if filehnd.POSITION = -1 then
        o_Status := 1;
		lb_filestat := F_SYNC_CLOSEFILE(filehnd);
		Gi_Can_Num_Motor := li_ind;
        exit;
    end_if;
    
    li_Match := FIND(la_Sline, '<END>');
    if li_Match <> 0 then 
        (* COSTANTE DI CONVERSIONE DELLA VELOCITA' DA MM/MIN A GIRI/MIN *)
        (* PER SM137 è IN GIRI/MINUTO                                   *)
        Gst_CanMotor[Node_index].VEL_CONV := 1.0/Gst_CanMotor[Node_index].ME_PITCH;

        (* Calcolo il fattore di conversione da impulsi motore a millimetri *)
        Gst_CanMotor[Node_index].POS_CONV := Gst_CanMotor[Node_index].ME_PITCH / Gst_CanMotor[Node_index].EL_PITCH;

		(* if the process is zero the cam motor is assigned at the process 1 *)
		if Gst_CanMotor[Node_index].ProcessNum = 0 then
			Gst_CanMotor[Node_index].ProcessNum := 1;
		end_if;

        o_Status := 0;
		Gi_Can_Num_Motor := li_ind;

        exit;
    end_if;

    (* Device type                        *)
    li_Match := FIND(la_Sline, '<DEVICE TYPE>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
    	Gst_CanMotor[Node_Index].DevType := lreal_to_int(ld_Tmp);
    end_if;

    (* ELECTRICAL PITCH                   *)
    li_Match := FIND(la_Sline, '<ELECTRICAL PITCH>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
    	Gst_CanMotor[Node_Index].EL_PITCH := ld_Tmp;
    end_if;
        
    (* MECCANICAL PITCH                  *)
    li_Match := FIND(la_Sline, '<MECCANICAL PITCH>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
    	Gst_CanMotor[Node_Index].ME_PITCH := ld_Tmp;
    end_if;        

    (* TOLLERANCE SPACE   *)
    li_Match := FIND(la_Sline, '<TOLLERANCE SPACE>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
    	Gst_CanMotor[Node_Index].POSIZ_Band := ld_Tmp;
    end_if;        
        
    (* TOLLERANCE WINDOW        *)
    li_Match := FIND(la_Sline, '<TOLLERANCE WINDOW>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        ld_Tmp := ld_Tmp * 1000.0; (* CONVERTE IL TEMPO DA SECONDI A MILLISECONDI *)
        Gst_CanMotor[Node_Index].POSIZ_WINDOW := lreal_to_time(ld_Tmp);
    end_if;        
        
    (* TOLLERANCE TIMEOUT              *)
    li_Match := FIND(la_Sline, '<TOLLERANCE TIMEOUT>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        ld_Tmp := ld_Tmp * 1000.0; (* CONVERTE IL TEMPO DA SECONDI A MILLISECONDI *)
        Gst_CanMotor[Node_Index].POSIZ_TIMEOUT := lreal_to_time(ld_Tmp);
    end_if;        
        
    (* RAPID VELOCITY                               *)
    li_Match := FIND(la_Sline, '<RAPID VELOCITY>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].VEL_RAP := ld_Tmp;
    end_if;        
        
    (* MANUAL VELOCITY                              *)
    li_Match := FIND(la_Sline, '<MANUAL VELOCITY>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].VEL_MAN := ld_Tmp;
    end_if;        

    (* RAPID ACCELERATION                           *)
    li_Match := FIND(la_Sline, '<RAPID ACCELERATION>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].ACC_RAP := ld_Tmp;        
    end_if;        

    (* MANUAL ACCELERATION                          *)
    li_Match := FIND(la_Sline, '<MANUAL ACCELERATION>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].ACC_MAN := ld_Tmp;
    end_if;        

    (* HOMING DIRECTION  0=POSITIVO 1=NEG      *)
    li_Match := FIND(la_Sline, '<HOMING DIRECTION>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].DIR_HOMING := (ld_Tmp = 0.0);
    end_if;        

    (* POSITIVE LIMIT                        *)
    li_Match := FIND(la_Sline, '<POSITIVE LIMIT>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].LIMOP_POS := ld_Tmp;
    end_if;        

    (* NEGATIVE LIMIT                         *)
    li_Match := FIND(la_Sline, '<NEGATIVE LIMIT>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].LIMOP_NEG := ld_Tmp;
    end_if;        

    (* HOME POSITION                                   *)
    li_Match := FIND(la_Sline, '<HOME POSITION>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].HOME_POSITION := ld_Tmp;
    end_if;        

    (* HOMING VELOCITY                               *)
    li_Match := FIND(la_Sline, '<HOMING VELOCITY>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].VEL_HOMING := ld_Tmp;
    end_if;
    
    (* Address of info to handle the motor *)
	(* Can PDO Control word offset in bytes *)
    li_Match := FIND(la_Sline, '<RPDO_CW_OFFSET>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].INDCW := lreal_to_int(ld_Tmp);
    end_if;

    li_Match := FIND(la_Sline, '<RPDO_POSITION_OFFSET>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].INDPOS := lreal_to_int(ld_Tmp);
    end_if;

    li_Match := FIND(la_Sline, '<RPDO_OPMODE_OFFSET>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].INDMODOCN := lreal_to_int(ld_Tmp);
    end_if;

    li_Match := FIND(la_Sline, '<RPDO_VELOCITY_OFFSET>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].IND_VEL := lreal_to_int(ld_Tmp);
    end_if;

    li_Match := FIND(la_Sline, '<TPDO_SW_OFFSET>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].INDSW := lreal_to_int(ld_Tmp);
    end_if;

    li_Match := FIND(la_Sline, '<TPDO_MOTOR_ENCODER_OFFSET>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].INDPOS_INP := lreal_to_int(ld_Tmp);
    end_if;

    li_Match := FIND(la_Sline, '<TPDO_ACT_OPMODE_OFFSET>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].INDMODOMOT := lreal_to_int(ld_Tmp);
    end_if;

    li_Match := FIND(la_Sline, '<TPDO_ACT_TORQUE_OFFSET>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].INDTORQUE := lreal_to_int(ld_Tmp);
    end_if;


	(* INDEX OF THE PREVIOUS MOTOR TO CHECK OPERATIVE LIMIT and COLLISION *)
    li_Match := FIND(la_Sline, '<PREVIOUS MOTOR NUMBER>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].PREV_MOTOR_INDEX := lreal_to_int(ld_Tmp);
    end_if;

	(* INDEX OF THE PREVIOUS MOTOR TO CHECK OPERATIVE LIMIT and COLLISION *)
    li_Match := FIND(la_Sline, '<NEXT MOTOR NUMBER>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].NEXT_MOTOR_INDEX := lreal_to_int(ld_Tmp);
    end_if;

	(* BREAKE ACTIVE *)
    li_Match := FIND(la_Sline, '<MOTOR WITH BREAKE>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].BREAKE := (ld_Tmp <> 0.0);;
    end_if;

	(* NULL OFFSET *)
    li_Match := FIND(la_Sline, '<NULL OFFSET>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].NULL_OFFSET := ld_Tmp;
    end_if;

	(* BACK LASH *)
    li_Match := FIND(la_Sline, '<BACK LASH>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].BACK_LASH := ld_Tmp;
    end_if;

	(* Motor is on table number ... *)
    li_Match := FIND(la_Sline, '<MOTOR ON TABLE>') ;
    if li_Match <> 0 then 
        Fn_StringToLrealB10(la_Sline, ld_Tmp);
        Gst_CanMotor[Node_Index].TABLE := lreal_to_int(ld_Tmp);
    end_if;

end_while;

lb_filestat := F_SYNC_CLOSEFILE(filehnd);

END_FUNCTION_BLOCK
        
