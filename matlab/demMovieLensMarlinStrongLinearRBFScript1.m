function [] = demMovieLensMarlinStrongLinearRBFScript1(substract_mean, partNo_v, latentDim_v,iters, inverted, new_iters)
% DEMMOVIELENSMARLINSTRONGLINEARRBFSCRIPT1 Try collaborative filtering on the EachMovie data with
% Marlins partitions
% where the weak movielens experiment
%
  % demMovieLensMarlinStrongLinearRBFScript1(substract_mean, partNo_v,
				  % latentDim_v,iters, inverted, new_iters)
%
% substract_mean --> bool if substract the mean
% partNo_v --> vector with the partitions to compute results
% latentDim_v --> vector with the latent dimensionalities to compute results
% iters --> number of iterations of the linear model already learned
% if inverted = true, then learn users as examples and not movies
% new_iters --> number of iters to do of the new model

randn('seed', 1e5);
rand('seed', 1e5);

experimentNo = 3;


%partNo_v = [1:5];
%latentDim_v = [5, 2:4, 6];


for i_latent=1:length(latentDim_v)
    q = latentDim_v(i_latent);
    for i_part=1:length(partNo_v)
        partNo = partNo_v(i_part);
        
        dataSetName = ['movielens_marlin_strong_',num2str(partNo)];
        
        disp(['Reading ... ',dataSetName]);
        
        [Y, lbls, Ytest] = lvmLoadData(dataSetName);

        Ytraintest = lbls;
        

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
                %Y(index) = Y(index) - meanY;
                %Y(index) = Y(index) / stdY;
            else
                 for i=1:numFilms
                    % compute the mean and standard deviation of each film
                    ind = find(Y(i,:));
                    mean_v = sum(Y(i,ind));
                    mean_v = mean_v + sum(nonzeros(Ytest(i,:)));
                    length_v = length(ind) + nnz(Ytest(i,:));
                    mean_v = mean_v/length_v;
                    std_v = (length(ind)*std(Y(i,ind)) + nnz(Ytest(i,:))*std(Ytest(i,:)))/length_v;
                    %Y(i,ind) = Y(i,ind) - mean_v;
                    %if (std_v>0) 
                    %    Y(i,ind) = Y(i,ind)/std_v;
                    %end
                    %meanFilms(i) = mean_v;
                    %stdFilms(i) = std_v;
                end
            end
            %keyboard;
        end

        options = collabOptions;


%%% load the linear kernel results
% Save the results.
        capName = dataSetName;
        capName(1) = upper(capName(1));
        
        loadResults = [capName,'_linear_inverted_',num2str(inverted),'_norm_',num2str(substract_mean),'_',num2str(q),'_',num2str(partNo),'_iters_',num2str(iters),'.mat'];
        disp(['Loading ... ',loadResults]);
kk = load(loadResults);

% expand the parameters...
param_opt = kernExtractParam(kk.model.kern)

% change the options to have a linear kernel
	options.kern = {'lin', 'bias', 'white','rbf'};
        model = collabCreate(q, size(Y, 2), size(Y, 1), options);
        % keyboard;
        if (substract_mean)
            if 0
                % this does the global mean
                model.mu = repmat(meanY,size(model.mu,1),1);
                model.sd = repmat(stdY,size(model.sd,1),1);
            else
                model.mu = meanFilms;
                model.sd = stdFilms;
            end
            
        end
        model.kern.comp{2}.variance = 0.11;
        model.kern.comp{3}.variance =  5; 
model.kern.comp{4}.variance = 0.2;
param_new = kernExtractParam(model.kern)
param_new(1:length(param_opt)) = param_opt;
model.kern = kernExpandParam(model.kern,param_new);
param_modif = kernExtractParam(model.kern)



        options = collabOptimiseOptions;
        

        % set parameters
        options.momentum = 0.9;
        options.learnRate = 0.0001;
        options.paramMomentum = 0.9;
        options.paramLearnRate = 0.0001;
        options.numIters = new_iters;
        options.showLikelihood = false;

        capName = dataSetName;
        capName(1) = upper(capName(1));
options.saveName = ['dem' capName num2str(experimentNo) '_'];

        model = collabOptimise(model, Y, options)

	% compute the test error
	  disp('Computing test error');

%keyboard; % check if we want an kernel width


[L2_error,NMAE_error,NMAE_round_error] = computeTestErrorWeak(model,Ytraintest,Ytest)


        % Save the results.
        capName = dataSetName;
        capName(1) = upper(capName(1));
        
saveResults = [capName,'_linear_RBF_inverted_',num2str(inverted),'_norm_',num2str(substract_mean),'_',num2str(q),'_',num2str(partNo),'_iters_',num2str(iters),'_newiters_',num2str(new_iters),'.mat'];
        disp(['Saving ... ',saveResults]);
        save(saveResults, 'model', 'L2_error','options','NMAE_error','NMAE_round_error');
    end
end



