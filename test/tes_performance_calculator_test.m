% [~,~,xlsData]=xlsread('./20160516.xlsx','Data');          
[~,~,xlsData]=xlsread('./2016 07 28 - T_80C RH_10.xlsx');     

column.dt=double('B')-64; dt=diff([0;cell2mat(xlsData(2:end,column.dt))])./60;
t=cell2mat(xlsData(2:end,column.dt))./60;
%column.T1=double(app.DropDown3.Value)-64; T1=cell2mat(xlsData(2:end,column.T1))+273.15;
%column.T2=double(app.DropDown4.Value)-64; T2=cell2mat(xlsData(2:end,column.T2))+273.15;
%column.T3=double(app.DropDown5.Value)-64; T3=cell2mat(xlsData(2:end,column.T3))+273.15;
%column.TH=double(app.DropDown6.Value)-64; TH=cell2mat(xlsData(2:end,column.TH))+273.15;
%column.T4=double(app.DropDown7.Value)-64;
column.RHout=double('G')-64; RHout=cell2mat(xlsData(2:end,column.RHout));