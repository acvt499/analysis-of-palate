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
% change for .... .Volume==props{index,1})
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
% electrodes_open_labeled contains 55/62 electrodes
%% --------------------------------------------------------------------- %%
clear strel electrodes_labeled electrodes_labeled_props...
    electrodes_opened electrodes_props_removed_1 electrodes_removed_1...
    electrodes_removed_2
%% ----------- Finding missing electrodes in wires class --------------- %%
%% ------------------------- Labeling wires ---------------------------- %%
wires_labeled=bwlabeln(wires);
imagesc(max(wires_labeled(:,:,:),[],3))
wires_props=regionprops3(wires_labeled,'Volume');
% --------------- Finding the electrodes by inspection ------------------ %
figure
subplot(1,2,1)
imagesc(max(wires_labeled(:,:,:),[],3))
subplot(1,2,2)
imagesc(max(electrodes_opened_labeled(:,:,:),[],3))
% ---------- There are 7 missing electrodes at this point -------------- %%
%% ------------- Extracting missing electrodes 1 and 2 ----------------- %%
% ------- Extracting Volume in which the elctrodes are "hiden" --------- %%
Volume_electrodes_1_and_2=ismember(wires_labeled,...
    find(wires_props.Volume==wires_props{1,1}));
imagesc(max(Volume_electrodes_1_and_2(:,:,:),[],3))
strel=strel('rectangle',[2,6]);
Electrodes_1_and_2_with_noise=imopen(Volume_electrodes_1_and_2,strel);
clear strel
Electrodes_1_and_2_with_noise_labeled=bwlabeln(...
    Electrodes_1_and_2_with_noise);
imagesc(max(Electrodes_1_and_2_with_noise_labeled(:,:,:),[],3))
Electrodes_1_and_2_with_noise_props=regionprops3...
    (Electrodes_1_and_2_with_noise_labeled,'Volume');
% Missing electrodes are labelled 4 and 9
label_1=4;
label_2=9;
Missing_electrode_1=ismember(Electrodes_1_and_2_with_noise_labeled, ...
    find(Electrodes_1_and_2_with_noise_props.Volume==...
    Electrodes_1_and_2_with_noise_props{label_1,1}));
Missing_electrode_2=ismember(Electrodes_1_and_2_with_noise_labeled,...
    find(Electrodes_1_and_2_with_noise_props.Volume==...
    Electrodes_1_and_2_with_noise_props{label_2,1}));
Missing_electrodes_1_and_2=Missing_electrode_1+Missing_electrode_2;
imagesc(max(Missing_electrodes_1_and_2(:,:,:),[],3))
%% --------------------------------------------------------------------- %%
clear Electrodes_1_and_2_with_noise Electrodes_1_and_2_with_noise_labeled...
    Electrodes_1_and_2_with_noise_props Missing_electrode_1 ...
    Missing_electrode_2 Volume_electrodes_1_and_2 label_1 label_2
%% ----------------- Extracting missing electrode 3 -------------------- %%
% -------- Extracting Volume in which the elctrode are "hiden" --------- %%
Volume_electrode_3=ismember(wires_labeled,...
    find(wires_props.Volume==wires_props{6,1}));
imagesc(max(Volume_electrode_3(:,:,:),[],3))
strel=strel('line',10, 30);
Electrode_3_with_noise=imopen(Volume_electrode_3,strel);
clear strel
Electrode_3_with_noise_labeled=bwlabeln(...
    Electrode_3_with_noise);
imagesc(max(Electrode_3_with_noise_labeled(:,:,:),[],3))
Electrode_3_with_noise_props=regionprops3...
    (Electrode_3_with_noise_labeled,'Volume');
% Missing electrode is labelled 2
label_3=2;
Missing_electrode_3=ismember(Electrode_3_with_noise_labeled, ...
    find(Electrode_3_with_noise_props.Volume==...
    Electrode_3_with_noise_props{label_3,1}));
imagesc(max(Missing_electrode_3(:,:,:),[],3))
%% --------------------------------------------------------------------- %%
clear Electrode_3_with_noise Electrode_3_with_noise_labeled label_3...
    Electrode_3_with_noise_props Volume_electrode_3
%% ----------------- Extracting missing electrode 4 -------------------- %%
% -------- Extracting Volume in which the elctrode are "hiden" --------- %%
Volume_electrode_4=ismember(wires_labeled,...
    find(wires_props.Volume==wires_props{5,1}));
imagesc(max(Volume_electrode_4(:,:,:),[],3))
%%
strel=strel('line',10, 30);
Electrode_4_with_noise_step_1=imopen(Volume_electrode_4,strel);
clear strel
strel=strel('line',10,90);
Electrode_4_with_noise=imopen(Electrode_4_with_noise_step_1,strel);
clear strel
Electrode_4_with_noise_labeled=bwlabeln(...
    Electrode_4_with_noise);
imagesc(max(Electrode_4_with_noise_labeled(:,:,:),[],3))
Electrode_4_with_noise_props=regionprops3...
    (Electrode_4_with_noise_labeled,'Volume');
%%
% Missing electrode is labelled 3
label_4=3;
Missing_electrode_4=ismember(Electrode_4_with_noise_labeled, ...
    find(Electrode_4_with_noise_props.Volume==...
    Electrode_4_with_noise_props{label_4,1}));
