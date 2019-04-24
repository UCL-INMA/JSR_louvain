% DEMO2_JSR - Model script for the launch of two methods
%
% Example on setting matrices in a cell array, setting advanced 
% options, launching two methods one after another and  
% retrieving and plotting information on a same plot 
% for comparison.
%
% Explanations are in the comments of the script.
% 
% type 
% 
% >> edit demo2_JSR 
% 
% to access this script without launching it.
%
% This demo uses jsr_norm_conitope which requires SeDuMi. One can verify
% that it is installed by watching the result of help sedumi for instance.
%
% 

clc
disp(' ')
disp(' ')
disp('--------------------- DEMO2 for JSR Toolbox ---------------------')
disp(' ')
disp(' ')
disp('Explanations are in the comments of the script.')
disp(' ')
disp('Type')
disp(' ')
disp('>> edit demo2_JSR')
disp(' ')
disp('To read the file and comments in the editor.')
disp(' ')
disp('The execution of this example takes around 5min on a normal computer.')
disp('jsr_norm_conitope will successfully stop at iteration 13.')
disp(' ')
disp('...this gives the time to understand the script during computations.')
disp(' ')
disp(' ')
disp('Press any key to open it in your editor and start ')
disp('the computations...')
pause

s = which('sedumi.m');
if isempty(s)
    error(['sedumi could not be found. Please install SeDuMi properly in order to run '...
        'this demo : http://perso.uclouvain.be/raphael.jungers/sites/default/files/sedumi.zip']);
end

edit demo2_JSR

% HERE STARTS THE SCRIPT AND ITS EXPLANATION
%
% First, we take a set of matrices into the workspace, for this demo we use
% a instance of A = rand(10,10,3) saved in demo2_JSR_rndmatrix.mat. 
% We load it

load demo2_JSR_rndmatrix.mat

% In the same way we could have generated the tensor with a function, 
% for instance, 
%
% A = genMat;

% If you have a few matrices A1, A2, A3, A4. You can set them into 
% a cell array this way:
% 
% M{1} = A1;
% M{2} = A2;
% M{3} = A3;
% M{4} = A4;
%
% Or equivalently:
%
% M = [{A1}, {A2}, {A3}, {A4}];
%

% If A is a tensor (3D array) [nxnxm double], we can use tens2cell to make
% it a cell array. This is the case here, hence,

M = tens2cell(A);


% We will compare the evolution of the bounds on M with
% jsr_norm_conitope and jsr_prod_pruningAlgorithm (note that the latter 
% algorithm requires the matrices to have non-negative entries).
%
% And also we will look at the evolution of the size of the population
% as both methods keep only a certain number of products.
%
% The set M or the matrices themselves might be large. So we ask the
% algorithms to save the results at each iteration.
% This allows to have some results even if we 
% end up stopping the algorithms before termination.
%
% For this purpose we can use the general (i.e. working for almost any method)
% saveinIt option.
%
% This will save the potential output at each 
% iteration in a user-specified .mat file:

opts_conitope = jsrsettings('saveinIt','myfile_conitope_inIteration');
opts_pruningAlg = jsrsettings('saveinIt','myfile_pruningAlg_inIteration');

% Feeding these option structures will tell the algorithms to save at each
% iteration in myfile_conitope_inIteration.mat
% and myfile_pruningAlg_inIteration.mat respectively.

% We also ask the algorithms to save in a .mat file in the end.
% We can do this by using jsrsettings on the options again and enabling 
% the general saveEnd option:

opts_conitope = jsrsettings(opts_conitope,'saveEnd','myfile_conitope_end');
opts_pruningAlg = jsrsettings(opts_pruningAlg,'saveEnd','myfile_pruningAlg_end');

% These files should have appeared in the current directory at the
% end of the execution.


% We can also tell the  algorithms to generate plots themselves in the end.
% They can only generate separate plots in different figures. 
% Nevertheless, we will retrieve the output structures info that contain 
% the data. From these we will make another figure with the two bounds.
%
% Finally, we want the version of the "conitope" method in which the
% algorithm does not reinitialize the unit ball:

