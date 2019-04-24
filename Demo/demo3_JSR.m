% DEMO3_JSR - jsr_pathcomplete tutorial
%
% Quick start guide for jsr_pathcomplete function.

clc;
clear all;
iMsg = 0;
totMsg = 9;

disp(' ')
disp(' ')
disp('--------------------- DEMO3 for JSR Toolbox ---------------------')
fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp('This demo shows how to use the method jsr_pathcomplete.')
disp('We start with a basic call to this function. Then, we will see how')
disp('to customize the main parameters.')
disp(' ')
disp(' ')
disp('Type CTRL-C to abort.')
disp(' ')
disp(' ')
disp('Press any key to start...')
disp('------------------------------------ ')
disp(' ')
disp(' ')
pause
iMsg=iMsg+1;


fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Let us first build two 2x2 matrices.')
disp(' ')
disp('>> M = {[-1 -1 ; -4 0],[3 3 ; -2 1]}')
disp(' ')
disp('This is the example 5.4 of [1].')
disp(' ')
disp('The joint spectral radius of this set has been proven to be = 3.917384715148...')
disp(' ')
disp('Press any key to launch this call...')
disp('------------------------------------ ')
disp(' ')
pause
iMsg=iMsg+1;

M = {[-1 -1 ; -4 0],[3 3 ; -2 1]}


fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Now, we can directly call :')
disp(' ')
disp('>> Ub = jsr_pathcomplete(M)')
disp(' ')
disp('Press any key to launch this call...')
disp('------------------------------------ ')
disp(' ')
pause
iMsg=iMsg+1;
[Ub] = jsr_pathcomplete(M);

disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause


fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('By default, the method uses a de Bruijn graph (see [1], [2], [3]) of dimension 1 ') 
disp('to compute the upper bound. This upper bound is inherent to the graph')
disp('used, and does not always achieve the actual JSR.')
disp(' ')
disp('Now, we can try increasing the number of nodes by increasing the')
disp('dimension of the de Bruijn graph.')
disp(' ')
disp('>> options = jsrsettings(''debruijn.dimension'',2); ')
disp('>> [Ub_dimension2] = jsr_pathcomplete(M,options) ')
disp(' ')
disp('Press any key to launch this call...')
disp('------------------------------------ ')
disp(' ')
pause
iMsg=iMsg+1;
options = jsrsettings('debruijn.dimension',2);
options = jsrsettings(options,'pathcomplete.reltol',1e-8);
[Ub_dimension2] = jsr_pathcomplete(M,options);

disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')

pause



fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('We can compare the Ub given by the two methods. The first one gives')
disp('3.9224 while the second one gives 3.9174. Indeed, the last value is  ')
disp('better than the first but demands more computational time.')
disp(' ')
disp('Press any key to continue ...')
disp('------------------------------------ ')
disp(' ')
pause
iMsg=iMsg+1;



adjacency_matrix_M1 = zeros(3);
adjacency_matrix_M2 = zeros(3);

adjacency_matrix_M1(1,1) = 1;
adjacency_matrix_M1(1,2) = 1;

adjacency_matrix_M2(1,3) = 1;
adjacency_matrix_M2(2,1) = 1;
adjacency_matrix_M2(3,1) = 1;

H3 = zeros(3,3,2);
H3(:,:,1) = adjacency_matrix_M1;
H3(:,:,2) = adjacency_matrix_M2;


fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('It is possible to introduce a custom graph in the method in matrix form')
disp('or described as a structure.  See jsr_pathcomplete for more information.')
disp('Let us introduce a graph in matrix form.')
disp(' ')
disp('For example, we can build the graph H_3 from [1].')
disp(' ')
disp('WARNING : This method only returns a valid upper bound if the graph provided')
disp('is path-complete! The method DOES NOT verify the path-completeness of the ')
disp('graph because it is a computationally prohibitive problem.')
disp(' ')
disp('Press any key to continue ...')
disp('------------------------------------ ')
pause
iMsg=iMsg+1;

fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('The graph H_3 (which is path-complete) is described below. Each (:,:,k)-subtensor')
disp('represents the adjacency matrix corresponding to the label k.')
disp(' ')
disp('              1   1   0                     0   0   1')
disp('H3(:,:,1) =   0   0   0   ;   H3(:,:,2) =   1   0   0')
disp('              0   0   1                     1   0   0')
disp(' ')
disp('Now, we can call ')
disp(' ')
disp('>> [Ub_customGraph] = jsr_pathcomplete(M,H3) ')
disp(' ')
disp('Press any key to continue ...')
disp('------------------------------------ ')
pause
iMsg=iMsg+1;
options = jsrsettings('pathcomplete.abstol',1e-8);
Ub_customGraph = jsr_pathcomplete(M,H3,options);