imagesc(max(Missing_electrode_4(:,:,:),[],3))
%% --------------------------------------------------------------------- %%
clear Electrode_4_with_noise Electrode_4_with_noise_labeled label_4...
    Electrode_4_with_noise_props Electrode_4_with_noise_step_1...
    Volume_electrode_4
%% -------------- Extracting missing electrode 5, 6, 7 ----------------- %%
% -------- Extracting Volume in which the elctrodes are "hiden" -------- %%
Volume_electrode_5_6_7=ismember(wires_labeled,...
    find(wires_props.Volume==wires_props{3,1}));
imagesc(max(Volume_electrode_5_6_7(:,:,:),[],3))
%%
strel=strel('line',10, 30);
Electrode_5_6_7_with_noise_step_1=imopen(Volume_electrode_5_6_7,strel);
clear strel
strel=strel('line',10,90);
Electrode_5_6_7_with_noise=imopen(Electrode_5_6_7_with_noise_step_1,strel);
clear strel
Electrode_5_6_7_with_noise_labeled=bwlabeln(...
    Electrode_5_6_7_with_noise);
imagesc(max(Electrode_5_6_7_with_noise_labeled(:,:,:),[],3))
Electrode_5_6_7_with_noise_props=regionprops3...
    (Electrode_5_6_7_with_noise_labeled,'Volume');
%%
% Missing electrodes is labelled 1, 5 and 2
label_5=1;
label_6=5;
label_7=2;
Missing_electrode_5=ismember(Electrode_5_6_7_with_noise_labeled, ...
    find(Electrode_5_6_7_with_noise_props.Volume==...
    Electrode_5_6_7_with_noise_props{label_5,1}));
Missing_electrode_6=ismember(Electrode_5_6_7_with_noise_labeled, ...
    find(Electrode_5_6_7_with_noise_props.Volume==...
    Electrode_5_6_7_with_noise_props{label_6,1}));
Missing_electrodes_7=ismember(Electrode_5_6_7_with_noise_labeled, ...
    find(Electrode_5_6_7_with_noise_props.Volume==...
    Electrode_5_6_7_with_noise_props{label_7,1}));
Missing_electrodes_5_6_7=Missing_electrode_5+Missing_electrode_6+...
    Missing_electrodes_7;
imagesc(max(Missing_electrodes_5_6_7(:,:,:),[],3))
%% --------------------------------------------------------------------- %%
clear Electrode_5_6_7_with_noise Electrode_5_6_7_with_noise_labeled...
    Electrode_5_6_7_with_noise_props Electrode_5_6_7_with_noise_step_1...
    label_5 label_6 Volume_electrode_5_6_7 Missing_electrode_5...
    Missing_electrode_6 Missing_electrodes_7 label_7
%% ------ Adding all the missing electrodes to the elctrodes class ----- %%
Electrodes_completed=electrodes_opened_labeled+Missing_electrodes_1_and_2...
    + double(Missing_electrode_3) + double(Missing_electrode_4)...
    +Missing_electrodes_5_6_7;
Electrodes_completed_labeled=bwlabeln(Electrodes_completed);
imagesc(max(Electrodes_completed_labeled(:,:,:),[],3))
colormap(jet2)
%% --------------------------------------------------------------------- %%
clear electrodes_opened_labeled electrodes_open_labeled_props...
    Missing_electrode_3 Missing_electrode_4 Missing_electrodes_1_and_2...
    Missing_electrodes_5_6_7

%% --------------------------------------------------------------------- %%
%% ------------------------ Set up - electrodes ------------------------ %%
Electrodes_matrix=Electrodes_completed_labeled;
[X_1,Y_1,Z_1]=size(Electrodes_matrix);
[X_2D,Y_2D]=meshgrid((1:X_1),(1:Y_1));
Z_2D=ones(size(X_2D));
X_3D=repmat(X_2D,[1 1 Z_1]);
Y_3D=repmat(Y_2D,[1 1 Z_1]);
Z_3D=zeros(X_1,Y_1,Z_1);
for i=1:Z_1
    Z_3D(:,:,i)=Z_2D*i;
end
%% --------------- Converting matrix 3D into 3D model ------------------ %%
figure
isovalue_e=1;
patch_e=patch(isosurface(X_3D,Y_3D,Z_3D,Electrodes_matrix,isovalue_e));
set(patch_e,'FaceColor','Magenta','EdgeColor','None')
camlight('right')
lighting gouraud
material shiny
view(170,50)
grid on
axis([-X_1/4 X_1*1.2 -Y_1/4 Y_1*1.2 -Z_1/4 Z_1*1.2])
%% ---------------------- Adding text labels --------------------------- %%
for Volume_electrodes_1_and_2=1:62
    text(round(Volume_values_electrodes.Centroid(Volume_electrodes_1_and_2,1)),...
    round(Volume_values_electrodes.Centroid(Volume_electrodes_1_and_2,2)),...
    round(Volume_values_electrodes.Centroid(Volume_electrodes_1_and_2,3)),...
    num2str(Volume_electrodes_1_and_2,2),'Color','black','FontSize',10)
end