opts_conitope = jsrsettings(opts_conitope,'conitope.plotBounds',1,'conitope.plotpopHist',1,'conitope.reinitBall',0);
opts_pruningAlg = jsrsettings(opts_pruningAlg,'pruning.plotBounds',1,'pruning.plotpopHist',1);

% All the names of these option fields can be found in the help of each
% method and in help jsrsettings for the general options. 


% Now we launch the methods one after another:

[bounds1, prodOpt, prodV, info_conitope] = jsr_norm_conitope(M,opts_conitope);

[bounds2, P, info_pruning] = jsr_prod_pruningAlgorithm(M,opts_pruningAlg);

% When those are done there should be four plots.
% The data is also contained in the respective info structures.

% In order to compare, on the same plot, the evolution of the bounds, we
% can do for instance :

% Retrieve information from the info structures
niter_con = info_conitope.niter; 
Lb_con = info_conitope.allLb;
Ub_con = info_conitope.allUb;

niter_prng = info_pruning.niter;
Lb_prng = info_pruning.allLb;
Ub_prng = info_pruning.allUb;

% Generate the plot with title and legend, this should be the fifth figure:

figure
h1 = plot(0:niter_con, Lb_con, '-+g',1:niter_con, Ub_con,'*-r'); hold on
h2 = plot(1:niter_prng, Lb_prng,'-oc',1:niter_prng,Ub_prng,'-.b');
title('Bounds found at each depth')
xlabel('depth')
legend([h1;h2],'Lb conitope','Ub conitope','Lb pruning','Ub pruning')

% Let us have a look at the optimal products given by each method.
% 
% conitope gives the index of an optimal product. This means that its 
% averaged spectral radius attains the lower bound. We can rebuild
% this product with buildProduct:
msg(-1,1,'\n Index of optimal product found by conitope : %s \n', num2str(prodOpt'))
msg(-1,1,'Corresponding matrix : opt1 = M{%d}*M{%d} = \n',prodOpt(2),prodOpt(1))
opt1 = buildProduct(M,prodOpt);
disp(opt1)
% Note the convention used for the order of product indices, it is further
% described in buildProducts

% pruning gives, in output P (a cell array), the indices of two products  
% attaining the lower and upper bound respectively.
msg(-1,1,'\n Index of product attaining lower bound found by pruningAlgorithm : %s \n', num2str(P{1}))
msg(-1,1,'Corresponding matrix : opt2 = M{%d}*M{%d} = \n',P{1}(2),P{1}(1))
opt2 = buildProduct(M,P{1});
disp(opt2)

% We can check that, as expected, the averaged spectral radii are the
% same:
% 
msg(-1,1,'rho(opt1)^(1/2) = %.14g \n',rho(opt1)^(1/2))
msg(-1,1,'rho(opt2)^(1/2) = %.14g \n',rho(opt2)^(1/2))

% We can also look at the evolution of the bounds found with respect to
% computation time. The structures info contain the time (in sec) at the 
% end of each iteration since the start of the algorithm.
%
% Let us retrieve this information from the structures and plot it
% on one graph.

time1 = (info_conitope.timeIter)/60; hold on
time2 = (info_pruning.timeIter)/60;

figure
hold on
h11 = plot([0 time1],info_conitope.allLb,'-+g',time1,info_conitope.allUb,'-*r','MarkerSize',10);
h22 = plot(time2,info_pruning.allLb,'-oc',time2,info_pruning.allUb,'-.b','MarkerSize',10);

xlabel('time from start in min')
title('Evolution of the bounds w.r.t. to time')
legend([h11;h22],'Lb conitope','Ub conitope','Lb pruning','Ub pruning')

% Note that conitope takes an iteration 0, this is why we had to plot for
% times [0 time1].
%
% You can observe that the pruning algorithm for this set of matrices was
% much faster than conitope but also gave less tight bounds.

