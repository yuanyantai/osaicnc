(*[[
    UserText1= "V15.7",
]]*)
FUNCTION_BLOCK Fb_Canopen_Init_Nodo

 	#IMPORT  "Gv_Allprocess.gvl"


(*
I dati sono espressi in valori esadecimanli, sia i comandi che i valori
I campi possono essere separati da qualsiasi terminatore
I numeri da 0-9 o le lettere da A-F
Le lettere minuscole da a-f non sono terminatori!!!
Ci possono essere delle righe vuote
I commenti devono risiedere al fondo della riga dei comandi

<STATIC>

6040	001	002	000006	    ;INVIO CONTROL WORD PER INIZIO OPERAZIONI
1800	2	1	fF
FFFF	80			      ;NMT DI PASSAGGIO IN PREOPERATIONAL (ffff --> -1 codice di riconoscimento)

<END>
<DINAMIC>

1800	2	1	FF
1800	2	1	FF
FFFF	80                 ;NMT DI PASSAGGIO IN PREOPERATIONAL

<END>           ; Fine sezione o fine file

*)

VAR_INPUT
    CHN         : int;
	Node_index	: int;
	Node_Id		: int;
END_VAR

VAR_OUTPUT
    o_Status	: Dword;                  (* SEGNALAZIONE DI EVENTUALI ERRORI 0 = COMANDI ESEGUITI CORRETTAMENTE *)
END_VAR

VAR
    la_FieldName	: STRING;               (* CAMPO DI COMANDI DA ESEGUIRE *)
    ll_Data			: Dword;                (* VARIBILE DI APPOGGIO PER L'ELABORAZIONE DEI DATI *)
    li_Object		: word;                 (* OGGETTO CAN *)
    li_SubIdx		: int;                  (* SUBINDICE DELL'OGGETTO *)
    li_DataLength	: int;                  (* LUNGHEZZA DEL DATO DA SPEDIRE *)
    li_Command		: int;                  (* COMANDO NMT *)
    ll_Deltime     	: Dword;                (* TEMPO DI DELAY *)  
    
    li_LenStr		: int;                  (* LUNGHEZZA DELLA STRINGA LETTA DAL FILE *)
    la_Stringlen1	: string[1];
	li_ExecStatus	: Dword;

    la_Sline		: STRING;	(* Singol file line                             *)
    li_Match		: int;      (* mach string output							*)
    li_Matchd		: int;      (* mach string output							*)
    li_Matchh		: int;      (* mach string output							*)
    li_Base			: int;

	filehnd			: F_SYNC_FILE;
	lb_filestat		: bool;
	lb_ReadSdo		: bool;
	lb_addCobId		: bool;

END_VAR    

o_Status := 0;
 
(* Compose the serach key inside the file at the end the key for the node 1 in the canbus 0 will be :
	<NODE_1.0>
*)
la_FieldName := CONCAT('<NODE_',INT_TO_STRING(NODE_ID),
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
repeat
	lb_filestat := F_SYNC_READLINE(filehnd, la_Sline);
 
    if filehnd.POSITION = -1 then
        o_Status := 1;
		lb_filestat := F_SYNC_CLOSEFILE(filehnd);
        return;
    end_if;

    li_Match := FIND(la_Sline, la_FieldName);
    until li_Match <> 0 
end_repeat;


(* Inside the section NODE_1.0 found the <INIT> section *)
la_FieldName := '<INIT>';
li_Base := 16;

repeat
	lb_filestat := F_SYNC_READLINE(filehnd, la_Sline);
 
    if filehnd.POSITION = -1 then
        o_Status := 1;
		lb_filestat := F_SYNC_CLOSEFILE(filehnd);
        return;
    end_if;
    li_Match := FIND(la_Sline, la_FieldName);
    until li_Match <> 0 
end_repeat;

(* ESECUZIONE DEI COMANDI DA FILE FINO ALLA PAROLA CHIAVE <END> *)

while (filehnd.POSITION <> -1 and o_Status = 0) do

	lb_filestat := F_SYNC_READLINE(filehnd, la_Sline);

    li_Match := FIND(la_Sline, '<END>');                             
    li_Matchd := FIND(la_Sline, '<DEC>');                             
    li_Matchh := FIND(la_Sline, '<HEX>');                             
    li_LenStr := LEN(la_Sline);
    if li_Match <> 0 then exit; end_if;  (* VERIFICA CHE LA LINEA LETTA NON SIA <END> ALTRIMENTI ESCE *)
    
    if li_Matchd <> 0 then li_Base := 10;
    elsif li_Matchh <> 0 then li_Base := 16;
    elsif li_LenStr > 1 then
        la_Stringlen1 := la_Sline;
        if (la_Stringlen1 <> ';') then

			lb_ReadSdo := (la_Stringlen1 = 'R');
			lb_addCobId := (la_Stringlen1 = 'C');
			if lb_ReadSdo or lb_addCobId then
	        	la_Sline := DELETE(la_Sline, 1, 0);
			end_if;

            Fn_StringToDwordHex(la_Sline, ll_Data);                                             (* ESTRAE L'OGGETTO *)
            li_Object := DWORD_TO_WORD(ll_Data);
    
            if (li_Object = 16#FFFF) then                                                          (* FFFF E' L'INDICATORE DEI COMANDI NMT *)
                Fn_StringToInt(la_Sline, li_Base, li_Command);                                            (* ESTRAE IL COMANDO NMT *)
				o_Status := CANopen_NmtCmd(MODE_WAIT, li_ExecStatus, CHN, NODE_ID, li_Command , 2000);
            elsif (li_Object = 16#FFFD) then
                (* FFFD E' L'INDICATORE DEI COMANDI DI DELAY *)
                Fn_StringToDword(la_Sline, li_Base, ll_Deltime);                                            (* ESTRAE IL COMANDO NMT *)
				ll_Deltime := lreal_to_dword(dword_to_lreal(ll_Deltime) * 1000.0);
                o_Status := DELAY(ll_Deltime);
            else
                Fn_StringToIntHex(la_Sline, li_SubIdx);                                         (* ESTRAE IL SUB-INDEX *)
                Fn_StringToIntHex(la_Sline, li_DataLength);                                         (* ESTRAE LA LUNGHEZZA DEL DATO *)
                Fn_StringToDword(la_Sline, li_Base, ll_Data);                                        (* ESTRAE IL DATO DA INVIARE *)
				if lb_ReadSdo then
					o_Status := CANopen_ReadSdoCmd(MODE_WAIT, li_ExecStatus, chn, NODE_ID, li_Object, li_SubIdx, 10000, li_DataLength, ll_Data);
				else
					if lb_addCobId then
						ll_Data := dint_to_dword(dword_to_dint(ll_Data) + int_to_dint(NODE_ID));
					end_if;
					o_Status := CANopen_WriteSdoCmd(MODE_WAIT, li_ExecStatus, chn, NODE_ID, li_Object, li_SubIdx, 10000, li_DataLength, ll_Data);
				end_if;
                ;
            end_if;
        end_if;
    end_if;
end_while; 

lb_filestat := F_SYNC_CLOSEFILE(filehnd);

(* Set errore su settaggio parametri drive *)
if o_Status <> 0 then 
	o_Status := 2;
end_if;

END_FUNCTION_BLOCK
