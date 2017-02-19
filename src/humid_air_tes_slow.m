function out=humid_air_tes_slow(ColumnVolume,dt,VolRate,Ptot,Tin,Tout,Thum,RHin,RHout)

    addpath('../lib/coolprop');

    if length(RHin)==1
        RHin=repmat(RHin,length(dt),1)./100;
    end
    % using Tin and Tout as the inputs with RHin and RHout isnt true because
    % Thum is the actualy Tout and Tin was the value we registered in bypass
    HAav=humid_air_props(Ptot,(Tin+Tout)/2,'RH',(RHin+RHout)/2,'model','new');
    HAin=humid_air_props(Ptot,Thum,'RH',RHin,'model','new');
    HAout=humid_air_props(Ptot,Thum,'RH',RHout,'model','new');


% might need to modify this equation since we have only VolRate of DA like
% Dan did:
dMassMA=dt./60.*VolRate.*HAav.rho_MA; %[(min)x(m3DA/min)x(kgMA/m3DA)] where rho is in 
%dMassDA=dt./60.*VolRate.*HAin.rho_DA; %[(min)x(m3DA/min)x(kgDA/m3DA)] ?

% cheating here again when using Tout and Tin to designate the RHout and
% RHin temperatures:
dHeatMA=dMassMA.*HAav.Cp_MA.*(Tout-Tin); %[(kg)x(J/kg/K)x(K)=(J)]:
dHeatMA1=dMassMA.*(HAout.h_MA - HAin.h_MA);

dEnergyDensity=dHeatMA./ColumnVolume./3.6e3; % [(kJ)x(1/m3)x((1/3.6e3) kW-h/1 kJ)= (kW-h)]
dEnergyDensity1=dHeatMA1./ColumnVolume./3.6e3; % [(kJ)x(1/m3)x((1/3.6e3) kW-h/1 kJ)= (kW-h)]

% can it be dMassDA.*(HAin.H - HAout.H) [(kgDA)x(kgHA/kgDA - kgHA/kgDA)]:
dAdsWater=dMassMA.*(HAin.H - HAout.H);

out.HAav=HAav;
out.HAin=HAin;
out.HAout=HAout;
out.dEnergyDensity=dEnergyDensity;
out.dHeat=dHeatMA;
out.dAdsWater=dAdsWater;
out.EnergyDensity=sum(dEnergyDensity);
out.EnergyDensity1=sum(dEnergyDensity1);
out.Heat=sum(dHeatMA);
out.AdsWater=sum(dAdsWater);

end