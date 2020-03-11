%% ------------------------- Registration ------------------------------ %%
%% --------------------------------------------------------------------- %%
close all
clear, clc
%% ------------------------ Data set: Lexie ---------------------------- %%
%% ------------------------- Load matricies ---------------------------- %%
% loc_1 is the localisation of the matrix for data set 1 in the computer %
loc_1="C:\Users\User\Desktop\3rd Year Project\New data base\Lexie\Lexie_1_Matrix_3D.mat";
load(loc_1)
Matrix_3D_set_1=Matrix_3D_1;
% loc_2 is the localisation of the matrix for data set 2 in the computer %
loc_2="C:\Users\User\Desktop\3rd Year Project\New data base\Lexie\Lexie_2_Matrix_3D.mat";
load(loc_2)
Matrix_3D_set_2=Matrix_3D_2;
%% --------------------------------------------------------------------- %%
clear Matrix_3D_1
clear Matrix_3D_2
%% ------------------- Levels (z) dimension alignment ------------------ %%
%% ----------------------------- Set up -------------------------------- %%
slice_checked=153;
Set_1_levels_checked=Matrix_3D_set_1(:,:,slice_checked);
%% ------------------- First loop ('Positive' shift) ------------------- %%
values_levels_positive=zeros(1,31);
for Set_2_levels_shift_value=1:31
    Set_2_levels_checked=...
        Matrix_3D_set_2(:,:,slice_checked+Set_2_levels_shift_value-1);
    Set_levels_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_positive=sum(sum(abs(Set_levels_diff)));
    values_levels_positive(1,Set_2_levels_shift_value)=sum_positive;
end
%% ------------------- Second loop ('Negative' shift) ------------------ %%
values_levels_negative=zeros(1,30);
for Set_2_levels_shift_value=1:30
    Set_2_levels_checked=...
        Matrix_3D_set_2(:,:,slice_checked-Set_2_levels_shift_value);
    Set_levels_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_negative=sum(sum(abs(Set_levels_diff)));
    values_levels_negative(1,Set_2_levels_shift_value)=sum_negative;
end
values_levels_negative_flip=fliplr(values_levels_negative);
%% ---------------------- Sensitivity analysis ------------------------- %%
values_levels_final=...
    horzcat(values_levels_negative_flip,values_levels_positive);
plot((-30:30),values_levels_final)
% -------------------------- Save the plot ----------------------------- %
%% ----------------- If statement to find optimal value ---------------- %%
[num_pix_levels_positive,optimal_shift_value_positive_raw]=...
    min(values_levels_positive);
[num_pix_levels_negative,optimal_shift_value_negative_raw]=...
    min(values_levels_negative_flip);
optimal_shift_value_positive=optimal_shift_value_positive_raw-1;
optimal_shift_value_negative=optimal_shift_value_negative_raw-31;
if num_pix_levels_positive<num_pix_levels_negative
    disp(strcat('Optimal shift value in levels:  ',...
        num2str(optimal_shift_value_positive)))
    Set_2_levels_shift_value=optimal_shift_value_positive;
else
    disp(strcat('Optimal shift value in levels:  ',...
        num2str(optimal_shift_value_negative)))
    Set_2_levels_shift_value=optimal_shift_value_negative;
end
%% -------- Creating new matrix with better alignment in levels -------- %%
[x_2, y_2, z_2]=size(Matrix_3D_set_2);
% ------------------ Setting up "empty" 3D matrix ---------------------- %
Matrix_3D_set_2_registration_levels=zeros(x_2, y_2, z_2);
if Set_2_levels_shift_value==0
    Matrix_3D_set_2_registration_levels=Matrix_3D_set_2;
elseif num_pix_levels_positive<num_pix_levels_negative
    for i=1:z_2-Set_2_levels_shift_value
        Matrix_3D_set_2_registration_levels(:,:,i)=...
            Matrix_3D_set_2(:,:,i+Set_2_levels_shift_value);
    end
else
    for i=1:z_2+Set_2_levels_shift_value
        Matrix_3D_set_2_registration_levels(:,:,i)=...
            Matrix_3D_set_2(:,:,i-Set_2_levels_shift_value);
    end
