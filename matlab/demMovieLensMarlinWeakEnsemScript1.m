function [] = demMovieLensMarlinWeakScript1(substract_mean, partNo_v, latentDim_v,iters, inverted, type)
% DEMMOVIELENSMARLINWEAKSCRIPT1 Try collaborative filtering on the EachMovie data with
% Marlins partitions
% where the weak movielens experiment
%
  % demMovieLensMarlinWeakScript1(substract_mean, partNo_v,
				  % latentDim_v,iters, inverted, type)
%
% substract_mean --> bool if substract the mean
% partNo_v --> vector with the partitions to compute results
% latentDim_v --> vector with the latent dimensionalities to compute results
% iters --> number of iterations
% if inverted = true, then learn users as examples and not movies
% type --> weak or strong

randn('seed', 1e5);
rand('seed', 1e5);

experimentNo = 3;


predictions = zeros(length(latentDim_v),length(partNo_v));
modelsActive = ones(length(latentDim_v),length(partNo_v));

%partNo_v = [1:5];
%latentDim_v = [5, 2:4, 6];



% for each partition load the data
    for i_part=1:length(partNo_v)
        partNo = partNo_v(i_part);
numActive = 0;
allModels = [];
 
        dataSetName = ['movielens_marlin_',type,'_',num2str(partNo)];
        
        disp(['Reading ... ',dataSetName]);
        
        [Y, lbls, Ytest] = lvmLoadData(dataSetName);

        if (inverted)
            Y = Y';
            Ytest = Y';
        end
        
	numFilms = size(Y,1);
        numUsers = size(Y,2);
        meanFilms = zeros(numFilms,1);
        stdFilms = ones(numFilms,1);
        
        if (substract_mean)
            if 0
                % this substract the global mean
                % create the total vector
                s = nonzeros(Ytest);
                ratings = [nonzeros(Y); nonzeros(Ytest)];
                meanY = mean(ratings);
                stdY = std(ratings);
                %keyboard;
                index = find(Y);
                Y(index) = Y(index) - meanY;
                Y(index) = Y(index) / stdY;
            else
                 for i=1:numFilms
                    % compute the mean and standard deviation of each film
                    ind = find(Y(i,:));
                    mean_v = sum(Y(i,ind));
                    mean_v = mean_v + sum(nonzeros(Ytest(i,:)));
                    length_v = length(ind) + nnz(Ytest(i,:));
                    mean_v = mean_v/length_v;
                    std_v = (length(ind)*std(Y(i,ind)) + nnz(Ytest(i,:))*std(Ytest(i,:)))/length_v;
                    Y(i,ind) = Y(i,ind) - mean_v;
                    if (std_v>0) 
                        Y(i,ind) = Y(i,ind)/std_v;
                    end
                    meanFilms(i) = mean_v;
                    stdFilms(i) = std_v;
                end
            end
            %keyboard;
        end

	for i_latent=1:length(latentDim_v)
	  q = latentDim_v(i_latent);

% load the model
        % Save the results.
        capName = dataSetName;
        capName(1) = upper(capName(1));
        
        loadResults = [capName,'inverted_',num2str(inverted),'_norm_',num2str(substract_mean),'_',num2str(q),'_',num2str(partNo),'_iters_',num2str(iters),'.mat'];
        disp(['Loading ... ',loadResults]);
try
	load(loadResults);
catch
disp(['Model not found ',loadResults]);
%keyboard;
continue;
end
numActive = numActive + 1;
allModels{numActive} = model;


%modelsActive(q) = 1;
end


%%%%%%%%
% compute the test error
disp('Computing test error');

% compute the test error for ensembles of models

if strcmp(type,'weak')

  [L2_error,NMAE_error,NMAE_round_error] = computeTestErrorEnsemblesWeak(allModels,Y,Ytest)
 else if strcmp(type,'strong')

[L2_error,NMAE_error,NMAE_round_error] = computeTestErrorEnsemblesWeak(allModels,lbls,Ytest)
end
end

%[mu] = computePredictionsErrorWeak(model,Y,Ytest)

        % Save the results.
        capName = dataSetName;
        capName(1) = upper(capName(1));
        
saveResults = [capName,'inverted_',num2str(inverted),'_norm_',num2str(substract_mean),'_',num2str(partNo),'_iters_',num2str(iters),'_ensembles.mat'];
        disp(['Saving ... ',saveResults]);
save(saveResults, 'allModels', 'L2_error','options','NMAE_error','NMAE_round_error','modelsActive');
    end
  
  

