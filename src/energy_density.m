
[FileName,PathName] = uigetfile('*.csv','Select the raw data file');
RawData=csvread([PathName FileName],1,1);

%Extract the time array in seconds
Time=zeros(size(RawData,1),1);
for i=1:size(RawData,1)
    if i==1
        Time(i,1)=0;
    else
        Time(i,1)=Time(i-1)+RawData(i);
    end
end

%Convert the time array into minutes
Time=Time./60;

%Extract other arrays
RH=RawData(:,2);
TH=RawData(:,3);
T1=RawData(:,4);
T3=RawData(:,6);
V1=RawData(:,9);
V2=RawData(:,10);


