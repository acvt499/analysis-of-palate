%% ------------ Object removing, labbeling and device model ------------ %%
%% --------------------------------------------------------------------- %%
close all
clear, clc
%% ------------------------ Data set: Lexie ---------------------------- %%
%% ------------------------- Load matricies ---------------------------- %%
% loc_1 is the localisation of the matrix for data set 1 in the computer %
loc_1="C:\Users\User\Desktop\3rd Year Project\New data base\Lexie\Lexie_1_Matrix_3D.mat";
load(loc_1)
Matrix_3D_set_1=Matrix_3D_1;
% loc_2 is the localisation of the matrix for set 2 registration in the computer %
loc_2="C:\Users\User\Desktop\3rd Year Project\New data base\Lexie\Lexie_2_Matrix_3D_registration_completed.mat";
load(loc_2)
Matrix_3D_set_2=Matrix_3D_set_2_registration_completed;
%% --------------------------------------------------------------------- %%
clear loc_1 loc_2 Matrix_3D_1 Matrix_3D_set_2_registration_completed
%% ----------------- Creating Device matrix - stage 1 ------------------ %%
Device_matrix_with_noise= Matrix_3D_set_1-Matrix_3D_set_2;
%% ----------------- Labeling Device matrix stage 1 -------------------- %%
Set_2_labeled_with_small_noise=bwlabeln...
    (Device_matrix_with_noise(:,:,:)>3200);
figure
imagesc(max(Set_2_labeled_with_small_noise(:,:,:),[],3))
jet2=jet;
jet2(1,:)=0;
colormap(jet2)
%% --------------- Removing small noise from Device matrix ------------- %%
Volume_values_with_small_noise=regionprops3...
    (Set_2_labeled_with_small_noise,'Volume');
Small_noise_treshold =600;
Set_2_labeled_objects_removed=ismember(Set_2_labeled_with_small_noise,...
    find([Volume_values_with_small_noise.Volume]>Small_noise_treshold));
Set_2_labeled_without_small_noise=bwlabeln(Set_2_labeled_objects_removed);
figure
imagesc(max(Set_2_labeled_without_small_noise(:,:,:),[],3))
jet2=jet;
jet2(1,:)=0;
colormap(jet2)
Volume_values_without_small_noise=regionprops3...
    (Set_2_labeled_without_small_noise,'Volume');
%% ------ Finding the treshold for segmenting electrodes and wires ----- %%
figure(1)
plot(Volume_values_without_small_noise.Volume,'b-o'); 
grid on;
axis tight
figure(2)
imagesc(max(Set_2_labeled_without_small_noise(:,:,:),[],3))
%% ------------- Initially segmenting wires and electrodes ------------- %%
close all
wires_treshold = 5000;
wires = ismember(Set_2_labeled_without_small_noise,...
    find([Volume_values_without_small_noise.Volume]>wires_treshold));
electrodes = ismember(Set_2_labeled_without_small_noise,...
    find([Volume_values_without_small_noise.Volume]<wires_treshold));
figure(3)
imagesc(max(wires(:,:,:),[],3))
figure(4)
imagesc(max(electrodes(:,:,:),[],3))
%% --------------------------------------------------------------------- %%
clear Matrix_3D_set_1 Matrix_3D_set_2 wires_treshold ...
    Device_matrix_with_noise Set_2_labeled_objects_removed...
    Set_2_labeled_with_small_noise Set_2_labeled_without_small_noise...
    Small_noise_treshold Volume_values_with_small_noise...
    Volume_values_without_small_noise
%% -------------- Removing noise objects from electrodes --------------- %%
electrodes_labeled = bwlabeln(electrodes);
electrodes_labeled_props = regionprops3(electrodes_labeled,'Volume');
imagesc(max(electrodes_labeled(:,:,:),[],3))
colormap(jet2)
% ---------- Removing two objects that are not the elxtrodes ------------ %
% 3389 and 1009 are the volume of two objects identified as noise in this
% class
electrodes_removed_1 = ismember(electrodes_labeled,...
    find(electrodes_labeled_props.Volume~=3389));
