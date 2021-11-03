%% Feedforward backpropagating netwrok
% clear all; clc;
% data = load('train.csv');
% labels = data(:,1);
% n_patient = length(labels);
% y = zeros(2,n_patient); %Correct outputs vector
% 
% for i = 1:n_patient
%     y(labels(i)+1,i) = 1;
% end
% 
% waves = data(:,2:201)';
% % waves = waves ./ max(waves(:));
% % waves = waves';
% 
% net = patternnet(10);
% 
% net = train(net,waves,y);

%% 
clc; clear all;
data = load('train.csv');
labels = data(:,1);
n_patient = length(labels);
y = zeros(2,n_patient); %Correct outputs vector

for i = 1:n_patient
    y(labels(i)+1,i) = 1;
end

waves = data(:,2:201);
waves = waves ./ max(waves(:));
waves = waves';

hn1 = 40; %Number of neurons in the first hidden layer
hn2 = 20; %Number of neurons in the second hidden layer

%Initializing weights and biases
w12 = randn(hn1,200)*sqrt(2/200);
w23 = randn(hn2,hn1)*sqrt(2/hn1);
w34 = randn(2,hn2)*sqrt(2/hn2);
b12 = randn(hn1,1);
b23 = randn(hn2,1);
b34 = randn(2,1);

%learning rate
eta = 0.005;

%Initializing errors and gradients
error4 = zeros(2,1);
error3 = zeros(hn2,1);
error2 = zeros(hn1,1);
errortot4 = zeros(10,1);
errortot3 = zeros(hn2,1);
errortot2 = zeros(hn1,1);
grad4 = zeros(2,1);
grad3 = zeros(hn2,1);
grad2 = zeros(hn1,1);

epochs = 100;

m = 2; %Minibatch size

for k = 1:epochs %Outer epoch loop
    
    batches = 1;
    
    for j = 1:n_patient/m
        error4 = zeros(2,1);
        error3 = zeros(hn2,1);
        error2 = zeros(hn1,1);
        errortot4 = zeros(2,1);
        errortot3 = zeros(hn2,1);
        errortot2 = zeros(hn1,1);
        grad4 = zeros(2,1);
        grad3 = zeros(hn2,1);
        grad2 = zeros(hn1,1);
    for i = batches:batches+m-1 %Loop over each minibatch
    
    %Feed forward
    a1 = waves(:,i);
    z2 = w12*a1 + b12;
    a2 = elu(z2);
    z3 = w23*a2 + b23;
    a3 = elu(z3);
    z4 = w34*a3 + b34;
    a4 = elu(z4); %Output vector
    
    %backpropagation
    error4 = (a4-y(:,i)).*elup(z4);
    error3 = (w34'*error4).*elup(z3);
    error2 = (w23'*error3).*elup(z2);
    
    errortot4 = errortot4 + error4;
    errortot3 = errortot3 + error3;
    errortot2 = errortot2 + error2;
    grad4 = grad4 + error4*a3';
    grad3 = grad3 + error3*a2';
    grad2 = grad2 + error2*a1';

    end
    
    %Gradient descent
    w34 = w34 - eta/m*grad4;
    w23 = w23 - eta/m*grad3;
    w12 = w12 - eta/m*grad2;
    b34 = b34 - eta/m*errortot4;
    b23 = b23 - eta/m*errortot3;
    b12 = b12 - eta/m*errortot2;
    
    batches = batches + m;
    
    end
    fprintf('Epochs:');
    disp(k) %Track number of epochs
    [waves,y] = shuffle(waves,y); %Shuffles order of the images for next epoch
end

disp('Training done!')
%% Saves the parameters
save('wfour.mat','w34');
save('wthree.mat','w23');
save('wtwo.mat','w12');
save('bfour.mat','b34');
save('bthree.mat','b23');
save('btwo.mat','b12');

%% Testing
clc; clear all;
testing_data = load('test.csv');

labels = testing_data(:,1);
n_patient = length(labels);
y = zeros(2,n_patient); %Correct outputs vector

for i = 1:n_patient
    y(labels(i)+1,i) = 1;
end

waves = testing_data(:,2:201);
waves = waves ./ max(waves(:));
waves = waves';
we34 = matfile('wfour.mat');
w4 = we34.w34;
we23 = matfile('wthree.mat');
w3 = we23.w23;
we12 = matfile('wtwo.mat');
w2 = we12.w12;
bi34 = matfile('bfour.mat');
b4 = bi34.b34;
bi23 = matfile('bthree.mat');
b3 = bi23.b23;
bi12 = matfile('btwo.mat');
b2 = bi12.b12;
success = 0;
n = length(labels);
for i = 1:n
out2 = elu(w2*waves(:,i)+b2);
out3 = elu(w3*out2+b3);
out = elu(w4*out3+b4);
big = 0;
num = 0;
for k = 1:2
    if out(k) > big
        num = k-1;
        big = out(k);
    end
end

if labels(i) == num
    success = success + 1;
end
    

end

fprintf('Accuracy: ');
fprintf('%f',success/n*100);
disp(' %');