disp('Press any key to continue...')
disp('------------------------------------ ')
disp(' ')
pause

realJSR = 3.917384715148;
fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('We can compare all results : ')
disp(' ')
disp('de bruijn of dimension 1 : 3.9223562')
disp('de bruijn of dimension 2 : 3.9173847')
disp('Graph H3                 : 3.9173847')
disp('Real value of the JSR    : 3.9173847')
disp(' ')
disp('Note that the graph H_3 is a smaller graph than the')
disp('de Bruijn graph of degree 2, and hence the method works faster. ')
disp('Nevertheless, it provides the same upper bound.')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
disp(' ')
pause
iMsg=iMsg+1;






fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('To find an upper bound for the JSR, jsr_pathcomplete solves a')
disp('quasi-convex problem using an (improved) bisection algorithm that we can customize.')
disp(' ')
disp('First, we can change the tolerance with jsrsettings (see example below).')
disp(' ')
disp('>> options = jsrsettings(options,''pathcomplete.reltol'',1e-3,''pathcomplete.abstol'',1e-4);')
disp(' ')
disp('With these options, the algorithm stops when the current upper bound is')
disp('the best possible up to an error of at most tol = min{Ub*1e-3 ; 1e-4}.')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
disp(' ')
pause
iMsg=iMsg+1;



fprintf('\n\n%g / %g \n',iMsg,totMsg)

disp(' ')
disp('For heavy computations, it is possible (and recommended) to save the')
disp('intermediate results after each iteration.')
disp(' ')
disp('First, here is the command where jsr_pathcomplete is called and voluntarily')
disp('interrupted after three iterations.')
disp(' ')
disp('>> options = jsrsettings(options,''pathcomplete.maxiter'',3,''saveinIt'',''save_it_demo3'');')
disp('>> pathcomplete(M,options)')
disp(' ')
disp('Press any key to launch this call...')
disp('------------------------------------ ')
disp(' ')
pause
iMsg=iMsg+1;

clear options;
options = jsrsettings('pathcomplete.maxiter',3,'saveinIt','save_it_demo3');
jsr_pathcomplete(M,options);

disp(' ')
disp('The program is interrupted. Results of the last iteration are saved in')
disp('file ''save_it_demo3.mat''.')
disp(' ')
disp('Below, the command called to resume where the computation was interrupted.')
disp(' ')
disp('>> options = jsrsettings(''pathcomplete.loadIt'',1,...')
disp('              ''pathcomplete.loadItFile'',''save_it_demo3'');')
disp('>> pathcomplete(M,options)')
disp(' ')
disp('Press any key to launch this call...')
disp('------------------------------------ ')
disp(' ')
pause
 
clear options;
options = jsrsettings('pathcomplete.loadIt',1,'pathcomplete.loadItFile','save_it_demo3');
jsr_pathcomplete(M,options);


disp(' ')
disp(' ')
disp('References :')
disp(' ')
disp('   [1] A. Ahmadi, R. Jungers, P. Parrilo and M. Roozbehani,')
disp('   "Joint spectral radius and path-complete graph Lyapunov functions."')
disp('   SIAM J. CONTROL OPTIM 52(1), 687-717, 2014.')
disp(' ')
disp('   [2]  J. W. Lee, G. Dullerud, Uniform stabilization of discrete-time')
disp('   switched and Markovian jump linear systems. Automatica, 42(2), 205-218, 2006.')
disp(' ')
disp('   [3]  P.-A. Bliman, G. Ferrari-Trecate')
disp('   Stability analysis of discrete-time switched systems through Lyapunov ')
disp('   functions with nonminimal state. Proceedings of IFAC Conf. on the ')
disp('   Analysis and Design of Hybrid Systems, 2003.')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
disp(' ')
pause


disp(' ')
disp('#################################### ')
disp(' ')
disp('This is the end of demo3_JSR.')
disp(' ')
disp('For more information, see help jsr_pathcomplete for the basic help or')
disp('see help jsr_pathcomplete>fullHelp for an extended help.')
disp(' ')
disp('#################################### ')
disp(' ')
