clear all
close all
clc

% Last edit: 29th Sept 2019 by Farah Roslend
% Note: Make sure your excel sheet, rgb2hex.m, are in the same directory as this script. 
% Currently script is limited to 434 rows/CPs due to round-down constrain for RGB_kickoff=[47,73,245]. WORKAROUND: increase the max value for the RGB kick-off.

%% Extract CP's chart names, key-in kick-off RGB 

[~,~, numberandtext] = xlsread('rbgHex_XF.xlsx', 'Sheet3');  %USER INPUT

CP_chart_names=numberandtext(2:end,1); %pushed into Matlab; USER EDIT RANGE

RGB_kickoff=[31,41,237]; %USER INPUT

%% Quantifying colour transition via 6 gradients

% Calculating "step-time"

CP_chart_names_no_rows=size(CP_chart_names);
CP_chart_names_no_rows=CP_chart_names_no_rows(1,1); %no. of rows for chart column from excel

one_phase_no_rows=ceil((CP_chart_names_no_rows(1,1))/6); %step-time/step-rows for each phase

% Identifying which of RGB is min, max, mid (index search)

[RGB_kickoff_max,I_max]=max(RGB_kickoff); %max value, index
[RGB_kickoff_min, I_min]=min(RGB_kickoff); %min value, index

RGB_kickoff_mid=median(RGB_kickoff); %mid value

RGB_index=[1;2;3]; %[R;G;B]
index_max = RGB_index == I_max;
index_min = RGB_index == I_min;
index_mid = (index_max+index_min)==0;
index_mid = sum(index_mid.*RGB_index); %mid index

% Phase X=1:6 gradient 

gradient(1,1)=[floor((RGB_kickoff_max-RGB_kickoff_min)/one_phase_no_rows)]; %gradient for Phase 1
gradient(2,1)=[-floor((RGB_kickoff_max-RGB_kickoff_min)/one_phase_no_rows)]; %gradient for Phase 2
gradient(3,1)=[floor((RGB_kickoff_max-RGB_kickoff_mid)/one_phase_no_rows)]; %etc.
gradient(4,1)=[-floor((RGB_kickoff_max-RGB_kickoff_min)/one_phase_no_rows)];
gradient(5,1)=[floor((RGB_kickoff_max-RGB_kickoff_min)/one_phase_no_rows)];
gradient(6,1)=[-floor((RGB_kickoff_max-RGB_kickoff_mid)/one_phase_no_rows)];


% Implementing the phase gradients on the appropriate R,G,B/min,mid,max components

RGBlist(1,1)=RGB_kickoff(1,1); %R
RGBlist(1,2)=RGB_kickoff(1,2); %G
RGBlist(1,3)=RGB_kickoff(1,3); %B
index_max;
index_mid;
index_min;

X=1;
for i=one_phase_no_rows*(X-1)+1:one_phase_no_rows*X % phase one
    
    RGBlist(i,index_min)=[RGB_kickoff_min+gradient(X,1)*(i-1-(X-1)*one_phase_no_rows)];
    
    RGBlist(i,index_max)=[RGB_kickoff_max];
    RGBlist(i,index_mid)=[RGB_kickoff_mid];

end

X=2;
for i=one_phase_no_rows*(X-1)+1:one_phase_no_rows*X % phase two
    
    RGBlist(i,index_max)=[RGB_kickoff_max+gradient(X,1)*(i-1-(X-1)*one_phase_no_rows)];
    
    
    RGBlist(i,index_mid)=[RGBlist(one_phase_no_rows*(X-1),index_mid)];
    RGBlist(i,index_min)=[RGBlist(one_phase_no_rows*(X-1),index_min)];

end

X=3;
for i=one_phase_no_rows*(X-1)+1:one_phase_no_rows*X % phase three
    
    RGBlist(i,index_mid)=[RGB_kickoff_mid+gradient(X,1)*(i-1-(X-1)*one_phase_no_rows)];
    
    
    RGBlist(i,index_max)=[RGBlist(one_phase_no_rows*(X-1),index_max)];
    RGBlist(i,index_min)=[RGBlist(one_phase_no_rows*(X-1),index_min)];

end

X=4;
for i=one_phase_no_rows*(X-1)+1:one_phase_no_rows*X % phase four
    
    RGBlist(i,index_min)=[RGBlist((one_phase_no_rows*(X-1)+1)-1,index_min)+gradient(X,1)*(i-1-(X-1)*one_phase_no_rows)];
    
    
    RGBlist(i,index_mid)=[RGBlist(one_phase_no_rows*(X-1),index_mid)];
    RGBlist(i,index_max)=[RGBlist(one_phase_no_rows*(X-1),index_max)];

end

X=5;
for i=one_phase_no_rows*(X-1)+1:one_phase_no_rows*X % phase five
    
    RGBlist(i,index_max)=[RGBlist((one_phase_no_rows*(X-1)+1)-1,index_min)+gradient(X,1)*(i-1-(X-1)*one_phase_no_rows)];
    
    RGBlist(i,index_min)=[RGBlist(one_phase_no_rows*(X-1),index_min)];
    RGBlist(i,index_mid)=[RGBlist(one_phase_no_rows*(X-1),index_mid)];
    

end

X=6;
for i=one_phase_no_rows*(X-1)+1:one_phase_no_rows*X % phase six
    
    RGBlist(i,index_mid)=[RGBlist((one_phase_no_rows*(X-1)+1)-1,index_mid)+gradient(X,1)*(i-1-(X-1)*one_phase_no_rows)];
    
    RGBlist(i,index_min)=[RGBlist(one_phase_no_rows*(X-1),index_min)];
    RGBlist(i,index_max)=[RGBlist(one_phase_no_rows*(X-1),index_max)];
    

end

RGBlist; %potentially overproduced (a bit more rows than no. of CPs) RGB list

%% Listing out the 15 complementary colours to be used for the charts with multiple signals

RGBlist_no_rows=size(RGBlist);
RGBlist_no_rows=RGBlist_no_rows(1,1);
for j=1:15
RGBlist_complementary(j,1:3)=[RGBlist(floor(RGBlist_no_rows*(j/15)),1:3)];
end

RGBlist_complementary=flipud(RGBlist_complementary);

%% Identifying and correcting RGBlist for CP rows with multiple signals

% Trimming RGBlist to match no. of rows for CP_chart_names
RGBlist=RGBlist(1:CP_chart_names_no_rows,:);

% Modifying the RGBlist

for c=1:CP_chart_names_no_rows
    tf=strcmp(CP_chart_names(c,1),CP_chart_names);

if sum(tf)>1
    k=find(tf); %index/row no. for the recurring chart name in CP_chart_names
    no_of_iterations=size(k);
    no_of_iterations=no_of_iterations(1,1);
    
    for m=1:no_of_iterations
      RGBlist(k(m,1),1:3)=[RGBlist_complementary(m,1:3)];  
    end
else
    %chillax
end
end

RGBlist;

%% Coverting the RGBlist to a hexlist

Hexlist=rgb2hex(RGBlist); %voila!

colourPairing={CP_chart_names,Hexlist};

