function out=humid_air_props(P,T,varargin)
%% Determining moist air properties via correlations from previous students
    %  These correlations were chosen initially by the masters student involved
    %  in the project and the student (Dan Dicaire) mentionned in his thesis
    %  these correlations were taken in Perry's Engineering Handbook. I was not
    %  able to confirm the source (I did not see it in this handbook reference)
    %  for the equation that estimates the humidity ratio 
    %  P [kPa]
    %  T [C]
    M_H2O = 18.01528;
    M_DA = 28.9645;
    M_av = (M_DA + M_H2O)/2;
    R = 8.31451;
    eps = M_H2O/M_DA;
    T = T + 273.15;

    for i=1:2:length(varargin)
        switch varargin{i}
            case 'RH'
                RH=varargin{i+1}./100;
                RH_input=1;
                y_input=0;
                H_input=0;
            case 'y'
                y_H2O=varargin{i+1};
                RH_input=0;
                y_input=1;
                H_input=0;
            case 'model'
                model=varargin{i+1};
            case 'H'
                H=varargin{i+1};
                RH_input=0;
                y_input=0;
                H_input=1;
        end
    end

    if strcmp(model,'Old2')
        % Old model (Burcu)
        % Pure component heat capacities of dry air and water (kJ/kg-K)
        Cp_DA = (28.088+(0.00197*T)+(0.48*10^(-5).*T.^2)-(1.965*10^(-9).*T.^3))/28.97;
        Cp_H2O = (32.218+(0.00192.*T)+(1.055*10^(-5).*T.^2)-(3.593*10^(-9).*T.^3))/18.01;
        out.Cp_DA = Cp_DA;
        out.Cp_H2O = Cp_H2O;
        
        if y_input==1
            H = eps.*(y_H2O./(1-y_H2O));
            RH = H./(0.0043.*exp(0.0629.*((T-273.15))));
            out.RH = RH;
        elseif RH_input==1
            H = (RH).*0.0043.*exp(0.0629.*(T-273.15));
            y_H2O = H/(eps+H);
            out.y_H2O = y_H2O;
            out.RH=RH;
        elseif H_input==1
            RH = H./(0.0043.*exp(0.0629.*((T-273.15))));
            out.RH = RH;
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
        
        
    elseif strcmp(model,'Old4')
        % Uses p_H2Osat taken from Perry 12-5 correlation by Sonntag.
        
        % Pure component heat capacities of dry air and water (kJ/kg-K)
        Cp_DA = (28.088+(0.00197*T)+(0.48*10^(-5).*T.^2)-(1.965*10^(-9).*T.^3))/28.97;
        Cp_H2O = (32.218+(0.00192.*T)+(1.055*10^(-5).*T.^2)-(3.593*10^(-9).*T.^3))/18.01;
        out.Cp_DA = Cp_DA;
        out.Cp_H2O = Cp_H2O;
        
        if y_input==1
            H = eps.*(y_H2O./(1-y_H2O));
            RH = H./(0.0043.*exp(0.0629.*((T-273.15))));
            out.RH = RH;
        elseif RH_input==1
            %H = (RH).*0.0043.*exp(0.0629.*(T-273.15));
            %y_H2O = H/(eps+H);
            p_H2Osat = (1/1000).*exp(-6096.9385.*T.^-1 + 21.2409642 - 2.711193e-2.*T ...
                + 1.673952e-5.*T.^2 + 2.433502.*log(T));
            p_H2O = RH.*p_H2Osat;
            y_H2O = p_H2O./P;
            H = eps.*(y_H2O./(1-y_H2O));
            out.y_H2O = y_H2O;
            out.RH = RH;
        elseif H_input==1
            p_H2Osat = (1/1000).*exp(-6096.9385.*T.^-1 + 21.2409642 - 2.711193e-2.*T ...
                + 1.673952e-5.*T.^2 + 2.433502.*log(T));
            p_H2O = P.*H./(eps + H);
            RH = p_H2O./p_H2Osat;
            out.RH = RH;
            out.H = H;
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
        
     elseif strcmp(model,'Old')
        % Uses p_H2Osat taken from Perry 12-5 correlation by Sonntag.
        
        
        
        if y_input==1
            H = eps.*(y_H2O./(1-y_H2O));
            RH = H./(0.0043.*exp(0.0629.*((T-273.15))));
            p_H2O = P.*H./(eps+H);
            out.RH = RH;
        elseif RH_input==1
            %H = (RH).*0.0043.*exp(0.0629.*(T-273.15));
            %y_H2O = H/(eps+H);
            p_H2Osat = (1/1000).*exp(-6096.9385.*T.^-1 + 21.2409642 - 2.711193e-2.*T ...
                + 1.673952e-5.*T.^2 + 2.433502.*log(T));
            p_H2O = RH.*p_H2Osat;
            y_H2O = p_H2O./P;
            H = eps.*(y_H2O./(1-y_H2O));
            out.y_H2O = y_H2O;
            out.RH = RH;
        elseif H_input==1
            p_H2Osat = (1/1000).*exp(-6096.9385.*T.^-1 + 21.2409642 - 2.711193e-2.*T ...
                + 1.673952e-5.*T.^2 + 2.433502.*log(T));
            p_H2O = P.*H./(eps + H);
            RH = p_H2O./p_H2Osat;
            y_H2O = p_H2O./P;
            out.RH = RH;
            out.H = H;
            out.y_H2O=y_H2O;
        end
        
        
        % Pure component heat capacities of dry air and water (kJ/kg-K)
        Cp_DA  = 1.0653697 - 4.4730851e-4.*T + 9.8719042e-7.*T.^2 - 4.6376809e-10.*T.^3;
        Cp_H2O = 6.564117 - 2.6905819e-2.*T + 5.1820718e-5.*T.^2 - 3.2682964e-8.*T.^3;
        Cp_MA = Cp_DA + Cp_H2O.*H; % Moist air heat capacity (kJ/kg-K)
        
