(*[[
    UserText1= "V15.7",
]]*)
FUNCTION_BLOCK Fb_AnalogPotentiometer
(*
F ***************************************************************************************
F * File name    : Fb_AnalogPotentiometer.st                                            *
F * Description  : External override potentiometer connected at analog input, with step *
F *                configuration and delay time to prevent undesired little variation.  *
F ***************************************************************************************
F * Product line : OpenControl                                                          *
F * Enviroment   : PLC Application                                                      *
F * Component    :                                                                      *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F *   Author       date      comments                                                   *
F *                                                                                     *
F *   Mazzocco     27-04-10  Function block creation                                    *
F *                                                                                     *
F * ----------------------------------------------------------------------------------- *
F *                                                                                     *
F * Input        :  iiMaxInp            INT                                             *
F *                     Maximum input value                                             *
F *                                                                                     *
F *                 iiMinInp            INT                                             *
F *                     Minimum input value                                             *
F *                                                                                     *
F *                 iiMaxOut            INT                                             *
F *                     Maximum output value                                            *
F *                                                                                     *
F *                 iiMinOut            INT                                             *
F *                     Minimum output value                                            *
F *                                                                                     *
F *                 iiStepOut           INT                                             *
F *                     Minimum variation for output value (in output signal scale)     *
F *                                                                                     *
F *                 iiStepAct           INT                                             *
F *                     Minimum variation in output signal scale that activate the      *
F *                     potentiometer                                                   *
F *                                                                                     *
F *                 iiDelay             TIME                                            *
F *                     Dealy to leave active the potentiometer when the variation are  *
F *                     little of minimum iiStepAct                                     *
F *                                                                                     *
F *                 iiValue             INT                                             *
F *                     Input value (analog potentiometer)                              *
F *                                                                                     *
F * Output       :  oiValue             INT                                             *
F *                     Output value (new override)                                     *
F *                                                                                     *
F *                 oError              BOOL                                            *
F *                     Scale value wrong (minimum value bigger then maximum or         *
F *                     division by zero)                                               *
F *                                                                                     *
F * Global used  :      Not used                                                        *
F *                                                                                     *
F ***************************************************************************************
*)

(* Example for program use
VAR
	Fb_1AnPot	:Fb_AnalogPotentiometer;	\* External override potentiometer connected at analog input */
END_VAR

\* External override potentiometer connected to analog input */
Fb_1AnPot(
	iiMaxInp	:= 2048,		\* IN	INT		Maximum input value */
	iiMinInp	:= 0,			\* IN	INT		Minimum input value */
	iiMaxOut	:= 10000,		\* IN	INT		Maximum output value */
	iiMinOut	:= 0,			\* IN	INT		Minimum output value */
	iiStepOut	:= 100,			\* IN	INT		Minimum variation for output value (in output signal scale) */
	iiStepAct	:= 200,			\* IN	INT		Minimum variation in output signal scale that activate the potentiometer */
	iiDelay		:= t#3000ms,	\* IN	TIME	Dealy to leave active the potentiometer when the variation are little of minimum iiStepAct */
	iiValue		:= liAnPot?,	\* IN	INT		Input value (analog potentiometer) */
	oiValue		=> liNewOvr?,	\* OUT	INT		Output value (new override) */
	oError		=> lErrMsg?);	\* OUT	BOOL	Scale value wrong (minimum value bigger then maximum or division by zero) *)

VAR_INPUT
	iiMaxInp	: int;	(* Maximum input value *)
	iiMinInp	: int;	(* Minimum input value *)
	iiMaxOut	: int;	(* Maximum output value *)
	iiMinOut	: int;	(* Minimum output value *)
	iiStepOut	: int;	(* Minimum variation for output value (in output signal scale) *)
	iiStepAct	: int;	(* Minimum variation in output signal scale that activate the potentiometer *)
	iiDelay		:TIME;	(* Dealy to leave active the potentiometer when the variation are little of minimum iiStepAct *)
	iiValue		: int;	(* Input value (analog potentiometer) *)
END_VAR

VAR_OUTPUT
	oiValue		: int;	(* Output value (new override) *)
	oError		: bool;	(* Scale value wrong (min value bigger then max or division by zero) *)
END_VAR

VAR
	liMaxInp	: int;	(* Maximum input value *)
	liMinInp	: int;	(* Minimum input value *)
	liMaxOut	: int;	(* Maximum output value *)
	liMinOut	: int;	(* Minimum output value *)
	liStepOut	: int;	(* Minimum variation for output value (in output signal scale) *)
	liOutNum	: int;	(* Number of output value *)
	liStepInp	: int;	(* Input step corrispondent to the configured output step *)
	liValue		: int;	(* Output value continuous calculation *)
	liDiff		: int;	(* Difference between new calculated value and active output value *)
	TON_Disable	:TON;	(* Potentiometer disable delay *)
END_VAR



(* Scale calculation, only when the configuration change *)
if iiMaxInp<>liMaxInp or iiMinInp<>liMinInp or iiMaxOut<>liMaxOut or iiMinOut<>liMinOut or
iiStepOut<>liStepOut or liOutNum=0 or oError then

	liMaxInp	:= iiMaxInp;
	liMinInp	:= iiMinInp;
	liMaxOut	:= iiMaxOut;
	liMinOut	:= iiMinOut;
	liStepOut	:= iiStepOut;

	(* Compare minimum value with maximum value and division by zero *)
	if liMaxInp<liMinInp or liMaxOut<liMinOut or liStepOut=0 then
		oError	:= true;
	else

		(* Number of output value calculation *)
		liOutNum	:= (liMaxOut - liMinOut) / liStepOut;

		if liOutNum=0 then
			oError	:= true;
		else
			(* Input step calculation *)
			liStepInp	:= (liMaxInp - liMinInp) / liOutNum;

			if liStepInp=0 then
				oError	:= true;
			else
				oError	:= false;
			end_if;

		end_if;

	end_if;

end_if;



if not oError then

	(* Output value continuous calculation *)
	liValue	:= LIMIT(liMinOut, ((iiValue - liMinInp) / liStepInp * liStepOut) + liMinOut, liMaxOut);

	(* Output difference calculation *)
	liDiff	:= oiValue - liValue;

end_if;



(* Potentiometer disable delay *)
TON_Disable(IN := ABS(liDiff)<ABS(iiStepAct), PT := iiDelay);



(* New output value activation *)
if not TON_Disable.Q and not oError then
	oiValue	:= liValue;
end_if;


END_FUNCTION_BLOCK
