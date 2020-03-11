%% ------------ Object removing, labbeling and device model ------------ %%
%% --------------------------------------------------------------------- %%
close all
clear, clc
%% ------------------------ Data set: Evans ---------------------------- %%
%% ------------------------- Load matricies ---------------------------- %%
% loc_1 is the localisation of the matrix for data set 1 in the computer %
loc_1="C:\Users\User\Desktop\3rd Year Project\New data base\Evans\Evans_1_Matrix_3D.mat";
load(loc_1)
Matrix_3D_set_1=Matrix_3D_1;
% loc_2 is the localisation of the matrix for set 2 registration in the computer %
loc_2="C:\Users\User\Desktop\3rd Year Project\New data base\Evans\Evans_2_Matrix_3D_registration_completed.mat";
load(loc_2)
Matrix_3D_set_2=Matrix_3D_set_2_registration_completed;
%% --------------------------------------------------------------------- %%
clear loc_1 loc_2 Matrix_3D_1 Matrix_3D_set_2_registration_completed
%% ----------------- Creating Device matrix - stage 1 ------------------ %%
Device_matrix_with_noise= Matrix_3D_set_1-Matrix_3D_set_2;
%% ----------------- Labeling Device matrix stage 1 -------------------- %%
Set_2_labeled_with_small_noise=bwlabeln...
    (Device_matrix_with_noise(:,:,:)>3150);
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
imagesc(max(Set_2_labeled_without_small_noise(:,:,:),[],3))
jet2=jet;
jet2(1,:)=0;
colormap(jet2)
Volume_values_without_small_noise=regionprops3...
    (Set_2_labeled_without_small_noise,'Volume');
%% ----------------------- Separating electrodes ----------------------- %%
Electrodes_treshold= 4600;
Set_2_labeled_separating_electrodes=ismember...
    (Set_2_labeled_without_small_noise, find...
    ([Volume_values_without_small_noise.Volume]<Electrodes_treshold));
Set_2_labeled_electrodes=bwlabeln(Set_2_labeled_separating_electrodes);
imagesc(max(Set_2_labeled_electrodes(:,:,:),[],3))
jet2=jet;
jet2(1,:)=0;
colormap(jet2)
Volume_values_electrodes=regionprops3...
    (Set_2_labeled_electrodes,'Volume','Centroid');
%% ------------------------ Separating wires --------------------------- %%
Wires_treshold=4500;
Set_2_labeled_separating_wires=ismember...
    (Set_2_labeled_without_small_noise, find...
    ([Volume_values_without_small_noise.Volume]>Wires_treshold));
Set_2_labeled_wires=bwlabeln(Set_2_labeled_separating_wires);
imagesc(max(Set_2_labeled_wires(:,:,:),[],3))
jet2=jet;
jet2(1,:)=0;
colormap(jet2)
Volume_values_wires=regionprops3...
    (Set_2_labeled_wires,'Volume','Centroid');
%% ------------------------ Set up - electrodes ------------------------ %%
Electrodes_matrix=Set_2_labeled_electrodes;
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
axis([0 X_1*1.2 0 Y_1*1.2 0 Z_1*1.2])
%% ---------------------- Adding text labels --------------------------- %%
for k=1:size(Volume_values_electrodes,1)
    text(round(Volume_values_electrodes.Centroid(k,1))...
        ,round(Volume_values_electrodes.Centroid(k,2)),...
        round(Volume_values_electrodes.Centroid(k,3)),...
        num2str(k,2),'Color','black','FontSize',10)
end