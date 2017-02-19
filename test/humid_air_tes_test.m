function y = HumidAirTES_test(ColumnVolume,dt,VolRate,Ptot,Tin,Tout,Thum,RHin,RHout)

HAav=HumidAirProps(Ptot,(Tin+Tout)/2,(RHin+RHout)/2);
HAin=HumidAirProps(Ptot,Thum,RHin);
HAout=HumidAirProps(Ptot,Thum,RHout);
dMassMA=dt.*VolRate.*HAav.RhoMA;
dHeat=dMassMA.*HAav.CpMA.*(Tout-Tin);
dEnergyDensity=dHeat./ColumnVolume./3600; % kWh
dAdsWater=dMassMA.*(HAin.Ha-HAout.Ha);
y.Ha=HAin.Ha;
y.EnergyDensity=sum(dEnergyDensity);
y.Rho=HAin.RhoMA;
y.Cp=HAin.CpMA;
end