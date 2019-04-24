% DEMO1_JSR - Simple random tensor
%
% Shows how to change a tensor to a cell array, the general ways of calling
% the methods. The two ways of specifying parameters and a first look at
% the outputs.
%
%
clc
iMsg = 0;
totMsg = 17;

disp(' ')
disp(' ')
disp('--------------------- DEMO1 for JSR Toolbox ---------------------')
fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp('This demo shows how to change a tensor to a cell array, the general ')
disp('ways of calling the methods. The two ways of specifying parameters and ')
disp('a first look at the outputs.')
disp(' ')
disp('This demo uses quick methods to rapidly generate gross bounds.')
disp(' ')
disp(' ')
disp('If you want to stop the demo before the end type CTRL-C')
disp(' ')
disp(' ')
disp('Press any key to start...')
disp(' ')
disp(' ')
pause
iMsg=iMsg+1;

fprintf('\n\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Let us first generate a set of 4 3x3 random matrices with entries ')
disp('between -1 and 1:')
disp(' ')
disp('>> A = 2*(rand(3,3,4)-0.5)')
disp(' ')
disp('Press any key to launch this call...')
pause
iMsg=iMsg+1;
 
 A = 2*(rand(3,3,4)-0.5)
 
fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('A is a tensor and all the methods ask a cell')
disp('array of matrices as input. We have a routine to')
disp('make it a cell array, the function tens2cell:')
disp(' ')
disp('>> M = tens2cell(A)')
disp(' ')
disp('Press any key to launch this call...')
pause

M = tens2cell(A)

disp(' ')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg = iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('You can now access the ith matrix of M by typing M{i}.')
disp(' ')
disp('For instance:')
disp(' ')
disp('>> M{3}  yields:')
M{3}
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg=iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('As a first inspection, let us look at the max spectral radii of the')
disp('matrices in M. This constitutes a lower bound on the JSR of M.  This')
disp('can be done by using rho(M) and taking the max of the resulting ')
disp('vector: ')
disp(' ')
disp('>> rho1 = max(rho(M))')

rho1 = max(rho(M))
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg = iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('In order to choose a method, we can have an overlook')
disp('at the content of the Toolbox by typing help ')
disp('and the name of the folder containing the Toolbox')
disp(' ')
disp('For instance, if the name is right:')
s = which('demo1_JSR.m');
s2 = regexp(s,filesep,'split');
disp(' ')
msg(-1,1,'>> help %s',s2{end-1})
disp(' ')
disp('Should show a listing of all the methods. ')
disp(' ')
disp(' ')
disp('Press any key to launch this call...')
disp('------------------------------------ ')
pause

try 
    help (s2{end-1})
catch
disp('...Apparently the demo could not find the right folder name...')    
end
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg=iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Let us now try the brute force method on this set.')
disp(' ')
disp('This method computes recursively all the products of matrices ')
disp('in M up to length maxdepth, the default value of maxdepth is 4. From those')
disp('it deduces a lower bound on the JSR by taking the averaged spectral ')
disp('radius and an upper bound by taking the averaged maximal norm.')
disp(' ')
disp('The matrix norm used is by default the spectral norm')
disp('and can be changed with the parameter normfun.')
disp(' ')
disp('Let us call the function with the default parameters:')
disp(' ')
disp('>> bounds = jsr_prod_bruteForce(M)')
disp(' ')
disp('Press any key to launch this call...')
pause

bounds = jsr_prod_bruteForce(M)

disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg = iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Of course better bounds could have been obtained if the parameter')
disp('maxdepth had been set to a higher value.')
disp(' ')
disp('As you see, bounds is a vector with [lower upper], ')
disp('this is the general first output of all the methods.')
disp('With the exception of jsr_prod_lowerBruteForce')
disp('that computes only a lower bound. ')
disp(' ')
disp(' ')
disp('Each method but two (jsr_norm_balancedRealPolytope and ')
disp('jsr_norm_balancedComplexPolytope) can be called with only')
disp('the cell array of matrices as input argument. ')
disp(' ')
disp('All the parameters are then set to the default values described in the')
disp('help of each function.')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg = iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('We now try jsr_lift_semidefinite.')
disp(' ')
disp('This method computes successive semidefinite liftings of the matrices  ')
disp('in M and deduces bounds from the spectral radius of the sum of these ')
disp('powers.')
disp(' ')
disp('The number of lifts and hence the highest semidefinite lifting to which ')
disp('it tries to go is specified by the parameter maxdepth.')
disp('The default value of this parameter is 6.')
disp(' ')
disp('We call it on M without any parameter but this time we also retrieve ')
disp('the output structure info:')
disp(' ')
disp('>> [bounds2, info] = jsr_lift_semidefinite(M)')
disp(' ')
disp('Press any key to launch this call...')
disp(' ')
pause

[bounds2, info] = jsr_lift_semidefinite(M)

disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
disp(' ')
pause
iMsg=iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Because of the semidefinite liftings this method might')
disp('crash before reaching maxdepth. In which case it prints:')
disp(' ')
disp(' ''Aborting at depth i...'' ')
disp(' ')
disp(' ')
disp('but still gives an output with the best attained bounds.')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg=iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('In case it has not crashed with the default value maxdepth = 6,')
disp('let us change it to 20 by executing: ')
disp(' ')
disp('>> [bounds2, info] = jsr_lift_semidefinite(M,20)')
disp(' ')
disp('Press any key to launch this call...')
pause

[bounds2, info] = jsr_lift_semidefinite(M,20)

disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
disp(' ')
pause
iMsg = iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Now if the method has not aborted before depth 20 your computer')
disp('is not a normal one.')
disp(' ')
disp(' ')
disp('The fact that the method has aborted before normal termination is')
disp('signaled in the field status of the structure info.')
disp(' ')
disp('We must have info.status = 1 which says that the method ')
disp('has aborted due to hardware or software limitations')
disp('(see help jsr_lift_semidefinite).')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg=iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('This was a first example on how to change a parameter.')
disp(' ')
disp('It only works for certain methods and parameters in a certain order.')
disp('You have to check the descriptions in the helps to know which')
disp('can be specified that way and in what order.')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg = iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Another way of changing an option or parameter for a method is to')
disp('feed it, as second input, a structure of options.')
disp(' ')
disp('The structure should be generated by jsrsettings.')
disp(' ')
disp('This allows more ease in the specification of particular parameters')
disp('and works in the same way for every method.')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg = iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('For instance, from the help in jsr_lift_semidefinite, you see that')
disp('there is a field in the structure options called:')
disp(' ')
disp(' options.semidef.maxdepth ')
disp(' ')
disp('Which contains the value of the parameter maxdepth for the function')
disp('jsr_lift_semidefinite.')
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg = iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('You can set its value to 3 the following way:')
disp(' ')
disp('>> options = jsrsettings(''semidef.maxdepth'',3)' )
disp(' ')
disp(' ')
disp('Press any key to launch this call...')
pause

options = jsrsettings('semidef.maxdepth',3)

disp('And the field referring to the semidefinite lifting method, options.semidef reads:')
disp(options.semidef)

disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg = iMsg+1;


fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Now calling jsr_lift_semidefinite with this particular structure')
disp('of options will use maxdepth = 3 and the default values for')
disp('the other parameters:')
disp(' ')
disp('>> [bounds2, info2] = jsr_lift_semidefinite(M,options) ')
disp(' ')
disp(' ')
disp('Press any key to launch this call...')
pause

[bounds2, info2] = jsr_lift_semidefinite(M,options)
disp(' ')
disp('Press any key to continue...')
disp('------------------------------------ ')
pause
iMsg=iMsg+1;

fprintf('\n%g / %g \n',iMsg,totMsg)
disp(' ')
disp('Hopefully it has not aborted this time so the field info2.status ')
disp('has value 0, meaning that termination was normal.')
disp(' ')
disp(' ')
disp('This is the end of this demo, all the variables and outputs')
disp('defined are on the workspace.')
disp(' ')






