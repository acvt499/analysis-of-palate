%% --- Creating Matrix 3D for data set 1 (palate with electropalate) --- %%
%% --------------------------------------------------------------------- %%
close all
clear, clc
%% ----------------------- Data set: Brooks 1 --------------------------- %%
%% ----------------------- Change if needed ---------------------------- %%
% --- loc_0 is the localisation of the dicom file 10 in the computer --- %
loc_0="C:\Users\User\Desktop\3rd Year Project\Brooks 1\S0000001\I0000010";
% loc_1 is the localisation of the dicom file 10-99 in the computer %
loc_1="C:\Users\User\Desktop\3rd Year Project\Brooks 1\S0000001\I00000";
% loc_2 is the localisation of the dicom file 100-451 in the computer %
loc_2="C:\Users\User\Desktop\3rd Year Project\Brooks 1\S0000001\I0000";
numslices_1=350; % number of slices = z (levels) dimension of 3D matrix
%% ----------------------------- Set up -------------------------------- %%
%  Matrix B0 is for checking the dimensions of one slice of a 3D matrix  %
B_0=dicomread(loc_0);
[x_1,y_1]=size(B_0); % x and y dimention of 3D matrix
% ---------------- setting up "empty" matrix for 3D matrix ------------- %
Matrix_3D_1=zeros(x_1,y_1,numslices_1);
%% ------------------------ Creating 3D matrix ------------------------- %%
% ----------------- First 49 slices are not included ------------------- %
% ---- Loops to replace one slice of 3D martix with one slice-image ---- %
for slice_number=50:99
    B_1=dicomread(strcat(loc_1,num2str(slice_number)));
    Matrix_3D_1(:,:,numslices_1+1-slice_number)=B_1; 
end
for slice_number=100:numslices_1
    B_2=dicomread(strcat(loc_2,num2str(slice_number)));
    Matrix_3D_1(:,:,numslices_1+1-slice_number)=B_2;
end
%% ----------- Save matrix 3D for data set 1 for further use ----------- %%