end
%% -------------------------- Save the matrix -------------------------- %%
%% --------------------------------------------------------------------- %%
clear Matrix_3D_set_2 Set_2_levels_checked num_pix_levels_negative ...
     num_pix_levels_positive optimal_shift_value_negative_raw...
     optimal_shift_value_negative optimal_shift_value_positive...
     optimal_shift_value_positive_raw Set_2_levels_shift_value...
     Set_levels_diff i sum_negative sum_positive values_levels_final...
     values_levels_negative values_levels_negative_flip...
     values_levels_positive loc_1 loc_2
%% -------------------- Rows (x) dimension alignment ------------------- %%
%% ------------------- First loop ('Positive' shift) ------------------- %%
values_rows_positive=zeros(1,31);
Set_2_rows_shift=zeros(x_2, y_2, z_2);
for Set_2_rows_shift_value=1:31
    for i=1:x_2-Set_2_rows_shift_value-1
        Set_2_rows_shift(i+Set_2_rows_shift_value-1,:,:)=...
            Matrix_3D_set_2_registration_levels(i,:,:);
    end
    Set_2_levels_checked=...
        Set_2_rows_shift(:,:,slice_checked);
    Set_levels_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_positive=sum(sum(abs(Set_levels_diff)));
    values_rows_positive(1,Set_2_rows_shift_value)=sum_positive;
end
%% ------------------ Second loop ('Negative' shift) ------------------- %%
values_rows_negative=zeros(1,30);
Set_2_rows_shift=zeros(x_2, y_2, z_2);
for Set_2_rows_shift_value=1:30
    for i=1:x_2-Set_2_rows_shift_value
        Set_2_rows_shift(i,:,:)=...
            Matrix_3D_set_2_registration_levels(...
            i+Set_2_rows_shift_value,:,:);
    end
    Set_2_levels_checked=...
        Set_2_rows_shift(:,:,slice_checked);
    Set_levels_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_negative=sum(sum(abs(Set_levels_diff)));
    values_rows_negative(1,Set_2_rows_shift_value)=sum_negative;
end
values_rows_negative_flip=fliplr(values_rows_negative);
%% ---------------------- Sensitivity analysis ------------------------- %%
values_rows_final=horzcat(values_rows_negative_flip,values_rows_positive);
plot((-30:30),values_rows_final)
% -------------------------- Save the plot ----------------------------- %
%% ---------------- If statement to find optimal value ----------------- %%
[num_pix_rows_positive,optimal_shift_value_rows_positive_raw]=...
    min(values_rows_positive);
[num_pix_rows_negative,optimal_shift_value_rows_negative_raw]=...
    min(values_rows_negative_flip);
Optimal_shift_value_positive=optimal_shift_value_rows_positive_raw-1;
Optimal_shift_value_negative=optimal_shift_value_rows_negative_raw-31;
if num_pix_rows_positive<num_pix_rows_negative
    disp(strcat('Optimal shift value in rows:  ',...
        num2str(Optimal_shift_value_positive)))
    Set_2_rows_shift_value=Optimal_shift_value_positive;
else
     disp(strcat('Optimal shift value in rows:  ',...
        num2str(Optimal_shift_value_negative)))
    Set_2_rows_shift_value=Optimal_shift_value_negative;
end
%% -------- Creating new matrix with better alignment in rows ---------- %%
% ------------------ Setting up "empty" 3D matrix ---------------------- %
Matrix_3D_set_2_registration_rows=zeros(x_2, y_2, z_2);
if Set_2_rows_shift_value==0
    Matrix_3D_set_2_registration_rows=Matrix_3D_set_2_registration_levels;
elseif num_pix_rows_positive<num_pix_rows_negative
    for i=1:x-Set_2_levels_shift_value
        Matrix_3D_set_2_registration_rows(i,:,:)=...
            Matrix_3D_set_2_registration_levels...
            (i+Set_2_rows_shift_value,:,:);
    end
