% VARIABLES
% Tdb (dry bulb temperature) and Tdp(dew point temperature) in C
% w (humidity ratio) in kg/kg of dry air
% RH (relative humidity) in %
% h (enthalpy) in kJ/kg of dry air
% v (specific volume) in m3/kg of dry air
% Twb (wet bulb temperature) in C
% P (atmospheric pressure) in kPa

function out=humid_air_correlations(Tdb,RH,P)
    c_air = 1006; %J/kg, value from ASHRAE 2013 Fundamentals eq. 32
    hlg = 2501000; %J/kg, value from ASHRAE 2013 Fundamentals eq. 32
    cw  = 1860; %J/kg, value from ASHRAE 2013 Fundamentals eq. 32
    
    % w calculation from Tdb and phi
    Pws=Saturation_pressure(Tdb);
    Pw=RH/100*Pws;
    w=0.621945*Pw/(P-Pw);
    
    % h calculation from Tdb and w
    h=c_air*Tdb+w*(hlg+cw*Tdb)/1000;
    
    % v calculation from Tdb and w
    v=0.287042*(Tdb+273.15)*(1+1.607858*w)/P;
    
    
    % dew point calculation from w
    % pw=(P*w)/(0.621945+w); % water vapor partial pressure in kPa
    alpha=log(Pw);
    Tdp=6.54 + 14.526*alpha+0.7389*(alpha^2)+0.09486*(alpha^3)+0.4569*(Pw^0.1984); % valid for Tdp between 0 C and 93 C
    
    % Twb calculation from Tdb and 
    % Note: this Twb calc. equations are good for patm=101325 Pa only. 
    if abs(Tdb - Tdp) < .001, Twb=Tdb;return;end
    options=optimset('LargeScale','off','Display','off');
    [y,~,~]=fsolve(@Iteration_function_3, Tdb,options);Twb=y(1);
    if Twb > Tdb,Twb=Tdb;end
    if Twb < Tdp,Twb=Tdp;end   
    
    function [Pws] = Saturation_pressure(Tdb) %saturated water vapor pressure ASHRAE 2013 fundamentals eq. 6
        T=Tdb+273.15;
        Pws=exp(-(5.8002206e3)/T+1.3914993+-(4.8640239e-2)*T+(4.1764768e-5)*(T^2)-(1.4452093e-8)*(T^3)+6.5459673*log(T)); %in Pa valid for 0 to 200C
        Pws=Pws/1000; % in kPa
    end

    function result = Iteration_function_3(y) %calc Twb from Tdb and w using ASHRAE 2013 fundamentals eq. 35
        Twb_as=y(1);
        Pws_as=Saturation_pressure(Twb_as);
        ws=0.621945*Pws_as/(P-Pws_as);
        w_as= ((hlg-2.326e3*Twb_as)*ws-c_air*(Tdb-Twb_as))/(hlg+cw*Tdb-4.186e3*Twb_as);
        result=(w-w_as)*1000;
    end

    out.Tdb=Tdb;
    out.w=w; 
    out.RH=RH;
    out.h=h;
    out.Tdp=Tdp;
    out.v=v;
    out.Twb=Twb;
    out.Tdp=Tdp;
    out.Pws=Pws;
    
    P=P*1000;
    Pws1=exp(-(5.8002206e3)/(Tdb+273.15)+1.3914993+-(4.8640239e-2)*(Tdb+273.15)+(4.1764768e-5)*((Tdb+273.15)^2)-(1.4452093e-8)*((Tdb+273.15)^3)+6.5459673*log(Tdb+273.15));
    Pw1=RH/100*Pws1;
    w1=0.621945*Pw1/(P-Pw1);
    
    out.w1=w1;
end