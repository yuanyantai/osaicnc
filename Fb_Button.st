(*[[
    UserText1= "V15.7",
]]*)
FUNCTION_BLOCK Fb_Button

(*
F ***************************************************************************************
F * File name    : FB_Button.st                                                         *
F * Description  : Button or selector interface with delay and manteined or On/Off      *
F *                functionality                                                        *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author        date        comments                                                *
F *                                                                                     *
F *   Scapolan      08-02-17    Creation Function Block                                 *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iFbEnable	BOOL	Function block enable							*
F *                 iButOn		BOOL	Physical button (ON request)					*
F *                 iActOn		BOOL													*
F *                     Flag to check actual condition (ON), used only with iMode=TRUE  *
F *                     to choose the OFF or ON request                                 *
F *                                                                                     *
F *                 iMode		BOOL	Working mode									*
F *                     FALSE Manteined, ON request pressing button, OFF request        *
F *                           releasing button                                          *
F *                     TRUE  ON/OFF, press button and request change from ON to OFF or *
F *                           from OFF to ON, release button and nothing appen          *
F *                                                                                     *
F * Input/Output :  ioOn                 BOOL                                           *
F *                     ON request, can be resetted from the PLC                        *
F *                                                                                     *
F *                 ioOff                BOOL                                           *
F *                     OFF request, can be resetted from the PLC                       *
F *                                                                                     *
F * Global used  :      not used                                                        *
F *                                                                                     *
F * Attention    :  Use this FB directly in the logic program, don't inside a cycle     *
F *                 (IF, FOR, etc.), is the same for all the macro function block with  *
F *                 the iFbEnable input.                                                *
F *                                                                                     *
F ***************************************************************************************

    Example for program use

VAR
	FB_1Button	:FB_Button;	\* Button or selector interface with delay and manteined or On/Off functionality */
END_VAR

\* Button or selector interface with delay and manteined or On/Off functionality */
FB_1Button(
	iFbEnable	:= ,			\* IN	BOOL	Function block enable */
	iButOn		:= I_But_?,		\* IN	BOOL	Physical button (ON request) */
	iActOn		:= lMemButOn,	\* IN	BOOL	Flag to check actual condition (ON), used only with iMode=TRUE to choose the OFF or ON request */
	iMode		:= ,			\* IN	BOOL	Working mode:
									FALSE Manteined, ON request pressing button, OFF request releasing button
									TRUE  ON/OFF, press button and request change from ON to OFF or from OFF to ON, release button and nothing appen */
	ioOn		:= lButOn,		\* I/O	BOOL	ON request, can be resetted from the PLC */
	ioOff		:= lButOff);	\* I/O	BOOL	OFF request, can be resetted from the PLC *)

VAR_INPUT
	iFbEnable	: bool;	(* Function block enable *)
	iButOn		: bool;	(* Physical button *)
	iActOn		: bool;	(* Flag to check actual condition (ON), used only with iMode=TRUE to choose the OFF or ON request *)
	iMode		: bool;	(* Working mode:	FALSE Manteined, ON request pressing button, OFF request releasing button
											TRUE  ON/OFF, press button and request change from ON to OFF or from OFF to ON, release button and nothing appen *)
END_VAR

VAR_IN_OUT
	ioOn	: bool;	(* ON request, can be resetted from the PLC *)
	ioOff	: bool;	(* OFF request, can be resetted from the PLC *)
END_VAR

VAR
	RT_But		:R_TRIG;	(* Press button trigger *)
	lReqOn		: bool;		(* On request memory *)
	lReqOff		: bool;		(* Off request memory *)
	RT_On		:R_TRIG;	(* On request output *)
	RT_Off		:R_TRIG;	(* Off request output *)
END_VAR



(* Press button trigger *)
RT_But(CLK := iButOn);

if iFbEnable then

	if iMode then
		(* ON/OFF mode, press button and request change from ON to OFF or from OFF to ON,
			release button and nothing appen *)
	
		(* Pressing button check actual condition and store the ON/OFF request *)
		if RT_But.Q then
			if iActOn then
				(* Off request *)
				lReqOn	:= false;
				lReqOff	:= true;
			else
				(* On request *)
				lReqOn	:= true;
				lReqOff	:= false;
			end_if;
		end_if;
	
		(* Releasing button delete request *)
		if not iButOn then
			lReqOn	:= false;
			lReqOff	:= false;
		end_if;
	else
		(* Manteined mode, ON request pressing button, OFF request releasing button *)		
		lReqOn	:= iButOn;		(* if button press lRepOn=true, lReqOff=false *)
		lReqOff	:= not iButOn;	(* if button release lRepOn=false, lReqOff=true *)
	end_if;

else
	lReqOn	:= false;
	lReqOff	:= false;
	ioOn	:= false;
	ioOff	:= false;
end_if;


(* On request after delay *)
RT_On(CLK := not lReqOff and lReqOn);
if RT_On.Q then
	ioOn	:= true;
	ioOff	:= false;
end_if;

(* Off request after delay *)
RT_Off(CLK := lReqOff and not lReqOn);
if RT_Off.Q then
	ioOn	:= false;
	ioOff	:= true;
end_if;


END_FUNCTION_BLOCK
