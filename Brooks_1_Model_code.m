%% - Creating Model (patch) for data set 1 (palate with electropalate) - %%
%% --------------------------------------------------------------------- %%
close all
clear, clc
%% ----------------------- Data set: Brooks 1 -------------------------- %%
%% ------------------------ Load matrix 3D ----------------------------- %%
% ----- loc_1 is the localisation of the matrix 3D in the computer ----- %
loc_1="C:\Users\User\Desktop\3rd Year Project\New data base\Brooks\Brooks_1_Matrix_3D.mat";
load(loc_1)
Matrix_3D_current=Matrix_3D_1;
%% ---------------------------- Set up --------------------------------- %%
[X_1,Y_1,Z_1]=size(Matrix_3D_current);
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
isovalue_1=1400;
patch_1=patch(isosurface(X_3D,Y_3D,Z_3D,Matrix_3D_current,isovalue_1));
set(patch_1,'FaceColor','Red','EdgeColor','None')
camlight('right')
lighting gouraud
material shiny
view(170,50)
grid on
axis([0 X_1 0 Y_1 0 Z_1])