else
    for i=1:x_2+Set_2_levels_shift_value
        Matrix_3D_set_2_registration_rows(i,:,:)=...
            Matrix_3D_set_2_registration_levels...
            (i-Set_2_rows_shift_value,:,:);
    end
end
%% -------------------------- Save the matrix -------------------------- %%
%% --------------------------------------------------------------------- %%
clear Matrix_3D_set_2_registration_levels num_pix_rows_negative ...
    num_pix_rows_positive Optimal_shift_value_negative ...
    Optimal_shift_value_positive optimal_shift_value_rows_negative_raw...
    optimal_shift_value_rows_positive_raw Set_2_levels_checked...
    Set_2_rows_shift Set_2_rows_shift_value Set_levels_diff sum_negative...
    sum_positive values_rows_final values_rows_negative...
    values_rows_negative_flip values_rows_positive i
%% ------------------- Columns (y) dimension alignment ----------------- %%
%% -------------------- First loop ('Positive' shift) ------------------ %%
values_columns_positive=zeros(1,31);
Set_2_columns_shift=zeros(x_2, y_2, z_2);
for Set_2_columns_shift_value=1:31
    for i=1:y_2-Set_2_columns_shift_value-1
        Set_2_columns_shift(:,i+Set_2_columns_shift_value-1,:)=...
            Matrix_3D_set_2_registration_rows(:,i,:);
    end
    Set_2_levels_checked=...
        Set_2_columns_shift(:,:,slice_checked);
    Set_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_positive=sum(sum(abs(Set_diff)));
    values_columns_positive(1,Set_2_columns_shift_value)=sum_positive;
end
%% -------------------- Second loop ('Negative' shift) ----------------- %%
values_columns_negative=zeros(1,30);
Set_2_columns_shift=zeros(x_2, y_2, z_2);
for Set_2_columns_shift_value=1:30
    for i=1:y_2-Set_2_columns_shift_value
        Set_2_columns_shift(i,:,:)=...
            Matrix_3D_set_2_registration_rows(...
            i+Set_2_columns_shift_value,:,:);
    end
    Set_2_levels_checked=...
        Set_2_columns_shift(:,:,slice_checked);
    Set_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_negative=sum(sum(abs(Set_diff)));
    values_columns_negative(1,Set_2_columns_shift_value)=sum_negative;
end
values_columns_negative_flip=fliplr(values_columns_negative);
%% ---------------------- Sensitivity analysis ------------------------- %%
values_columns_final=horzcat...
    (values_columns_negative_flip,values_columns_positive);
plot((-30:30),values_columns_final)
%% ---------------- If statement to find optimal value ----------------- %%
[num_pix_columns_positive,optimal_value_shift_columns_positive_raw]=...
    min(values_columns_positive);
[num_pix_columns_negative,optimal_value_shift_columns_negative_raw]=...
    min(values_columns_negative_flip);
Optimal_shift_value_positive=optimal_value_shift_columns_positive_raw-1;
Optimal_shift_value_negative=optimal_value_shift_columns_negative_raw-31;
if num_pix_columns_positive<num_pix_columns_negative
    disp(strcat('Optimal shift value in columns:  ',...
        num2str(Optimal_shift_value_positive)))
    Set_2_columns_shift_value=Optimal_shift_value_positive;
else
     disp(strcat('Optimal shift value in columns:  ',...
        num2str(Optimal_shift_value_negative)))
    Set_2_columns_shift_value=Optimal_shift_value_negative;
end
%% -------- Creating new matrix with better alignment in columns ------- %%
% ------------------ Setting up "empty" 3D matrix ---------------------- %
Matrix_3D_set_2_registration_columns=zeros(x_2, y_2, z_2);
if Set_2_columns_shift_value==0
    Matrix_3D_set_2_registration_columns=Matrix_3D_set_2_registration_rows;
elseif num_pix_columns_positive<num_pix_columns_negative
    for i=1:y_2-Set_2_columns_shift_value
        Matrix_3D_set_2_registration_columns(:,i,:)=...
            Matrix_3D_set_2_registration_rows...
            (:,i+Set_2_columns_shift_value,:);
    end