%         M_MA = M_DA.*(1-y_H2O) + M_H2O.*y_H2O;
%         Cp_DA  = 1.03409 - 0.284887e-3.*T + 0.7816818e-6.*T.^2 - 0.4970786e-9.*T.^3 + 0.1077024e-12;
%         Cp_H2O = 1.86910989 - 2.578421578e-4.*(T-0) + 1.941058941e-5.*(T-0).^2;
%         Cp_MA = (1/M_MA).*(Cp_DA.*(1-y_H2O).*M_DA + Cp_H2O.*y_H2O.*M_H2O); % Moist air heat capacity (kJ/kg-K)
        
        out.Cp_DA = Cp_DA;
        out.Cp_H2O = Cp_H2O;
        
        % Moist air heat (kJ/kg)
        h_MA = Cp_MA.*(T-273.15)+2501.*H;
        
        % Moist air density (kg/m3)
        %rho_MA = (P-0.378.*p_H2O)./(287.1e-3.*T);
        z_MA   = 1 + y_H2O.*((1.007840 - 3.4396097e-3.*T)./(1 - 3.4299543e-3.*T) - 1);
        rho_MA = (1./z_MA).*(P./R./T).*((1-y_H2O).*M_DA + y_H2O.*M_H2O);
        
    elseif strcmp(model,'New')
        %% Determining moist air properties via more sophisticated algorithm:
        %  These calculations use the CoolProp library package obtainable from
        %  by visiting http://www.coolprop.org/fluid_properties/HumidAir.html
        
        rho_MA = zeros(length(T),1);
        
        Cp_MA  = zeros(length(T),1);
        h_MA   = zeros(length(T),1);
%         p_H2O  = zeros(length(T),1);
%         T_dp   = zeros(length(T),1);
%         T_wb   = zeros(length(T),1);

        if RH_input==1
            H      = zeros(length(T),1);
            y_H2O = zeros(length(T),1);
        elseif y_input==1
            H      = zeros(length(T),1);
            RH = zeros(length(T),1);
        elseif H_input==1
            y_H2O = zeros(length(T),1);
            RH = zeros(length(T),1);
        end
 
        for i=1:length(T)

            if RH_input==1
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
%                 T_wb(i) = ...
%                     CoolProp.HAPropsSI('Twb','Tdb',T(i),'RH',RH(i),'P',1000.*P)-273.15;
%                 T_dp(i) = ...
%                     CoolProp.HAPropsSI('Tdp','Tdb',T(i),'RH',RH(i),'P',1000.*P)-273.15;
%                 p_H2O(i) = ...
%                     CoolProp.HAPropsSI('Pw','Tdb',T(i),'RH',RH(i),'P',1000.*P)./1000;
%                 
%                 out.T_dp = T_dp;
%                 out.T_wb = T_wb;
                out.y_H2O(i)   = y_H2O(i); % molar fraction of water in mixture (mol_w/mol)
                out.RH(i)=RH(i);
            elseif y_input==1
                rho_MA(i) = ...
                    1/CoolProp.HAPropsSI('Vha','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P);
                H(i)    = ...
                    CoolProp.HAPropsSI('W','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P)./1000;
                Cp_MA(i)  = ...
                    CoolProp.HAPropsSI('Cha','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P)./1000;
                RH(i)  = ...
                    CoolProp.HAPropsSI('RH','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P).*100;
%                 h_MA(i) = ...
%                     CoolProp.HAPropsSI('Hha','Tdb',T(i),'Y',y_H2O(i),'P',1000.*P)./1000;
%                 p_H2O(i) = ...
%                     CoolProp.HAPropsSI('P_w','T_db',T(i),'Y',y_H2O(i),'P',1000.*P)./1000;
                out.RH(i)=RH(i);
            elseif H_input==1
                rho_MA(i) = ...
                    1/CoolProp.HAPropsSI('Vha','Tdb',T(i),'W',H(i),'P',1000.*P);
                Cp_MA(i)  = ...
                    CoolProp.HAPropsSI('Cha','Tdb',T(i),'W',H(i),'P',1000.*P)./1000;
                h_MA(i) = ...
                    CoolProp.HAPropsSI('Hha','Tdb',T(i),'W',H(i),'P',1000.*P)./1000;
                RH(i)  = ...
                    CoolProp.HAPropsSI('RH','Tdb',T(i),'W',H(i),'P',1000.*P);
                
                
                out.RH(i)=RH(i);
                out.h_MA(i)=h_MA(i);
            end
        end
    end
    out.T   = T;
    out.P   = P;

%     out.p_H2O   = p_H2O;
    out.H       = H; % humidity ratio (kg_w/kg_a)
    out.rho_MA  = rho_MA; % mixture density (%)
    out.h_MA    = h_MA; 
    out.Cp_MA   = Cp_MA; % mixture specific heat capacity (kJ/kg-K)
%     out.RH      = RH;

%     out.RH      = RH.*100; % relative humidity (%)
%     out.y_H2O   = y_H2O; % molar fraction of water in mixture (mol_w/mol)
end