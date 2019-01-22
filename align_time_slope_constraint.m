% SLOPING, INITIAL BOUNDARY CONDITION, monotonicity, warping window boundaries are integrated in this code
% Created by SP: 22 Aug, 2016

function ind2=align_time_slope_constraint(D,restiction_points)
if nargin==1
    restiction_points=2;
end

%% Itakura parallelogram constraint 
row_mat=repmat((1:size(D,1))',1,size(D,2));
col_mat=repmat((1:size(D,2)),size(D,1),1);
ItakuraParallelogramMask=nan(size(D));
ItakuraParallelogramMask((row_mat./col_mat)<tan(pi/3)  & ((row_mat./col_mat)>tan(pi/6))  & ((size(D,1)-row_mat+1)./(size(D,2)-col_mat+1)<tan(pi/3)) & ((size(D,1)-row_mat+1)./(size(D,2)-col_mat+1)>tan(pi/6)))=1;
D=D.*ItakuraParallelogramMask;
D(isnan(D))=Inf;
%%
ind2=zeros(size(D,2),1);

base_ind=size(D,1)-100;
allowed_rows=base_ind+1:size(D,1);
prev_steps=nan(restiction_points,1);

%%
for i=length(ind2):-1:2
    [~,min_ind]=min(D(allowed_rows,i));
    ind2(i)=min_ind+base_ind;
    allowed_rows=base_ind+min_ind-2:base_ind+min_ind;
    allowed_rows(allowed_rows<=0)=[];
    allowed_rows(allowed_rows>size(D,1))=[];
    
    prev_steps(1:restiction_points-1)=prev_steps(2:restiction_points);
    prev_steps(end)=min_ind;
    
    if length(unique(prev_steps))==1
        if prev_steps(1)==1
            allowed_rows(1)=[];
            prev_steps(end)=2;
        elseif prev_steps(1)==3 
            allowed_rows(end)=[];
            prev_steps(end)=2;
        else 
            % Do nothing
        end
    end
    base_ind=allowed_rows(1)-1;
end

ind2=ind2(2:end)-1;