electrodes_removed_1=bwlabeln(electrodes_removed_1);
electrodes_props_removed_1=regionprops3(electrodes_removed_1,'Volume');
electrodes_removed_2 = ismember(electrodes_removed_1,...
    find(electrodes_props_removed_1.Volume~=1009));
electrodes_removed_2=bwlabeln(electrodes_removed_2);
imagesc(max(electrodes_removed_2(:,:,:),[],3))
colormap(jet2)
%% ------------------- Opening the electrodes -------------------------- %%
strel=strel('rectangle',[3,7]);
electrodes_opened=imopen(electrodes_removed_2,strel);
electrodes_opened_labeled=bwlabeln(electrodes_opened);
imagesc(max(electrodes_opened_labeled(:,:,:),[],3))
colormap(jet2)
electrodes_open_labeled_props=regionprops3(electrodes_opened_labeled,...
    'Volume');
% electrodes_open_labeled contains 56/62 electrodes
%% --------------------------------------------------------------------- %%
clear strel electrodes_labeled electrodes_labeled_props...
    electrodes_opened electrodes_props_removed_1 electrodes_removed_1...
    electrodes_removed_2

%% --------------------- Opening the electrodes ------------------------ %%
Expe=Set_2_labeled_without_small_noise;
se = strel('line',8,180);
Set_2_opening_1=imopen((Expe(370:420,85:140,:)),se);
for i=370:420
    for j=85:140
Expe(i,j,:)=Set_2_opening_1(i-370+1,j-85+1,:);
    end
end
imagesc(max(Expe(:,:,:),[],3))
se=strel('rectangle',[2 8]);
Set_2_opening_1=imopen((Expe),se);
%%
Expe_2=Expe;
se = strel('line',12,30);
Set_2_opening_2=imopen((Expe_2(276:295,85:110,:)),se);
for i=276:295
    for j=85:110
Expe_2(i,j,:)=Set_2_opening_2(i-276+1,j-85+1,:);
    end
end
%%
se=strel('rectangle',[2 8]);
Expe_3=imopen(Expe_2, se);
imagesc(max(Expe_3(:,:,:),[],3))
% se=strel('line',10,30);
% Set_2_opening=imopen((Set_2_opening),se);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure
% imagesc(max(Set_2_opening(:,:,:),[],3))
% colormap(jet2)
% Set_2_labeled_after_opening=bwlabeln(Set_2_opening);
% Volume_labeled_open=regionprops3(Set_2_labeled_after_opening,'Volume');
%% --------------------------------------------------------------------- %%
clear Device_matrix_with_noise Matrix_3D_set_1 Matrix_3D_set_2...
    Set_2_labeled_with_small_noise Set_2_labeled_objects_removed...
    Volume_values_with_small_noise
%% ----------------------- Separating electrodes ----------------------- %%
Electrodes_treshold_1 = 3000;
Electrodes_treshold_2 = 700;
Set_2_labeled_separating_electrodes_1_tresh=ismember...
    (Set_2_labeled_after_opening, find...
    ([Volume_labeled_open.Volume]<Electrodes_treshold_1));
Set_2_labeled_electrodes_1=bwlabeln(...
    Set_2_labeled_separating_electrodes_1_tresh);
Volume_labeled_electrodes_1=regionprops3(...
    Set_2_labeled_electrodes_1,'Volume');
Set_2_labeled_separating_electrodes_2_tresh=ismember...
    (Set_2_labeled_electrodes_1, find...
    ([Volume_labeled_electrodes_1.Volume]>Electrodes_treshold_2));
Set_2_labeled_electrodes_2=bwlabeln(...
    Set_2_labeled_separating_electrodes_2_tresh);
