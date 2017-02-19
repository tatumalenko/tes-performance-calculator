function out=humid_air_tes(ColumnVolume,dt,VolRate,Ptot,Tin,Tout,Thum,RHin,RHout,modelname,filepath)
    if length(RHin)==1
        RHin= repmat(RHin,length(dt),1);
        T1 = repmat(Thum(1),length(dt),1);
    end
    % using Tin and Tout as the inputs with RHin and RHout isnt true because
    % Thum is the actualy Tout and Tin was the value we registered in bypass
    HAin=humid_air_props(Ptot,Thum,'RH',RHin,'model',modelname);
    HAout=humid_air_props(Ptot,Thum,'RH',RHout,'model',modelname);
    %HAav=humid_air_props(Ptot,(Tin+Tout)/2,'RH',(RHin+RHout)/2,'model','new');
    %HAav=humid_air_props(Ptot,(Tin+Tout)/2,'H',(HAin.H+HAout.H)/2,'model',modelname);
    HA3=humid_air_props(Ptot,Tout,'H',HAout.H,'model',modelname);
    %  ...
    %dMassMA=dt./60.*VolRate.*HAav.rho_MA; %[(min)x(m3DA/min)x(kgMA/m3DA)]
    dMassDA=dt./60.*VolRate.*1.2929.*273.15./(Tin+273.15);
    %dMassDA=dt./60.*VolRate.*CoolProp.PropsSI('Dmass','T',T+273.15,'P',Ptot,'Air');
    dMassMA=(1+HAout.H).*dMassDA;
    
    % ...
    %dHeatMA=dMassMA.*HAav.Cp_MA.*(Tout-Tin); %[(kg)x(J/kg/K)x(K)=(J)]:
    %dHeatMA=dMassMA.*(HA3.h_MA - HAin.h_MA);
    dHeatMA=dMassMA.*(HA3.Cp_MA.*Tout-HAin.Cp_MA.*Tin); 

    dEnergyDensity=dHeatMA./ColumnVolume./3.6e3; % [(kJ)x(1/m3)x((1/3.6e3) kW-h/1 kJ)= (kW-h)]
   
    % can it be dMassDA.*(HAin.H - HAout.H) [(kgDA)x(kgHA/kgDA - kgHA/kgDA)]:
    dAdsWater=dMassDA.*(HAin.H - HAout.H);

    %out.HAav=HAav;
    out.HAin=HAin;
    out.HAout=HAout;
    out.dEnergyDensity=dEnergyDensity;
    out.dHeat=dHeatMA;
    out.dAdsWater=dAdsWater;
    out.EnergyDensity=sum(dEnergyDensity);
    out.Heat=sum(dHeatMA);
    out.AdsWater=sum(dAdsWater);
    
    out.Tin=Tin;
    out.Tout=Tout;
    out.RHin=RHin;
    out.RHout=RHout;
    out.filepath=filepath;
    out.model=modelname;
    
    expr=regexpi(out.filepath,'\w*C ','match');
    out.Tregen=str2double(expr{1}(3:end-2));
    
    results.T =out.Tregen;
    results.RH   = RHin(1);
    results.model = modelname;
    results.EnergyDensity=out.EnergyDensity;
    
    assignin('base','out',out)
    assignin('base','results',results)
end