else
    for i=1:y_2+Set_2_columns_shift_value
        Matrix_3D_set_2_registration_columns(:,i,:)=...
            Matrix_3D_set_2_registration_rows...
            (:,i-Set_2_columns_shift_value,:);
    end
end
%% -------------------------- Save the matrix -------------------------- %%
%% --------------------------------------------------------------------- %%
clear Matrix_3D_set_2_registration_rows i num_pix_columns_negative...
    num_pix_columns_positive Optimal_shift_value_negative ...
    Optimal_shift_value_positive optimal_value_shift_columns_negative_raw...
    optimal_value_shift_columns_positive_raw Set_2_levels_checked...
    Set_2_columns_shift Set_2_columns_shift_value Set_2_rows_shift_value...
    Set_diff sum_negative sum_positive values_columns_final ...
    values_columns_negative values_columns_negative_flip ...
    values_columns_positive
%% ---------------------- Angular shift alignment ---------------------- %%
%% ------------------ Finding new centre of rotation ------------------- %%
slice_checked_2=230;
figure
subplot(1,2,1)
imagesc(Matrix_3D_set_1(:,:,slice_checked_2)), hold on
plot([100 300],[34 34]),hold off
subplot(1,2,2)
imagesc(Matrix_3D_set_2_registration_columns(:,:,slice_checked_2)), hold on
plot([100 300],[34 34]), hold off
colormap gray
%% ------------------- Setting new centre of rotation ------------------ %%
y_new_centre=206;
x_new_centre=34;
% ------------------------------ STEP 1 -------------------------------- %
x_added_step_1=x_2-2*x_new_centre;
Set_2_new_centre_step1=...
    zeros(x_2+x_added_step_1, y_2, z_2);
Set_2_new_centre_step1(x_added_step_1:end-1,:,:)=...
    Matrix_3D_set_2_registration_columns(:,:,:);
% ------------------------------ STEP 2 -------------------------------- %
y_added_step_2=y_2-2*y_new_centre;
Set_2_new_centre_step2=...
    zeros(x_2+x_added_step_1, y_2+y_added_step_2, z_2);
Set_2_new_centre_step2(:,y_added_step_2:end-1,:)=...
    Set_2_new_centre_step1(:,:,:);
% ----------------------------- Testing -------------------------------- %
imagesc(Set_2_new_centre_step2(:,:,slice_checked_2))
colormap gray
%% ------------ Rearanging Set 1 matrix for testing purposes ----------- %%
% ------------------------------ STEP 1 -------------------------------- %
Set_1_new_centre_step1=...
    zeros(x_2+x_added_step_1, y_2, z_2);
Set_1_new_centre_step1(x_added_step_1:end-1,:,:)=...
    Matrix_3D_set_1(:,:,:);
% ------------------------------ STEP 2 -------------------------------- %
Set_1_new_centre_step2=...
    zeros(x_2+x_added_step_1, y_2+y_added_step_2, z_2);
Set_1_new_centre_step2(:,y_added_step_2:end-1,:)=...
    Set_1_new_centre_step1(:,:,:);
% ----------------------------- Testing -------------------------------- %
imagesc(Set_1_new_centre_step2(:,:,slice_checked_2))
colormap gray
%% ----------------------  Fiding optimal angle ------------------------ %%
%% ------------------- First loop ('Positive' shift) ------------------- %%
angle_values_positive=zeros(1,11);
Set_1_angle_checked=Set_1_new_centre_step2(:,:,slice_checked_2);
for Set_2_angle_shift_value=1:11
    Set_2_angular_rotation=imrotate(...
        Set_2_new_centre_step2,Set_2_angle_shift_value-1,'crop');
    Set_diff_angles=(Set_1_angle_checked>1700)...
        -(Set_2_angular_rotation(:,:,slice_checked_2)>2300);
    sum_positive=sum(sum(abs(Set_diff_angles)));
    angle_values_positive(1,Set_2_angle_shift_value)=sum_positive;
