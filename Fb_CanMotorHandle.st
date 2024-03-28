(*[[
    UserText1= "V15.7",
]]*)
FUNCTION_BLOCK Fb_CanMotorHandle

	#IMPORT  "Gv_AllProcess.gvl"


(*
    ENABLE      : bool;   ABILITA IL DRIVE - DA COPPIA AL MOTORE            
    DISABLE     : bool;   DISABILITA IL DRIVE - DISABILITA COPPIA AL MOTORE 
    EMERG       : bool;   RICHIESTA DI EMERGENZA                            
    HOLD        : bool;   RICHIEDE LO STOP TEMPORANEO AL MOVIMENTO          
    RESET       : bool;   RICHIESTA DI RESET OPERAZIONE IN CORSO            
    MOV         : bool;   RICHIESTA DI MUOVERE ALLA POSIZIONE DATA          
    HOME        : bool;   RICHIEDE DI ESEGUIRE IL CICLO DI AZZERAMENTO      

    I dati da drive -> cnc sono descritti nella struttura Gst_CanMotor[node_id].TPDO
    I dati da cnc -> drive sono descritti nella struttura Gst_CanMotor[node_id].RPDO


    STATUS DI RITORNO :

    0   Esecuzione terminata correttamente
    1   Richiesta su drive non inizializzato
    2   Richiesta su drive non abilitato
    3   Errore nel comando di abilitazione assi
    10  Richiesta di set modo positioning abortita
    11  Richiesta di set modo homing abortita
    12  Richiesta di invio indice tavola abortita
    13  Errore nella richiesta movimento index table

*)


var_input
    node_id	: int;
end_var

var
	ll_RetCode	: dword;
end_var

(* debug IL := I; *)
if Gst_CanMotor[node_id].INDSW <> -1 then
	ll_RetCode := MoveMemory( Gst_CanMotor[node_id].INDSW,      2,	0, QB0,	Gst_CanMotor[node_id].TPDO_SW        );
end_if;

if Gst_CanMotor[node_id].INDPOS_INP <> -1 then
	ll_RetCode := MoveMemory( Gst_CanMotor[node_id].INDPOS_INP, 4,	0, QB0,	Gst_CanMotor[node_id].TPDO_ACT_POSIZ );
end_if;

if Gst_CanMotor[node_id].INDTORQUE <> -1 then
	ll_RetCode := MoveMemory( Gst_CanMotor[node_id].INDTORQUE, 2,	0, QB0,	Gst_CanMotor[node_id].TPDO_TORQUE );
end_if;

Gst_CanMotor[node_id].ACT_POSIZ := dint_to_lreal(Gst_CanMotor[node_id].TPDO_ACT_POSIZ) * Gst_CanMotor[node_id].POS_CONV;

while true do

