%% ----------------------- Asymmetry assesment ------------------------- %%
%% --------------------------------------------------------------------- %%
close all
clear, clc
%% ------------------------ Data set: Lexie ---------------------------- %%
%% ------------------------- Load matricies ---------------------------- %%
loc1="C:\Users\User\Desktop\3rd Year Project\New data base\Lexie\Lexi_Matrix_3D_all_electrodes_labeled.mat";
load(loc1)
Electrodes=Electrodes_completed_labeled;
%% --------------------------------------------------------------------- %%
clear loc1 Electrodes_completed_labeled
%% ---------------------- Labeling electrodes -------------------------- %%
Electrodes_labeled=bwlabeln(Electrodes);
Electrodes_props=regionprops3(Electrodes_labeled,'Volume','Centroid');
%% ------------ Calculating distance between electrodes ---------------- %%
pixel_spacing=0.113; %in mm (read from DICOM files)
distance_record=zeros(62,62);
for i=1:62
    for j=1:62    
        distance=sqrt(abs((Electrodes_props.Centroid(i,1))^2-...
            (Electrodes_props.Centroid(j,1))^2 +...
            (Electrodes_props.Centroid(i,2))^2-...
            (Electrodes_props.Centroid(j,2))^2 +...
            (Electrodes_props.Centroid(i,3))^2-...
            (Electrodes_props.Centroid(j,3))^2));
        distance_record(i,j)=round(distance*pixel_spacing);
    end
end
%% ----------------- Creating plane of symmetry matrix ----------------- %%
[X, Y, Z]=size(Electrodes);
midY=220;
Plane=zeros(X,Y,Z);
for i=1:X
    for j=1:Z
        Plane(i,midY,j)=100;
    end
end
clear i j
%% --------------------------------------------------------------------- %%
%% ------------------------ Set up - electrodes ------------------------ %%
Electrodes_matrix=Electrodes;
[X_1,Y_1,Z_1]=size(Electrodes_matrix);
[X_2D,Y_2D]=meshgrid((1:X_1),(1:Y_1));
Z_2D=ones(size(X_2D));
X_3D=repmat(X_2D,[1 1 Z_1]);
Y_3D=repmat(Y_2D,[1 1 Z_1]);
Z_3D=zeros(X_1,Y_1,Z_1);
for i=1:Z_1
    Z_3D(:,:,i)=Z_2D*i;
end
%% -------------------------- Set up - plane --------------------------- %%
[X_1p,Y_1p,Z_1p]=size(Plane);
[X_2Dp,Y_2Dp]=meshgrid((1:X_1p),(1:Y_1p));
Z_2Dp=ones(size(X_2Dp));
X_3Dp=repmat(X_2Dp,[1 1 Z_1p]);
Y_3Dp=repmat(Y_2Dp,[1 1 Z_1p]);
Z_3Dp=zeros(X_1p,Y_1p,Z_1p);
for i=1:Z_1p
    Z_3Dp(:,:,i)=Z_2Dp*i;
end
%% --------------- Converting matrix 3D into 3D model ------------------ %%
figure
isovalue_e=0;
patch_e=patch(isosurface(X_3D,Y_3D,Z_3D,Electrodes_matrix,isovalue_e));
set(patch_e,'FaceColor','Magenta','EdgeColor','None')
patch_p=patch(isosurface(X_3Dp,Y_3Dp,Z_3Dp,Plane,isovalue_e));
set(patch_p,'FaceColor','Black','EdgeColor','None')
alpha(patch_p, 0.3)
camlight('right')
lighting gouraud
material shiny
view(170,50)
grid on
axis([0 X_1 0 Y_1 0 Z_1])
%% ---------------------- Adding text labels --------------------------- %%
for Volume_electrodes=1:62
    text(round(Electrodes_props.Centroid(Volume_electrodes,1)+5),...
    round(Electrodes_props.Centroid(Volume_electrodes,2)+5),...
    round(Electrodes_props.Centroid(Volume_electrodes,3)+5),...
    num2str(Volume_electrodes,2),'Color','black','FontSize',10)
end