end
%% ------------------- Second loop ('Negative' shift) ------------------ %%
angle_value_negative=zeros(1,10);
for Set_2_angle_shift_value=1:10
    Set_2_angular_rotation=imrotate(...
        Set_2_new_centre_step2,-Set_2_angle_shift_value,'crop');
    Set_diff_angles=(Set_1_angle_checked>1700)...
        -(Set_2_angular_rotation(:,:,slice_checked_2)>2300);
    sum_negative=sum(sum(abs(Set_diff_angles)));
    angle_value_negative(1,Set_2_angle_shift_value)=sum_negative;
end
angles_value_negative_flip=fliplr(angle_value_negative);
%% ---------------------- Sensitivity analysis ------------------------- %%
angle_value_final=horzcat(angles_value_negative_flip,angle_values_positive);
plot((-10:10),angle_value_final)
%% ----------------- If statement to find optimal value ---------------- %%
[num_pix_angle_shift_positive,optimal_angle_shift_positive_raw]=...
    min(angle_values_positive);
[num_pix_angle_shift_negative,optimal_angle_shift_negative_raw]=...
    min(angles_value_negative_flip);
Optimal_shift_value_positive=optimal_angle_shift_positive_raw-1;
Optimal_shift_value_negative=optimal_angle_shift_negative_raw-10;
if num_pix_angle_shift_positive<num_pix_angle_shift_negative
    disp(strcat('Optimal shift value in angle:  ',...
        num2str(Optimal_shift_value_positive), ' degrees'))
        Set_2_angle_shift_value=Optimal_shift_value_positive;
else
    disp(strcat('Optimal shift value in angle: -  ',...
        num2str(Optimal_shift_value_negative),' degrees'))
        Set_2_angle_shift_value=Optimal_shift_value_negative;
end
%% --------------------------------------------------------------------- %%
clear Set_1_new_centre_step1 Set_2_new_centre_step1 ...
    Set_2_angular_rotation angle_value_final angle_value_negative...
    angle_values_positive angles_value_negative_flip...
    num_pix_angle_shift_negative num_pix_angle_shift_positive...
    optimal_angle_shift_negative_raw optimal_angle_shift_positive_raw...
    Optimal_shift_value_negative Optimal_shift_value_positive...
    Set_1_angle_checked Set_diff_angles sum_negative sum_positive
%% ------------------ Visualisation of angle alignment ----------------- %%
Set_2_angle_alignment=imrotate(...
    Set_2_new_centre_step2,Set_2_angle_shift_value,'crop');
figure
subplot(1,3,1)
imagesc(Set_1_new_centre_step2(:,:,slice_checked_2))
subplot(1,3,2)
imagesc(Set_2_angle_alignment(:,:,slice_checked_2))
subplot(1,3,3)
output_of_angular_shifting=...
    (Set_1_new_centre_step2(:,:,slice_checked_2)>1700)-...
    (Set_2_angle_alignment(:,:,slice_checked_2)>1700);
imagesc(output_of_angular_shifting)
colormap gray
%% ------------------------ Cropping matrix ---------------------------- %%
Matrix_3D_set_2_registration_angle=zeros(x_2, y_2, z_2);
Matrix_3D_set_2_registration_angle(:,:,:)=...
    Set_2_angle_alignment(x_added_step_1:end-1,y_added_step_2:end-1,:);
%% -------------------------- Save the matrix -------------------------- %%
%% --------------------------------------------------------------------- %%
clear Matrix_3D_set_2_registration_columns output_of_angular_shifting...
    Set_1_new_centre_step2 Set_2_angle_alignment Set_2_angle_shift_value...
    Set_2_new_centre_step2 x_added_step_1 x_new_centre y_added_step_2...
    y_new_centre
%% -------------- Second check rows and columns alignment -------------- %%
%% ------------ Rows (x) dimension alignment - SECOND CHECK ------------ %%
%% ------------------- First loop ('Positive' shift) ------------------- %%
values_rows_positive=zeros(1,31);
Set_2_rows_shift=zeros(x_2, y_2, z_2);
for Set_2_rows_shift_value=1:31
    for i=1:x_2-Set_2_rows_shift_value-1
        Set_2_rows_shift(i+Set_2_rows_shift_value-1,:,:)=...
            Matrix_3D_set_2_registration_angle(i,:,:);
    end
    Set_2_levels_checked=...
        Set_2_rows_shift(:,:,slice_checked);
    Set_levels_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_positive=sum(sum(abs(Set_levels_diff)));
    values_rows_positive(1,Set_2_rows_shift_value)=sum_positive;