if (Gst_CanMotor[node_id].ENABLED = true) then
	if ((Gst_CanMotor[node_id].RPDO_CW and 16#08) <> 16#00) and  ((Gst_CanMotor[node_id].TPDO_SW and 16#07) <> 16#07) then
            Gst_CanMotor[node_id].STATUS := 33;
	end_if;
else
	Gst_CanMotor[node_id].POSIZ := Gst_CanMotor[node_id].ACT_POSIZ;
end_if;


(* GESTIONE INIZIALIZZAZIONE DEL MOTORE CANOPEN *)
if Gst_CanMotor[node_id].INIT then
    Gst_CanMotor[node_id].STATUS := 0;
    Gst_CanMotor[node_id].ENABLED     := false;             (* PRESET ASSE NON ABILITATO  *)
    Gst_CanMotor[node_id].RPDO_CW     := 16#100;            (* PRESET DRIVE IN HALT       *)
	if Gst_CanMotor[node_id].DevType = 2 then
	    Gst_CanMotor[node_id].RPDO_CW     := 16#170;            (* PRESET DRIVE IN HALT       *)
	end_if;
    Gst_CanMotor[node_id].SINIT       := 1;
    Gst_CanMotor[node_id].INIT        := false;
end_if;


(* Se il drive non è stato inizializzato non vengono eseguite le altre funzioni *)
if not Gst_CanMotor[node_id].SINIT then
    Gst_CanMotor[node_id].FAS_ENAB        := 0;   Gst_CanMotor[node_id].ENABLE     := false;
    Gst_CanMotor[node_id].FAS_DISAB       := 0;   Gst_CanMotor[node_id].DISABLE    := false;
    Gst_CanMotor[node_id].FAS_MOV         := 0;   Gst_CanMotor[node_id].MOV        := false;
    Gst_CanMotor[node_id].FAS_HOMESM137   := 0;   Gst_CanMotor[node_id].HOMESM137  := false;
    Gst_CanMotor[node_id].FAS_RESET       := 0;   Gst_CanMotor[node_id].RESET      := false;
    Gst_CanMotor[node_id].FAS_EMERG       := 0;   Gst_CanMotor[node_id].EMERG      := false;

    (* SET STATO DI RITORNO AD ERRORE *)
    Gst_CanMotor[node_id].STATUS := 1;
    exit;
end_if;

(*------------------------------------------*)
(* INIZIO GESTIONE DEL COMAMDO DI EMERGENZA *)
(*------------------------------------------*)
if Gst_CanMotor[node_id].EMERG then
    Gst_CanMotor[node_id].FAS_ENAB        := 0;   Gst_CanMotor[node_id].ENABLE     := false;
    Gst_CanMotor[node_id].FAS_DISAB       := 0;   Gst_CanMotor[node_id].DISABLE    := false;
    Gst_CanMotor[node_id].FAS_MOV         := 0;   Gst_CanMotor[node_id].MOV        := false;
    Gst_CanMotor[node_id].FAS_HOMESM137   := 0;   Gst_CanMotor[node_id].HOMESM137  := false;
    Gst_CanMotor[node_id].FAS_RESET       := 0;   Gst_CanMotor[node_id].RESET      := false;


    Gst_CanMotor[node_id].ENABLED := false;
    Gst_CanMotor[node_id].STATUS := 0;

    case Gst_CanMotor[node_id].FAS_EMERG of
    
        0:  
            if Gst_CanMotor[node_id].EMERG then
                (* TOGLIE IL  SETPOINT E ATTIVA QUICK STOP - QUICK ATTIVO A 0 E' IL BIT " 4 " *)
                Gst_CanMotor[node_id].RPDO_CW   := 0;
                Gst_CanMotor[node_id].FAS_EMERG := 1;                     (* ATTESA ASSE FERMO   *)
            end_if;
    
        1:
            if ((Gst_CanMotor[node_id].TPDO_SW and 16#07) = 16#00) then
                Gst_CanMotor[node_id].RPDO_CW   := 0;
                Gst_CanMotor[node_id].FAS_EMERG := 2;                     (* ATTESA ASSE FERMO   *)
            end_if;
    
        2:
            if ((Gst_CanMotor[node_id].TPDO_SW and 16#07) = 16#00) then
               Gst_CanMotor[node_id].EMERG := false;
               Gst_CanMotor[node_id].FAS_EMERG := 0;
            end_if;
    
    end_case;
    
end_if;
(* FINE GESTIONE DEL COMAMDO DI EMERGENZA *)


(*------------------------------------------*)
(* INIZIO GESTIONE DEL COMAMDO DI RESET     *)
(*------------------------------------------*)
if Gst_CanMotor[node_id].RESET then
    Gst_CanMotor[node_id].STATUS := 0;

    Gst_CanMotor[node_id].FAS_ENAB        := 0;   Gst_CanMotor[node_id].ENABLE     := false;
    Gst_CanMotor[node_id].FAS_DISAB       := 0;   Gst_CanMotor[node_id].DISABLE    := false;
    Gst_CanMotor[node_id].FAS_MOV         := 0;   Gst_CanMotor[node_id].MOV        := false;
    Gst_CanMotor[node_id].FAS_HOMESM137   := 0;   Gst_CanMotor[node_id].HOMESM137  := false;
    
    
    case Gst_CanMotor[node_id].FAS_RESET of

        0:  
            if Gst_CanMotor[node_id].RESET then
                Gst_CanMotor[node_id].WAIT_REG := Time_SinceSystemBoot;

				if Gst_CanMotor[node_id].DevType = 1 then
	                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW and not 16#30;   (* TOGLIE IL  SETPOINT + NEW POINT *)
				end_if;

                if ((Gst_CanMotor[node_id].TPDO_SW and 16#07) <> 0) then
                    Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#100;    (* SETTA HALT *)
                end_if;

                if ((Gst_CanMotor[node_id].TPDO_SW and 16#8) <> 0) then
                    Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#80;    (* FAULT RESET *)
                end_if;

                Gst_CanMotor[node_id].FAS_RESET := 1;                       (* ATTESA ASSE FERMO   *)
            end_if;

        1:
            Gst_CanMotor[node_id].DELTA_ACTPOS := Gst_CanMotor[node_id].ACT_POSIZ - Gst_CanMotor[node_id].ACTPOS_PREC;
            if (ABS(Gst_CanMotor[node_id].DELTA_ACTPOS) > Gst_CanMotor[node_id].POSIZ_BAND) then
                Gst_CanMotor[node_id].ACTPOS_PREC := Gst_CanMotor[node_id].ACT_POSIZ;
                Gst_CanMotor[node_id].WAIT_REG := Time_SinceSystemBoot;
            end_if;

            if ((Gst_CanMotor[node_id].TPDO_SW and 16#400) = 16#400) or ((Gst_CanMotor[node_id].TPDO_SW and 16#0F) = 16#00) or
            ( (Time_SinceSystemBoot - Gst_CanMotor[node_id].WAIT_REG) > Gst_CanMotor[node_id].WAIT_RESET)
            then
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW and not 16#080;    (* TOGLIE IL FAULT RESET *)
                Gst_CanMotor[node_id].FAS_RESET := 2;
            end_if;

        2:
            Gst_CanMotor[node_id].POSIZ := Gst_CanMotor[node_id].ACT_POSIZ;
            Gst_CanMotor[node_id].RESET := false;
            Gst_CanMotor[node_id].FAS_RESET := 0;

    end_case;

end_if;
(* FINE GESTIONE DEL COMAMDO DI RESET *)


(*-------------------------------------------*)
(* GESTIONE DEL COMANDO DI ABILITAZIONE ASSE *)
(*-------------------------------------------*)
if Gst_CanMotor[node_id].ENABLE then
    Gst_CanMotor[node_id].STATUS := 0;

    case Gst_CanMotor[node_id].FAS_ENAB of
    
        0:  

            if ((Gst_CanMotor[node_id].TPDO_SW and 16#07) <> 0) then
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#100;    (* SETTA HALT *)
            end_if;

            if ((Gst_CanMotor[node_id].TPDO_SW and 16#8) <> 0) then
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#80;    (* FAULT RESET *)
            end_if;
            Gst_CanMotor[node_id].FAS_ENAB := 1;                        (* INIZIO FASI DI ABILITAZIONE DEL DRIVER *)

        1:
            Gst_CanMotor[node_id].WAIT_REG := Time_SinceSystemBoot;

			if Gst_CanMotor[node_id].DevType = 2 then
			    Gst_CanMotor[node_id].RPDO_CW     := 16#70;            (* PRESET DRIVE IN HALT       *)
			else
	            Gst_CanMotor[node_id].RPDO_CW := 0;
			end_if;
            Gst_CanMotor[node_id].FAS_ENAB := 2;

        2:
    
            (* PRESET STATO NON PREVISTO O ERRORE SEQUENZA DI ENABLE *)
            Gst_CanMotor[node_id].FAS_ENAB := 99;
    
            Gst_CanMotor[node_id].TPDO_SW := Gst_CanMotor[node_id].TPDO_SW and 16#07;
            if (Gst_CanMotor[node_id].TPDO_SW = 16#000) then
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#6; (* ENABLE VOLTAGE + QUICK STOP *)
                Gst_CanMotor[node_id].FAS_ENAB := 2;            
            end_if;
    
            if (Gst_CanMotor[node_id].TPDO_SW = 16#01) then
                (* SWITCH ON *)
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#1;
                Gst_CanMotor[node_id].FAS_ENAB := 2;            
            end_if;
    
            if (Gst_CanMotor[node_id].TPDO_SW = 16#03) then
                (* ENABLE OPERATION *)
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#8;
                Gst_CanMotor[node_id].FAS_ENAB := 2;            
            end_if;
    
            if (Gst_CanMotor[node_id].TPDO_SW = 16#07) then
                Gst_CanMotor[node_id].ENABLED := true;
                Gst_CanMotor[node_id].ENABLE := false;
                Gst_CanMotor[node_id].FAS_ENAB := 0;            
            end_if;
    
            if ( (Time_SinceSystemBoot - Gst_CanMotor[node_id].WAIT_REG) > t#10000ms) then
            	Gst_CanMotor[node_id].FAS_ENAB := 99;
            end_if;

        99:
            (* SET ERRORE NELLA SEQUENZA DI ABILITAZIONE ASSI *)
            Gst_CanMotor[node_id].RPDO_CW   := Gst_CanMotor[node_id].RPDO_CW  and not 16#0F or 16#180;            (* RESET DELLA CONTROL WORD + SET NO QUICK STOP *)
            Gst_CanMotor[node_id].STATUS    := 3;
            Gst_CanMotor[node_id].FAS_ENAB  := 0;            
            Gst_CanMotor[node_id].ENABLE    := false;

    end_case;
end_if;
    
(*----------------------------------------------*)
(* GESTIONE DEL COMANDO DI DISABILITAZIONE ASSE *)
(*----------------------------------------------*)
if Gst_CanMotor[node_id].DISABLE then
    Gst_CanMotor[node_id].STATUS := 0;

    case Gst_CanMotor[node_id].FAS_DISAB of
    
        0:
            Gst_CanMotor[node_id].FAS_ENAB    := 0; (* STOP FASI DI ABILITAZIONE DEL DRIVER *)
            Gst_CanMotor[node_id].ENABLE      := false;
            Gst_CanMotor[node_id].ENABLED     := false;
            Gst_CanMotor[node_id].TPDO_SW     := Gst_CanMotor[node_id].TPDO_SW and 16#6FF;
            Gst_CanMotor[node_id].RPDO_CW     := Gst_CanMotor[node_id].RPDO_CW and 16#0070;           (* SET HALT + QUICK STOP *)
            Gst_CanMotor[node_id].FAS_DISAB   := 2;
            Gst_CanMotor[node_id].WAIT_REG    := Time_SinceSystemBoot;
    
        2:
            Gst_CanMotor[node_id].TPDO_SW := Gst_CanMotor[node_id].TPDO_SW and 16#0F;
            if ( Gst_CanMotor[node_id].TPDO_SW = 16#00) then
    
                Gst_CanMotor[node_id].FAS_ENAB      := 0;   Gst_CanMotor[node_id].ENABLE     := false;
                Gst_CanMotor[node_id].FAS_MOV       := 0;   Gst_CanMotor[node_id].MOV        := false;
    
                Gst_CanMotor[node_id].FAS_DISAB     := 0;
                Gst_CanMotor[node_id].ENABLED       := false;
                Gst_CanMotor[node_id].DISABLE       := false;
            end_if;
    
            if ( (Time_SinceSystemBoot - Gst_CanMotor[node_id].WAIT_REG) > t#2000ms) then
                Gst_CanMotor[node_id].FAS_DISAB := 99;
            end_if;
    
        99:
            (* SET ERRORE NELLA SEQUENZA DI ABILITAZIONE ASSI *)
            Gst_CanMotor[node_id].STATUS    := 3;
            Gst_CanMotor[node_id].FAS_DISAB := 0;            
            Gst_CanMotor[node_id].DISABLE    := false;
    
    end_case;
end_if;

(*----------------------------------------------*)
(* Gestione del comandi di movimentazione  asse *)
(*----------------------------------------------*)
if Gst_CanMotor[node_id].MOV then
    Gst_CanMotor[node_id].STATUS := 0;

    case Gst_CanMotor[node_id].FAS_MOV of
    
        0:
            (* Controlla che l'asse sia in coppia ed abilitato. Se il modo operativo non è  *)
            (* positionig allora invia l'SDO per settare il modo altrimenti passa alla fase *)
            (* di movimentazione                                                            *)
                if Gst_CanMotor[node_id].ENABLED then
                    (* Set posizione da raggiungere riportata in impulsi motore *)
                    Gst_CanMotor[node_id].RPDO_POSIZ := lreal_to_dint(Gst_CanMotor[node_id].POSIZ / Gst_CanMotor[node_id].POS_CONV);
                    if ((Gst_CanMotor[node_id].TPDO_SW and 16#0F) = 16#07) then
                        Gst_CanMotor[node_id].FAS_MOV := 2;
                    end_if;
                else
                    Gst_CanMotor[node_id].MOV := false;
                    Gst_CanMotor[node_id].STATUS := 2;
                end_if;
    
        2:
            if ((Gst_CanMotor[node_id].TPDO_SW and 16#0F) = 16#07) then
                (* INVIO COMANDO ED ATTESA DEL  NEW SET POINT ACKN = 1 *)
				(* Take out the Halt command and set NEW setpoint *)
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW and not 16#100 or 16#010;
                if ((Gst_CanMotor[node_id].TPDO_SW and 16#1000) <> 0) then
                    Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW and not(16#010);  (* RESET NEW SET POINT *)
                    Gst_CanMotor[node_id].FAS_MOV := 3;
                end_if;        
            end_if;
   
        3:
            (* ATTESA DEL BIT DI TARGET MACH E ASSE IN COPPIA *)
            if ((Gst_CanMotor[node_id].TPDO_SW and 16#140F) = 16#407) then
                Gst_CanMotor[node_id].MOV := false;
                Gst_CanMotor[node_id].FAS_MOV := 0;
            end_if;
    end_case;
end_if;

(*---------------------------------------------------------------------*)
(* Gestione del comandi di invio tramite SDO della velocità di profilo *)
(*---------------------------------------------------------------------*)
if Gst_CanMotor[node_id].SET_VEL then
    Gst_CanMotor[node_id].STATUS := 0;

    if Gst_CanMotor[node_id].ENABLED then
        Gst_CanMotor[node_id].LEN_RES := 4;
        Gst_CanMotor[node_id].RPDO_VEL := lreal_to_dint(Gst_CanMotor[node_id].VELOCITA * Gst_CanMotor[node_id].VEL_CONV);
	    Gst_CanMotor[node_id].STS := CANopen_WriteSdoCmd(MODE_POLLING, Gst_CanMotor[node_id].ExecStatus, Gst_CanMotor[node_id].CHN, Gst_CanMotor[node_id].NODE_ID, 
	                                                  16#6081, 0, 2000, Gst_CanMotor[node_id].LEN_RES, Gst_CanMotor[node_id].RPDO_VEL);
		if (Gst_CanMotor[node_id].ExecStatus <> 16#80000000) then
			(* READ OPERATIO EXECUTED *)
	        if (Gst_CanMotor[node_id].ExecStatus = 0) then
                Gst_CanMotor[node_id].SET_VEL     := false;
			else
                Gst_CanMotor[node_id].STATUS      := 10;     
                Gst_CanMotor[node_id].SET_VEL     := false;
	        end_if;
	    end_if;
    else
        Gst_CanMotor[node_id].SET_VEL := false;
        Gst_CanMotor[node_id].STATUS := 2;
    end_if;
end_if;




(*--------------------------------------------------------------------*)
(* Gestione del comando homing in modalità 35 , home sul posto        *)
(*--------------------------------------------------------------------*)
if Gst_CanMotor[node_id].HOMESM137 then
    Gst_CanMotor[node_id].STATUS := 0;

    case Gst_CanMotor[node_id].FAS_HOMESM137 of
    
        0:
            (* Controlla che l'asse sia in coppia ed abilitato. Se il modo operativo non è  *)
            (* positionig allora invia l'SDO per settare il modo altrimenti passa alla fase *)
            (* di movimentazione                                                            *)
                if Gst_CanMotor[node_id].ENABLED then
                    if ((Gst_CanMotor[node_id].TPDO_SW and 16#0F) = 16#07) then
                        Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW and not 16#8;  (* PONE IL MOTORE IN DISASSERVITO *)
                        Gst_CanMotor[node_id].FAS_HOMESM137 := 1;
                    end_if;
                end_if;

        1:
            if ((Gst_CanMotor[node_id].TPDO_SW and 16#0F) = 16#03) then
				(*Invio parametro Homing offset prima di lanciare la sequenza di homing *)     
                Gst_CanMotor[node_id].LEN_RES := 1;
                Gst_CanMotor[node_id].LDATA_L := byte_to_dword(6);
			    Gst_CanMotor[node_id].STS := CANopen_WriteSdoCmd(MODE_POLLING, Gst_CanMotor[node_id].ExecStatus, Gst_CanMotor[node_id].CHN, Gst_CanMotor[node_id].NODE_ID, 
			                                                  16#6060, 0, 2000, Gst_CanMotor[node_id].LEN_RES, Gst_CanMotor[node_id].LDATA_L);
				if (Gst_CanMotor[node_id].ExecStatus <> 16#80000000) then
					(* READ OPERATIO EXECUTED *)
					if (Gst_CanMotor[node_id].ExecStatus = 0) then
                        (* Attende che lo stato di operational sia tolto per riasservire il motore *)
                        Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#8;       (* RIASSERVE IL MOTORE *)
                        Gst_CanMotor[node_id].FAS_HOMESM137 := 2;
					else
                        Gst_CanMotor[node_id].STATUS        := 10;     
                        Gst_CanMotor[node_id].FAS_HOMESM137 := 0;
                        Gst_CanMotor[node_id].HOMESM137     := false;
					end_if;
				end_if;
			end_if;

        2:
            if ((Gst_CanMotor[node_id].TPDO_SW and 16#0F) = 16#07) then
                (* INVIO COMANDO ED ATTESA DEL  NEW SET POINT ACKN = 1 *)
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW and not 16#100;  (* TOGLIE HALT *)
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#10;        (* MODALITA' HOMING ATTIVA*)
                Gst_CanMotor[node_id].FAS_HOMESM137 := 3;
            end_if;

        3:
            (* ATTESA DEL BIT DI TARGET E HOMING RAGGIUNTO *)
            if ((Gst_CanMotor[node_id].TPDO_SW and 16#1400) = 16#1000) then  (*BIT 10 E BIT 12*)
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW and not 16#010;   (* RESET COMANDO DI HOMING      *)
                Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW and not 16#8;  (* PONE IL MOTORE IN DISASSERVITO *)
                Gst_CanMotor[node_id].FAS_HOMESM137 := 4;
            end_if;

		4:
            if ((Gst_CanMotor[node_id].TPDO_SW and 16#0F) = 16#03) then
				(*Invio parametro Homing offset prima di lanciare la sequenza di homing *)     
                Gst_CanMotor[node_id].LEN_RES := 1;
                Gst_CanMotor[node_id].LDATA_L := byte_to_dword(1);
			    Gst_CanMotor[node_id].STS := CANopen_WriteSdoCmd(MODE_POLLING, Gst_CanMotor[node_id].ExecStatus, Gst_CanMotor[node_id].CHN, Gst_CanMotor[node_id].NODE_ID, 
			                                                  16#6060, 0, 2000, Gst_CanMotor[node_id].LEN_RES, Gst_CanMotor[node_id].LDATA_L);
				if (Gst_CanMotor[node_id].ExecStatus <> 16#80000000) then
					(* READ OPERATIO EXECUTED *)
					if (Gst_CanMotor[node_id].ExecStatus = 0) then
                        (* Attende che lo stato di operational sia tolto per riasservire il motore *)
                        Gst_CanMotor[node_id].RPDO_CW := Gst_CanMotor[node_id].RPDO_CW or 16#8;       (* RIASSERVE IL MOTORE *)
                        Gst_CanMotor[node_id].FAS_HOMESM137 := 5;
					else
                        Gst_CanMotor[node_id].STATUS        := 10;     
                        Gst_CanMotor[node_id].FAS_HOMESM137 := 0;
                        Gst_CanMotor[node_id].HOMESM137     := false;
					end_if;
				end_if;
			end_if;

        5:
            (* Attende la trasmissione del comando di reset homing in corso *)
            if ((Gst_CanMotor[node_id].TPDO_SW and 16#0F) = 16#07) then
				Gst_CanMotor[node_id].POSIZ := dint_to_lreal(Gst_CanMotor[node_id].TPDO_ACT_POSIZ) * Gst_CanMotor[node_id].POS_CONV;
	            Gst_CanMotor[node_id].FAS_HOMESM137 := 0;
	            Gst_CanMotor[node_id].HOMESM137     := false;
	            Gst_CanMotor[node_id].HOMING_DONE := true; 
			end_if;


    end_case;
end_if;


exit;
end_while;


(*
   CARICA IN SEQUENZA :
   VELOCITA DEL MOVIMENTO
   POSIZIONE DA RAGGIUNGERE
   CONTROL WORD DEL MOVIMENTO
*)

Gst_CanMotor[node_id].RPDO_VEL := lreal_to_dint(Gst_CanMotor[node_id].VELOCITA * Gst_CanMotor[node_id].VEL_CONV);
Gst_CanMotor[node_id].RPDO_POSIZ := lreal_to_dint(Gst_CanMotor[node_id].POSIZ / Gst_CanMotor[node_id].POS_CONV);

if Gst_CanMotor[node_id].INDPOS <> -1 then
	ll_RetCode := MoveMemory(  0, 4,	Gst_CanMotor[node_id].INDPOS,   	Gst_CanMotor[node_id].RPDO_POSIZ,	OB0);
end_if;

if Gst_CanMotor[node_id].INDCW <> -1 then
	ll_RetCode := MoveMemory(  0, 2,	Gst_CanMotor[node_id].INDCW,    	Gst_CanMotor[node_id].RPDO_CW,		OB0);
end_if;

if Gst_CanMotor[node_id].IND_VEL <> -1 then
	ll_RetCode := MoveMemory(  0, 4,	Gst_CanMotor[node_id].IND_VEL,  	Gst_CanMotor[node_id].RPDO_VEL,		OB0);
end_if;


END_FUNCTION_BLOCK