figure
imagesc(max(Set_2_labeled_electrodes_2(:,:,:),[],3))
jet2=jet;
jet2(1,:)=0;
colormap(jet2)
Volume_values_electrodes=regionprops3...
    (Set_2_labeled_electrodes_2,'Volume','Centroid');
%% ------------------------ Separating wires --------------------------- %%
Wires_treshold=4500;
Set_2_labeled_separating_wires=ismember...
    (Set_2_labeled_without_small_noise, find...
    ([Volume_values_without_small_noise.Volume]>Wires_treshold));
Set_2_labeled_wires=bwlabeln(Set_2_labeled_separating_wires);
figure
imagesc(max(Set_2_labeled_wires(:,:,:),[],3))
jet2=jet;
jet2(1,:)=0;
colormap(jet2)
Volume_values_wires=regionprops3...
    (Set_2_labeled_wires,'Volume','Centroid');
%% ------------------------ Set up - electrodes ------------------------ %%
Electrodes_matrix=Set_2_labeled_electrodes_1;
[X_1,Y_1,Z_1]=size(Electrodes_matrix);
[X_2D,Y_2D]=meshgrid((1:X_1),(1:Y_1));
Z_2D=ones(size(X_2D));
X_3D=repmat(X_2D,[1 1 Z_1]);
Y_3D=repmat(Y_2D,[1 1 Z_1]);
Z_3D=zeros(X_1,Y_1,Z_1);
for i=1:Z_1
    Z_3D(:,:,i)=Z_2D*i;
end
%% ------------------------ Set up - wires ------------------------ %%
Wires_matrix=Set_2_labeled_wires;
[X_1w,Y_1w,Z_1w]=size(Electrodes_matrix);
[X_2Dw,Y_2Dw]=meshgrid((1:X_1w),(1:Y_1w));
Z_2Dw=ones(size(X_2Dw));
X_3Dw=repmat(X_2Dw,[1 1 Z_1w]);
Y_3Dw=repmat(Y_2Dw,[1 1 Z_1w]);
Z_3Dw=zeros(X_1w,Y_1w,Z_1w);
for i=1:Z_1w
    Z_3Dw(:,:,i)=Z_2Dw*i;
end
%% --------------------------------------------------------------------- %%
clear Device_matrix_with_noise Matrix_3D_set_1 Matrix_3D_set_2...
    Wires_treshold jet2 Electrodes_treshold Set_2_labeled_electrodes...
    Set_2_labeled_wires Set_2_labeled_with_small_noise...
    Set_2_labeled_without_small_noise Small_noise_treshold...
    Set_2_labeled_objects_removed Set_2_labeled_separating_electrodes...
    Set_2_labeled_separating_wires Volume_values_without_small_noise...
    Volume_values_wires Volume_values_with_small_noise
%% --------------- Converting matrix 3D into 3D model ------------------ %%
figure
isovalue_2=1;
patch_e=patch(isosurface(X_3D,Y_3D,Z_3D,Electrodes_matrix,isovalue_2));
patch_w=patch(isosurface(X_3Dw,Y_3Dw,Z_3Dw,Wires_matrix,isovalue_2));
set(patch_e,'FaceColor','Magenta','EdgeColor','None')
set(patch_w,'FaceColor','Green','EdgeColor','None')
camlight('right')
lighting gouraud
material shiny
view(170,50)
grid on
axis([-X_1/4 X_1*1.2 -Y_1/4 Y_1*1.2 -Z_1/4 Z_1*1.2])
%% ---------------------- Adding text labels --------------------------- %%
for k=1:size(Volume_values_electrodes,1)
    text(round(Volume_values_electrodes.Centroid(k,1)),...
    round(Volume_values_electrodes.Centroid(k,2)),...
    round(Volume_values_electrodes.Centroid(k,3)),...
    num2str(k,2),'Color','black','FontSize',10)
end