end
%% ------------------ Second loop ('Negative' shift) ------------------- %%
values_rows_negative=zeros(1,30);
Set_2_rows_shift=zeros(x_2, y_2, z_2);
for Set_2_rows_shift_value=1:30
    for i=1:x_2-Set_2_rows_shift_value
        Set_2_rows_shift(i,:,:)=...
            Matrix_3D_set_2_registration_angle(...
            i+Set_2_rows_shift_value,:,:);
    end
    Set_2_levels_checked=...
        Set_2_rows_shift(:,:,slice_checked);
    Set_levels_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_negative=sum(sum(abs(Set_levels_diff)));
    values_rows_negative(1,Set_2_rows_shift_value)=sum_negative;
end
values_rows_negative_flip=fliplr(values_rows_negative);
%% ---------------------- Sensitivity analysis ------------------------- %%
figure
values_rows_final=horzcat(values_rows_negative_flip,values_rows_positive);
plot((-30:30),values_rows_final)
% -------------------------- Save the plot ----------------------------- %
%% ---------------- If statement to find optimal value ----------------- %%
[num_pix_rows_positive,optimal_shift_value_rows_positive_raw]=...
    min(values_rows_positive);
[num_pix_rows_negative,optimal_shift_value_rows_negative_raw]=...
    min(values_rows_negative_flip);
Optimal_shift_value_positive=optimal_shift_value_rows_positive_raw-1;
Optimal_shift_value_negative=optimal_shift_value_rows_negative_raw-31;
if num_pix_rows_positive<num_pix_rows_negative
    disp(strcat('Optimal shift value in rows:  ',...
        num2str(Optimal_shift_value_positive)))
    Set_2_rows_shift_value=Optimal_shift_value_positive;
else
     disp(strcat('Optimal shift value in rows:  ',...
        num2str(Optimal_shift_value_negative)))
    Set_2_rows_shift_value=Optimal_shift_value_negative;
end
%% -------- Creating new matrix with better alignment in rows ---------- %%
% ------------------ Setting up "empty" 3D matrix ---------------------- %
Matrix_3D_set_2_registration_rows_second_check=zeros(x_2, y_2, z_2);
if Set_2_rows_shift_value==0
    Matrix_3D_set_2_registration_rows_second_check=Matrix_3D_set_2_registration_angle;
elseif num_pix_rows_positive<num_pix_rows_negative
    for i=1:x-Set_2_rows_shift_value
        Matrix_3D_set_2_registration_rows_second_check(i,:,:)=...
            Matrix_3D_set_2_registration_angle...
            (i+Set_2_rows_shift_value,:,:);
    end
else
    for i=1:x_2+Set_2_rows_shift_value
        Matrix_3D_set_2_registration_rows_second_check(i,:,:)=...
            Matrix_3D_set_2_registration_angle...
            (i-Set_2_rows_shift_value,:,:);
    end
end
%% -------------------------- Save the matrix -------------------------- %%
%% --------------------------------------------------------------------- %%
clear i Matrix_3D_set_2_registration_angle num_pix_rows_negative...
    num_pix_rows_positive Optimal_shift_value_negative ...
    Optimal_shift_value_positive optimal_shift_value_rows_negative_raw...
    optimal_shift_value_rows_positive_raw Set_2_levels_checked...
    Set_2_rows_shift Set_2_rows_shift_value Set_levels_diff sum_negative...
    sum_positive values_rows_final values_rows_negative ...
    values_rows_negative_flip values_rows_positive
