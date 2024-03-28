(*[[
    UserText1= "V15.7",
]]*)
FUNCTION F_Get_Sys_Type
	#IMPORT  "Gv_AllProcess.gvl"

var
	ll_RetCode			: dword;
	lb_Board_type		: byte;						(* Board type code *)
end_var

	(* Get current board of system, the system can use max 2 board 0 and 1 *)
	(* Board 0 *)
	ll_RetCode := GetBoardInfo(0, gSt_BoardInfo_0);
	lb_Board_type := Dword_to_byte(SHR(gSt_BoardInfo_0.BusDescr1, 8));
	if    (lb_Board_type = DGT_BUS_SERCOS) 			then gBoard_0_DGT_BUS_SERCOS 		:= true;
	elsif (lb_Board_type = DGT_BUS_MECHATROLINK)	then gBoard_0_DGT_BUS_MECHATROLINK	:= true;
	elsif (lb_Board_type = DGT_BUS_OSWIRE)			then gBoard_0_DGT_BUS_OSWIRE		:= true;
	elsif (lb_Board_type = DGT_BUS_CANOPEN)			then gBoard_0_DGT_BUS_CANOPEN		:= true;
	elsif (lb_Board_type = DGT_BUS_PROFIBUS)		then gBoard_0_DGT_BUS_PROFIBUS		:= true;
	elsif (lb_Board_type = DGT_BUS_ETN)				then gBoard_0_DGT_BUS_ETN			:= true;
	elsif (lb_Board_type = DGT_BUS_ETHERCAT)		then gBoard_0_DGT_BUS_ETHERCAT		:= true;
	end_if;

	lb_Board_type := Dword_to_byte(SHR(gSt_BoardInfo_0.BusDescr2, 8));
	if    (lb_Board_type = DGT_BUS_SERCOS) 			then gBoard_0_DGT_BUS_SERCOS 		:= true;
	elsif (lb_Board_type = DGT_BUS_MECHATROLINK)	then gBoard_0_DGT_BUS_MECHATROLINK	:= true;
	elsif (lb_Board_type = DGT_BUS_OSWIRE)			then gBoard_0_DGT_BUS_OSWIRE		:= true;
	elsif (lb_Board_type = DGT_BUS_CANOPEN)			then gBoard_0_DGT_BUS_CANOPEN		:= true;
	elsif (lb_Board_type = DGT_BUS_PROFIBUS)		then gBoard_0_DGT_BUS_PROFIBUS		:= true;
	elsif (lb_Board_type = DGT_BUS_ETN)				then gBoard_0_DGT_BUS_ETN			:= true;
	elsif (lb_Board_type = DGT_BUS_ETHERCAT)		then gBoard_0_DGT_BUS_ETHERCAT		:= true;
	end_if;

	lb_Board_type := Dword_to_byte(SHR(gSt_BoardInfo_0.BusDescr3, 8));
	if    (lb_Board_type = DGT_BUS_SERCOS) 			then gBoard_0_DGT_BUS_SERCOS 		:= true;
	elsif (lb_Board_type = DGT_BUS_MECHATROLINK)	then gBoard_0_DGT_BUS_MECHATROLINK	:= true;
	elsif (lb_Board_type = DGT_BUS_OSWIRE)			then gBoard_0_DGT_BUS_OSWIRE		:= true;
	elsif (lb_Board_type = DGT_BUS_CANOPEN)			then gBoard_0_DGT_BUS_CANOPEN		:= true;
	elsif (lb_Board_type = DGT_BUS_PROFIBUS)		then gBoard_0_DGT_BUS_PROFIBUS		:= true;
	elsif (lb_Board_type = DGT_BUS_ETN)				then gBoard_0_DGT_BUS_ETN			:= true;
	elsif (lb_Board_type = DGT_BUS_ETHERCAT)		then gBoard_0_DGT_BUS_ETHERCAT		:= true;
	end_if;

	lb_Board_type := Dword_to_byte(SHR(gSt_BoardInfo_0.BusDescr4, 8));
	if    (lb_Board_type = DGT_BUS_SERCOS) 			then gBoard_0_DGT_BUS_SERCOS 		:= true;
	elsif (lb_Board_type = DGT_BUS_MECHATROLINK)	then gBoard_0_DGT_BUS_MECHATROLINK	:= true;
	elsif (lb_Board_type = DGT_BUS_OSWIRE)			then gBoard_0_DGT_BUS_OSWIRE		:= true;
	elsif (lb_Board_type = DGT_BUS_CANOPEN)			then gBoard_0_DGT_BUS_CANOPEN		:= true;
	elsif (lb_Board_type = DGT_BUS_PROFIBUS)		then gBoard_0_DGT_BUS_PROFIBUS		:= true;
	elsif (lb_Board_type = DGT_BUS_ETN)				then gBoard_0_DGT_BUS_ETN			:= true;
	elsif (lb_Board_type = DGT_BUS_ETHERCAT)		then gBoard_0_DGT_BUS_ETHERCAT		:= true;
	end_if;

	
	(* Board 1 *)
	ll_RetCode := GetBoardInfo(1, gSt_BoardInfo_1);
	lb_Board_type := Dword_to_byte(SHR(gSt_BoardInfo_1.BusDescr1, 8));                                      
	if    (lb_Board_type = DGT_BUS_SERCOS) 			then gBoard_1_DGT_BUS_SERCOS 		:= true;          
	elsif (lb_Board_type = DGT_BUS_MECHATROLINK)	then gBoard_1_DGT_BUS_MECHATROLINK	:= true;        
	elsif (lb_Board_type = DGT_BUS_OSWIRE)			then gBoard_1_DGT_BUS_OSWIRE		:= true;        
	elsif (lb_Board_type = DGT_BUS_CANOPEN)			then gBoard_1_DGT_BUS_CANOPEN		:= true;        
	elsif (lb_Board_type = DGT_BUS_PROFIBUS)		then gBoard_1_DGT_BUS_PROFIBUS		:= true;
	elsif (lb_Board_type = DGT_BUS_ETN)				then gBoard_1_DGT_BUS_ETN			:= true;
	elsif (lb_Board_type = DGT_BUS_ETHERCAT)		then gBoard_1_DGT_BUS_ETHERCAT		:= true;        
	end_if;                                                                                                 
                                                                                                                
	lb_Board_type := Dword_to_byte(SHR(gSt_BoardInfo_1.BusDescr2, 8));                                      
	if    (lb_Board_type = DGT_BUS_SERCOS) 			then gBoard_1_DGT_BUS_SERCOS 		:= true;          
	elsif (lb_Board_type = DGT_BUS_MECHATROLINK)	then gBoard_1_DGT_BUS_MECHATROLINK	:= true;        
	elsif (lb_Board_type = DGT_BUS_OSWIRE)			then gBoard_1_DGT_BUS_OSWIRE		:= true;        
	elsif (lb_Board_type = DGT_BUS_CANOPEN)			then gBoard_1_DGT_BUS_CANOPEN		:= true;        
	elsif (lb_Board_type = DGT_BUS_PROFIBUS)		then gBoard_1_DGT_BUS_PROFIBUS		:= true;
	elsif (lb_Board_type = DGT_BUS_ETN)				then gBoard_1_DGT_BUS_ETN			:= true;
	elsif (lb_Board_type = DGT_BUS_ETHERCAT)		then gBoard_1_DGT_BUS_ETHERCAT		:= true;        
	end_if;                                                                                                 
                                                                                                                
	lb_Board_type := Dword_to_byte(SHR(gSt_BoardInfo_1.BusDescr3, 8));                                      
	if    (lb_Board_type = DGT_BUS_SERCOS) 			then gBoard_1_DGT_BUS_SERCOS 		:= true;          
	elsif (lb_Board_type = DGT_BUS_MECHATROLINK)	then gBoard_1_DGT_BUS_MECHATROLINK	:= true;        
	elsif (lb_Board_type = DGT_BUS_OSWIRE)			then gBoard_1_DGT_BUS_OSWIRE		:= true;        
	elsif (lb_Board_type = DGT_BUS_CANOPEN)			then gBoard_1_DGT_BUS_CANOPEN		:= true;        
	elsif (lb_Board_type = DGT_BUS_PROFIBUS)		then gBoard_1_DGT_BUS_PROFIBUS		:= true;
	elsif (lb_Board_type = DGT_BUS_ETN)				then gBoard_1_DGT_BUS_ETN			:= true;
	elsif (lb_Board_type = DGT_BUS_ETHERCAT)		then gBoard_1_DGT_BUS_ETHERCAT		:= true;        
	end_if;                                                                                                 
                                                                                                                
	lb_Board_type := Dword_to_byte(SHR(gSt_BoardInfo_1.BusDescr4, 8));                                      
	if    (lb_Board_type = DGT_BUS_SERCOS) 			then gBoard_1_DGT_BUS_SERCOS 		:= true;          
	elsif (lb_Board_type = DGT_BUS_MECHATROLINK)	then gBoard_1_DGT_BUS_MECHATROLINK	:= true;        
	elsif (lb_Board_type = DGT_BUS_OSWIRE)			then gBoard_1_DGT_BUS_OSWIRE		:= true;        
	elsif (lb_Board_type = DGT_BUS_CANOPEN)			then gBoard_1_DGT_BUS_CANOPEN		:= true;        
	elsif (lb_Board_type = DGT_BUS_PROFIBUS)		then gBoard_1_DGT_BUS_PROFIBUS		:= true;
	elsif (lb_Board_type = DGT_BUS_ETN)				then gBoard_1_DGT_BUS_ETN			:= true;
	elsif (lb_Board_type = DGT_BUS_ETHERCAT)		then gBoard_1_DGT_BUS_ETHERCAT		:= true;        
	end_if;
	
END_FUNCTION
