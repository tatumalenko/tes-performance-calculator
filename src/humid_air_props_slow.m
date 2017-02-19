function out=humid_air_props_slow(P,T,varargin)
%% Determining moist air properties via correlations from previous students
    %  These correlations were chosen initially by the masters student involved
    %  in the project and the student (Dan Dicaire) mentionned in his thesis
    %  these correlations were taken in Perry's Engineering Handbook. I was not
    %  able to confirm the source (I did not see it in this handbook reference)
    %  for the equation that estimates the humidity ratio (? ? ? vs ?
    %  P [kPa]
    %  T [C]
    
    addpath('../lib/coolprop');
    
    Mw = 18.01528;
    Ma = 28.97;
    eps = Mw/Ma;
    T = T + 273.15;

    for i=1:2:length(varargin)
        switch varargin{i}
            case 'RH'
                RH=varargin{i+1}./100;
                RH_in=1;
                y_in=0;
            case 'y'
                y_H2O=varargin{i+1};
                RH_in=0;
                y_in=1;
            case 'model'
                model=varargin{i+1};
        end
    end

    if strcmp(model,'old')
        % Old model (Burcu)
        % Pure component heat capacities of dry air and water (kJ/kg-K)
        Cp_DA = (28.088+(0.00197*T)+(0.48*10^(-5).*T.^2)-(1.965*10^(-9).*T.^3))/28.97;
        Cp_H2O = (32.218+(0.00192.*T)+(1.055*10^(-5).*T.^2)-(3.593*10^(-9).*T.^3))/18.01;
        out.Cp_DA = Cp_DA;
        out.Cp_H2O = Cp_H2O;
        
        if RH_in==0
            H = eps.*(y_H2O./(1-y_H2O));
            RH = H./(0.0043.*exp(0.0629.*((T-273.15))));
            out.RH = RH.*100;
        elseif y_in==0
            H = (RH).*0.0043.*exp(0.0629.*(T-273.15));
            y_H2O = H/(eps+H);
            out.y_H2O = y_H2O;
        end
        
        % Moist air heat capacity (kJ/kg-K)
        Cp_MA = Cp_DA+Cp_H2O.*H;
        
        % Moist air heat (kJ/kg)
        h_MA = Cp_MA.*T;
        
        % Vapor pressure of water in mixture (kPa)
        p_H2O = P.*H./(eps+H);
        
        % Moist air density (kg/m3)
        rho_MA = (P-0.378.*p_H2O)./(287.1e-3.*T);
        %rho_MA = (3.484-1.317.*y).*P./T./1000;
        
        
    elseif strcmp(model,'new')
        %% Determining moist air properties via more sophisticated algorithm:
        %  These calculations use the CoolProp library package obtainable from
        %  by visiting http://www.coolprop.org/fluid_properties/HumidAir.html
        
        rho_MA = zeros(length(T),1);
        H      = zeros(length(T),1);
        Cp_MA  = zeros(length(T),1);
        h_MA   = zeros(length(T),1);
        p_H2O  = zeros(length(T),1);
        T_dp   = zeros(length(T),1);
        T_wb   = zeros(length(T),1);

        if RH_in==1
            y_H2O = zeros(length(T),1);
        elseif y_in==1
            RH = zeros(length(T),1);
        end
 
        for i=1:length(T)

            if RH_in==1
                rho_MA(i) = ...
                    1/CoolProp.HAPropsSI('Vha','Tdb',T(i),'RH',RH(i),'P',1000.*P);
                H(i)    = ...
                    CoolProp.HAPropsSI('W','Tdb',T(i),'RH',RH(i),'P',1000.*P);
                Cp_MA(i)  = ...
                    CoolProp.HAPropsSI('Cha','Tdb',T(i),'RH',RH(i),'P',1000.*P)./1000;
                y_H2O(i)  = ...
                    CoolProp.HAPropsSI('Y','Tdb',T(i),'RH',RH(i),'P',1000.*P);
                h_MA(i) = ...
                    CoolProp.HAPropsSI('Hha','Tdb',T(i),'RH',RH(i),'P',1000.*P)./1000;
                T_wb(i) = ...
                    CoolProp.HAPropsSI('Twb','Tdb',T(i),'RH',RH(i),'P',1000.*P)-273.15;
                T_dp(i) = ...
                    CoolProp.HAPropsSI('Tdp','Tdb',T(i),'RH',RH(i),'P',1000.*P)-273.15;
                p_H2O(i) = ...
                    CoolProp.HAPropsSI('Pw','Tdb',T(i),'RH',RH(i),'P',1000.*P)./1000;
                
                out.T_dp = T_dp;
                out.T_wb = T_wb;
            elseif y_in==1
                rho_MA(i) = ...
                    1/CoolProp.HAPropsSI('Vha','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P);
                H(i)    = ...
                    CoolProp.HAPropsSI('W','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P)./1000;
                Cp_MA(i)  = ...
                    CoolProp.HAPropsSI('Cha','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P)./1000;
                RH(i)  = ...
                    CoolProp.HAPropsSI('RH','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P).*100;
                h_MA(i) = ...
                    CoolProp.HAPropsSI('Hha','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P)./1000;
                p_H2O(i) = ...
                    CoolProp.HAPropsSI('P_w','T_db',T(i),'Y',y_H2O(i),'P',1000.*P)./1000;
            end
        end
    end
    out.T   = T;
    out.P   = P;

    out.p_H2O   = p_H2O;
    out.H       = H; % humidity ratio (kg_w/kg_a)
    out.rho_MA  = rho_MA; % mixture density (%)
    out.h_MA    = h_MA;
    out.Cp_MA   = Cp_MA; % mixture specific heat capacity (kJ/kg-K)

    out.RH      = RH.*100; % relative humidity (%)
    out.y_H2O   = y_H2O; % molar fraction of water in mixture (mol_w/mol)
end