%% ------------ Columns (y) dimension alignment - SECOND CHECK --------- %%
%% -------------------- First loop ('Positive' shift) ------------------ %%
values_columns_positive=zeros(1,31);
Set_2_columns_shift=zeros(x_2, y_2, z_2);
for Set_2_columns_shift_value=1:31
    for i=1:y_2-Set_2_columns_shift_value-1
        Set_2_columns_shift(:,i+Set_2_columns_shift_value-1,:)=...
            Matrix_3D_set_2_registration_rows_second_check(:,i,:);
    end
    Set_2_levels_checked=...
        Set_2_columns_shift(:,:,slice_checked);
    Set_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_positive=sum(sum(abs(Set_diff)));
    values_columns_positive(1,Set_2_columns_shift_value)=sum_positive;
end
%% -------------------- Second loop ('Negative' shift) ----------------- %%
values_columns_negative=zeros(1,30);
Set_2_columns_shift=zeros(x_2, y_2, z_2);
for Set_2_columns_shift_value=1:30
    for i=1:y_2-Set_2_columns_shift_value
        Set_2_columns_shift(i,:,:)=...
            Matrix_3D_set_2_registration_rows_second_check(...
            i+Set_2_columns_shift_value,:,:);
    end
    Set_2_levels_checked=...
        Set_2_columns_shift(:,:,slice_checked);
    Set_diff=(Set_1_levels_checked>1700)-(Set_2_levels_checked>2300);
    sum_negative=sum(sum(abs(Set_diff)));
    values_columns_negative(1,Set_2_columns_shift_value)=sum_negative;
end
values_columns_negative_flip=fliplr(values_columns_negative);
%% ---------------------- Sensitivity analysis ------------------------- %%
figure
values_columns_final=horzcat...
    (values_columns_negative_flip,values_columns_positive);
plot((-30:30),values_columns_final)
%% ---------------- If statement to find optimal value ----------------- %%
[num_pix_columns_positive,optimal_value_shift_columns_positive_raw]=...
    min(values_columns_positive);
[num_pix_columns_negative,optimal_value_shift_columns_negative_raw]=...
    min(values_columns_negative_flip);
Optimal_shift_value_positive=optimal_value_shift_columns_positive_raw-1;
Optimal_shift_value_negative=optimal_value_shift_columns_negative_raw-31;
if num_pix_columns_positive<num_pix_columns_negative
    disp(strcat('Optimal shift value in columns:  ',...
        num2str(Optimal_shift_value_positive)))
    Set_2_columns_shift_value=Optimal_shift_value_positive;
else
     disp(strcat('Optimal shift value in columns:  ',...
        num2str(Optimal_shift_value_negative)))
    Set_2_columns_shift_value=Optimal_shift_value_negative;
end
%% -------- Creating new matrix with better alignment in columns ------- %%
% ------------------ Setting up "empty" 3D matrix ---------------------- %
Matrix_3D_set_2_registration_columns_second_check=zeros(x_2, y_2, z_2);
if Set_2_columns_shift_value==0
    Matrix_3D_set_2_registration_columns_second_check=...
        Matrix_3D_set_2_registration_rows_second_check;
elseif num_pix_columns_positive<num_pix_columns_negative
    for i=1:y_2-Set_2_columns_shift_value
        Matrix_3D_set_2_registration_columns_second_check(:,i,:)=...
            Matrix_3D_set_2_registration_rows_second_check...
            (:,i+Set_2_columns_shift_value,:);
    end
else
    for i=1:y_2+Set_2_columns_shift_value
        Matrix_3D_set_2_registration_columns_second_check(:,i,:)=...
            Matrix_3D_set_2_registration_rows_second_check...
            (:,i-Set_2_columns_shift_value,:);
    end
end
%% -------------------------- Save the matrix -------------------------- %%
%% --------------------------------------------------------------------- %%
clear i Matrix_3D_set_2_registration_rows_second_check...
    num_pix_columns_negative num_pix_columns_positive...
    optimal_value_shift_columns_negative_raw values_columns_negative...
    optimal_value_shift_columns_positive_raw Set_2_columns_shift...
    Set_2_columns_shift_value Set_diff values_columns_final...
    values_columns_negative_flip values_columns_positive
%% ---------------------- Complete registration ------------------------ %%
Matrix_3D_set_2_registration_completed =...
    Matrix_3D_set_2_registration_columns_second_check;
%% -------------------------- Save the matrix -------------------------- %%