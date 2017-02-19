function out=psychrometric_test

    addpath('../src','../lib/coolprop');
    
    fprintf('HA.old humid air properties based on old correlations used\n');
    fprintf('HA.new humid air properties based on ASHRAE methods used in CoolProp\n\n');
    fprintf(['T(C)     y       RH_new     RH_old     H_new      H_old      H_err      rho_new    rho_old    rho_err    Cp_new     Cp_old     Cp_err  \n']);
    i=0;
    j=0;
    steps=4;
    test(1,:)={'T(C)' 'y' 'RH_new'    'RH_old'    'H_new'     'H_old'     'H_err'  'rho_new'    'rho_old'   'rho_err'   'Cp_new'    'Cp_old'    'Cp_err'};
    T=[20,30,40,50,60,70,80,90,100,110,120,130]; 
    RH=linspace(25,100,steps);
    for Ti=T
        %for y=[0.01 0.05:0.05:.99 .99]
        i=i+1;
        j=0;
        for RHi=RH
            j=j+1;
% %             HA.new=humid_air_props(101.325,T,'y',Y,'model','new');
% %             HA.old=humid_air_props(101.325,T,'y',Y,'model','old');
            
            HA.new=humid_air_props(101.325,Ti,'RH',RHi,'model','New');
            HA.old=humid_air_props(101.325,Ti,'RH',RHi,'model','Old');
            
            HA.err.H=100.*abs((HA.new.H-HA.old.H)./HA.new.H);
            %HA.err.H=[num2str(round(HA.err.H,4),'% .3f') '%'];
            HA.err.rho_MA=100.*abs((HA.new.rho_MA-HA.old.rho_MA)./HA.new.rho_MA);
            %HA.err.rho_MA=[num2str(round(HA.err.rho_MA,4),'% .3f') '%'];
            HA.err.Cp_MA=100.*abs((HA.new.Cp_MA-HA.old.Cp_MA)./HA.new.Cp_MA);
            %HA.err.Cp_MA=[num2str(round(HA.err.Cp_MA,4),'% .3f') '%'];
            b={Ti,HA.new.y_H2O,HA.new.RH,HA.old.RH,HA.new.H,HA.old.H,HA.err.H,HA.new.rho_MA,HA.old.rho_MA,HA.err.rho_MA,HA.new.Cp_MA,HA.old.Cp_MA,HA.err.Cp_MA};
            fprintf(['%-4.d % -10.4f % -10.4f % -10.4f % -10.4f % -10.4f % -10.4f % -10.4f % -10.4f % -10.4f % -10.4f % -10.4f % -10.4f \n'],Ti,HA.new.y_H2O,HA.new.RH,HA.old.RH,HA.new.H,HA.old.H,HA.err.H,HA.new.rho_MA,HA.old.rho_MA,HA.err.rho_MA,HA.new.Cp_MA,HA.old.Cp_MA,HA.err.Cp_MA);
            %c={Ti,HA.new.y_H2O,HA.new.RH,HA.old.RH,HA.new.H,HA.old.H,str2num(regexprep(HA.err.H,'%','')),HA.new.rho_MA,HA.old.rho_MA,str2num(regexprep(HA.err.rho_MA,'%','')),HA.new.Cp_MA,HA.old.Cp_MA,str2num(regexprep(HA.err.Cp_MA,'%',''))};
            test(steps*(i-1)+j+1,:)=b;
            
            out.Ts(i,j)=Ti;
            out.RHs(i,j)=RHi;
            out.new.H(i,j)=HA.new.H;
            out.new.rho_MA(i,j)=HA.new.rho_MA;
            out.new.Cp_MA(i,j)=HA.new.Cp_MA;
            out.old.H(i,j)=HA.old.H;
            out.old.rho_MA(i,j)=HA.old.rho_MA;
            out.old.Cp_MA(i,j)=HA.old.Cp_MA;
            out.err.H(i,j)=HA.err.H;
            out.err.rho_MA(i,j)=HA.err.rho_MA;
            out.err.Cp_MA(i,j)=HA.err.Cp_MA;
        end
    end
    out.test=test;
    out.T=T;
    out.RH=RH;
    old.T=out.T;
    
    i=0;
    for t=T
        i=i+1;
        legT{i}=num2str(t);
    end
    
    i=0;
    for rh=RH
        i=i+1;
        legRH{i}=num2str(rh);
    end
    
    leg={'Humidity','Moist air density','Moist air heat capacity'};
    
    figure;
    lw=1.5;
    ms=1.5;
    
    subplot(1,3,1); 
    semilogy(out.T, out.err.H, 'o', 'LineWidth', ms); ylabel('Humidity error (%)');
    legend(leg);
    
    subplot(1,3,2);
    semilogy(out.T,out.err.rho_MA, 'o', 'LineWidth', ms); ylabel('Density error (%)');
    legend(leg);
    
    subplot(1,3,3);
    semilogy(out.T,out.err.Cp_MA, 'o', 'LineWidth', ms); ylabel('Specific heat error (%)');
    legend(leg);
    
    a=gca;  
    col={a.Children.Color};
    col=flip(col);
    
    figure;
    subplot(1,3,1);
    semilogy(out.T, out.new.H, 'o', 'LineWidth',ms); ylabel('Humidity (kg/kg)');
    j=0;
    hold on; 
    sl=semilogy(old.T, out.old.H, '-', 'LineWidth', lw);
    %sl=plot(old.T, out.old.H, '-', 'LineWidth', lw);
    for i=1:length(col)
        j=j+1;
        sl(j).Color=col{i};
    end
    legend(legRH);
    
    subplot(1,3,2);
    semilogy(out.T,out.new.rho_MA, 'o', 'LineWidth',ms); ylabel('Density (kg/m^3)');
    j=0;
    hold on; 
    sl=semilogy(old.T,out.old.rho_MA, '-','LineWidth',lw);
    %sl=plot(old.T,out.old.rho_MA, '-','LineWidth',lw);
    for i=1:length(col)
        j=j+1;
        sl(j).Color=col{i};
    end
    legend(legRH);
    
    subplot(1,3,3);
    semilogy(out.T,out.new.Cp_MA, 'o','LineWidth',ms); ylabel('Specific heat (kJ/kg-K)');  
    j=0;
    hold on; 
    sl=semilogy(old.T,out.old.Cp_MA, '-','LineWidth',2);
    %sl=plot(old.T,out.old.Cp_MA, '-','LineWidth',2);
    for i=1:length(col)
        j=j+1;
        sl(j).Color=col{i};
    end
    legend(legRH);
end