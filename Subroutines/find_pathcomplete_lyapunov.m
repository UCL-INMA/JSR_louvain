function [Ub, P, gammaMax, info] = find_pathcomplete_lyapunov(M,A,Agamma,b,c,K,graph,options)
%
%  FIND_PATHCOMPLETE_LYAPUNOV   If the graph is path-complete, then the method
%                               computes an UB for the JSR of M.
%
%   [UB, P] = FIND_PATHCOMPLETE_LYAPUNOV(M,A,Agamma,b,c,K,graph)
%       The function computes an upperbound UB for the JSR for a given
%       graph. M must be a cell array of matrices.
%       The variables A, Agamma, b, c and K must describe the
%       following problem (by denoting E the set of edges) :
%             max_P 0
%       s.t.    gamma^2( M_k' P_j M_k ) - P_i <=0 forall i,j,k in E (SPD sense)
%               P_i                           > 0 forall nodes i    (PD sense)
%       These input can be generated by the method GENERATE_PATHCOMPLETE_SDP
%       for a given graph. The structure graph must follows specifications
%       described in jsr_pathcomplete (see also tens2graph).
%
%       P is a cell array which contains last feasible matrices P_i for the 
%       above problem.
%
%       By default, the solver used to solve the SDP is SeDuMi, but it is
%       possible to use another one. See SOLVE_SEMI_DEFINITE_PROGRAM for 
%       more information.
%       All options can be given to the solver with
%       options.SDPsolver.solverOptions, excepted for the tolerance.
%
%       The last input gammaMax is equal to 1/UB.
%
%       The output info is a structure which contains following fields:
%
%           info.stopFlag   = 0 if the algorithm converge without any
%                               numerical problem
%                           = 1 if Ub is found with the required tolerance
%                               but not P
%                           = 2 if there is a complete numerical failure
%                               (the solver is not able to solve the SDP
%                               problem properly)
%                           = 3 if the number of iterations is greater than
%                               maxiter value (see options below)
%                           = 4 if maxTime is reached (see options below)
%                           = 5 If the method stops for an unknown reason
%                           =-1 if the given or computed UB is not
%                               feasible. In this case, this UB will be
%                               returned but P will be empty
%
%           info.elapsedtime    Total elapsed time
%
%           info.bisec         [lower upper] last bisection interval
%
%           info.niter          Number of iterations (bisection)
%
%           info.iterTime       Vector containing the elapsed
%                               time of each iteration
%
%           info.opts           The structure of options used
%
%           info.iterGamma      Value of gamma tested at each
%                               iterations (see [1])
%
%           info.iterFeas       Binary vector. The kth entry is true
%                               when info.iterGamma(k) is feasible
%
%           info.primalVar      Primal variables of the last feasible SDP
%
%           info.dualVar        Dual variables of the last feasible SDP
%
%           info.iterObj        Vector with all values of the objective 
%                               function at each iteration
%
%
%   [ ... ] = FIND_PATHCOMPLETE_LYAPUNOV(M,A,Agamma,b,c,K,graph,options)
%       Does the same as above but with specified parameters described in
%       fields of the structure "options.pathcomplete". See JSRSETTINGS and
%       below for available parameters and options.
%
%       pathcomplete.LbBisec   - Real positive number.
%                                 Gives starting LB for bisection method.
%                                 If not specified, takes the biggest
%                                 spectral radius of each matrices.
%       pathcomplete.UbBisec   - Real positive number.
%                                 Gives starting UB for bisection method.
%                                 If not specified, takes the biggest
%                                 norm 2 of each matrices.
%       pathcomplete.maxiter    - Positive integer.
%                                 Maximum number of iterations (for
%                                 bisection), (inf).
%       pathcomplete.reltol     - Real positive number.
%                                 Maximum relative length for bisection interval. 
%                                 Stopping criterion is
%                                 UbBisec-LbBisec < options.pathcomplete.reltol*UbBisec
%                                 Default : 1e-6.
%       pathcomplete.abstol     - Real positive number.
%                                 Maximum absolute length for bisection interval. 
%                                 Stopping criterion is
%                                 UbBisec-LbBisec < options.pathcomplete.abstol
%                                 Default : +inf.
%   Warning : the algorithm stops when the length of the bisection
%   interval is smaller than the tolerance. It does NOT mean that
%   (Ub - realJSR) < tol !
%
%       pathcomplete.testUb     - Binary value.
%                                 If testUb =1, then the method checks if
%                                 the upper bound for the JSR is feasible.
%                                 By default, testUb =1. 
%       pathcomplete.testLb     - Binary value.
%                                 If testLb =1, then the method checks if
%                                 the lower bound for the JSR is infeasible.
%                                 By default, testLb =1. 
%       pathcomplete.loadIt     - Binary value.
%                                 If loadIt =1, then the  method loads the
%                                 file with name [pathcomplete.loadItFile]
%                                 and resumes from the last finished 
%                                 iteration.
%                                 See options 'saveinIt' in jsrsettings to
%                                 know how to save data after each iterations.
%                                 By default, loadIt = 0. 
%       pathcomplete.loadItFile - String.
%                                 By default, loadItFile = 'saveinIt.mat'
%                                 See pathcomplete.loadIt.
%
% REFERENCES
%   [1] Ahmadi, Jungers, Parrilo and Roozbehani,
%   "Joint spectral radius and path-complete graph Lyapunov functions"
%   Vol. 52, No1, pp. 687-717 in SIAM J. CONTROL OPTIM, 2014.
%
% See also SOLVE_SEMI_DEFINITE_PROGRAM, TENS2GRAPH.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           PRE PROCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close =1;

% logfile opening
if (ischar(options.logfile) )    
    logFile = fopen(options.logfile,'wt');
    if (logFile == -1)
        warning(sprintf('Could not open file %s',options.logfile));
    end
elseif isnumeric(options.logfile)
    if (options.logfile==0)
        logFile = -1;
    elseif options.logfile==1
        logFile = fopen('log_pathcomplete','wt');
        if (logFile == -1)
            warning('Could not open logfile')
        end
    else
        logFile = options.logfile;
        close =0;
    end
else
    logFile = fopen('log_pathcomplete','wt');
    if (logFile == -1)
        warning('Could not open logfile')
    end
end
msg(logFile,options.verbose>1,'\n ********* Starting find_pathcomplete_lyapunov ******** \n');

if(nargin < 7)
    error('Not enought arguments.');
end

if(nargin < 8) % Default settings
    options = jsrsettings;
end

sizeMatrix = size(M{1},1);

maxiter = options.pathcomplete.maxiter;
maxTime = options.maxTime;

if(maxiter < 1)
    error('Parameter options.pathcomplete.maxiter must be positive.');
end

if(maxTime < 0)
    error('Parameter options.pathcomplete.maxTime must be non-negative.');
end

% Check bounds
Ub = options.pathcomplete.UbBisec;
if( isempty(Ub))
    Ub = getUpperBound(M);
elseif (not(isnumeric(Ub)) || Ub == inf || Ub <= 0)
    error('Ub must be a numeric and finite positive value.');
end

Lb = options.pathcomplete.LbBisec;
if (isnumeric(Lb) && not(isempty(Lb)) && Lb > 0 )
    Lb = max(options.pathcomplete.LbBisec,0);
else
    Lb = getLowerBound(M);
end

if(Ub < Lb)
    error('Ub must be greater than Lb !');
end

if(options.pathcomplete.testUb ~= 0 && options.pathcomplete.testUb ~= 1)
    error('Field options.pathcomplete.testUb must be equal to 0 or 1.')
end
if(options.pathcomplete.testLb ~= 0 && options.pathcomplete.testLb ~= 1)
    error('Field options.pathcomplete.testLb must be equal to 0 or 1.')
end

if(not(options.pathcomplete.loadIt)) % If we do not load a file, then we initialize everything
    info.niter = 0;

    info.iterTime = [] ;
    info.elapsedtime = 0;

    info.stopFlag = 5;

    info.iterGamma = [];
    info.iterFeas = [];
    info.iterObj = [];

    feas = 0;


    gammaMax = 0;
    P = [];


    Ub = min(Ub,getUpperBound(M));
    Lb = max(Lb,getLowerBound(M));
else % If we have to load the file, then we recover old variables.
    load(options.pathcomplete.loadItFile,'Ub','bisecInterval','gammaMax','P','info');
    if(not(isempty(info.iterFeas))) % When the first iteration was interupted.
        feas = info.iterFeas(end);
    else
        feas = 0;
    end
    Lb = bisecInterval(1);
    Ub = bisecInterval(2);
end

stopFlag = 2;

testingUb = 0;
testingLb = 0;

UbChecked = 0;
LbChecked = 0;

tol = min(options.pathcomplete.abstol, options.pathcomplete.reltol*Ub);
msg(logFile,options.verbose>0,['Algorithm will stop when possible improvement < ', num2str(tol) ]);
stop = 0;

if(tol <= 0)
    error('Tolerance must be positive. Check opts.pathcomplete.abstol and opts.pathcomplete.reltol');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           MAIN LOOP (bisection)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msg(logFile,options.verbose>1,'Begining bisection');

numericalFailureSDPSolver = 0;

if(Lb < eps)
    LbChecked = 1;
end

while( (Ub-Lb >= tol || ...                                         % We must reach the tol
        (UbChecked == 0 && options.pathcomplete.testUb == 1 ) || ...% We must check UB if needed
        (LbChecked == 0 && options.pathcomplete.testLb == 1 ) )...  % We must check LB if needed
        && not(stop) )                                              % Excepted if we must stop
    timeBeg = cputime;
    info.niter = info.niter+1;
    
    
    % Update gamma + constraint matrix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if(options.pathcomplete.testUb == 1 && not(UbChecked))
        msg(logFile,options.verbose>1,'Checking Ub.');
        gamma = 1/Ub;
        testingUb = 1;
    elseif(options.pathcomplete.testLb == 1 && not(LbChecked))
        msg(logFile,options.verbose>1,'Checking Lb.');
        gamma = 1/Lb;
        testingLb = 1;
    else
        gamma = getNewGamma(info,Lb,Ub,options);
    end
    ConstrainMatrix = A+(gamma^2-1)*Agamma;
    
    
    % Solve SDP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    msg(logFile,options.verbose>1,'Solving SDP.');
    [X,Y,trash,stopFlag,objectiveVal] = solve_semi_definite_program(ConstrainMatrix,b,c,K,tol,options);
    msg(logFile,options.verbose>1,'Done.');
    info.iterObj = [info.iterObj, objectiveVal];
    if(isempty(stopFlag))
        stopFlag = 0;
    end
    
    if(stopFlag == 2)
        msg(logFile,options.verbose>1,'Numerical failure while solving SDP.') 
    end
    
    % Check the feasability
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Xcell = convertSolutionToCell(Y,graph.nNodes,sizeMatrix);
    [BestPossibleUbWithP] = BoundJSRApproxGivenP(Xcell,M,graph);
    if(BestPossibleUbWithP <= 1/gamma && IsSolutionDefinitePositive(Xcell) )
        feas = 1;
    else
        feas = 0;
    end
    
    if feas
        P = Xcell;
        Ub = BestPossibleUbWithP;
        if(Ub < Lb)
            Ub = Lb;
        end
        info.primalVar = X ;
        info.dualVar = Y;
        msg(logFile,options.verbose>0,['It ', num2str(info.niter) , ';   feas.\t Best Ub : ' , num2str(Ub,'%.15f') , '. Further improvement <= ' , num2str(Ub-Lb)  , '.']);
    else
        Lb = 1/gamma;
        msg(logFile,options.verbose>0,['It ', num2str(info.niter) , '; infeas.\t Best Ub : ' , num2str(Ub,'%.15f') , '. Further improvement <= ' , num2str(Ub-Lb)  , '.']);
    end
    

    
    % Fill structure info
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    info.iterTime = [info.iterTime cputime-timeBeg];
    info.elapsedtime = info.elapsedtime + info.iterTime(end);
    info.iterFeas = [info.iterFeas,feas];
    info.iterGamma = [info.iterGamma,gamma];
    
    
    if(stopFlag == 0)
        info.stopFlag   = 0;
    elseif(stopFlag == 1)
        info.stopFlag   = 1;
    end
    
    
    
    % Check if we must stop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(maxiter < info.niter) % Too much iterations
        stop = 1;
        info.stopFlag = 3;
        msg(logFile,options.verbose>0,'Maximum iterations reached.');
    end
    
    if(maxTime < info.elapsedtime) % Too much time
        stop = 1;
        info.stopFlag = 4;
        msg(logFile,options.verbose>0,'Maximum time reached.');
    end
    
    
    % Check UB and LB if needed
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(testingUb == 1 && feas == 0 && stop == 0) % Ub infeasible
        msg(logFile,options.verbose>0,'Ub infeasible. Aborting');
        info.stopFlag = -1;
        stop = 1;
        P = [];
        testingUb = 0;
        UbChecked = 1;
    elseif (testingUb == 1) % All Ok
        msg(logFile,options.verbose>1,'Ub feasible. All OK.');
        UbChecked = 1;
        testingUb = 0;
    end
        
    if(testingLb == 1 && feas == 1 && stop == 0) % Lb feasible
        msg(logFile,options.verbose>0,'Lb feasible. Computing new Lb.');
        Ub = Lb;
        Lb = getLowerBound(M);
        LbChecked = 1;
        testingLb = 0;
        msg(logFile,options.verbose>0,'New Lb computed.');
    elseif(testingLb == 1)
        msg(logFile,options.verbose>1,'Lb infeasible. All OK.');
        LbChecked = 1;
        testingLb = 0;
    end
    

    
    
    % Save after the iteration if needed
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ischar(options.saveinIt)
        bisecInterval = [Lb,Ub];
        gammaMax = 1/Ub;
        save([options.saveinIt,'.mat'],'Ub','bisecInterval','gammaMax','P','info',...
            'M','A','Agamma','b','c','K','graph');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           POST PROCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gammaMax = 1/Ub;
info.bisec = [Lb Ub];

if(stop == 0)
    if(stopFlag == 0)
        info.stopFlag = 0;
    elseif (stopFlag == 1)
        info.stopFlag = 1;
    end
end

if numericalFailureSDPSolver
    info.stopFlag =2;
end

msg(logFile,options.verbose>0,['\nBest upper bound with this graph : ', num2str(Ub,'%.15f') , ', up to precision ' ,  num2str(Ub-Lb) , '.']);
msg(logFile,options.verbose>1,['\nMethod find_pathcomplete_lyapunov ended after ' , num2str(info.elapsedtime) , 'sec.']);

if (logFile~=-1 && close)
    fclose(logFile);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           INTERNAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Get bounds
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function ub = getUpperBound(M) % Max_k || M{k} ||_2
        vecnorm = zeros(length(M),1);
        for i=1:length(M)
            vecnorm(i) = norm(M{i});
        end
        ub = max(vecnorm);
    end

    function lb = getLowerBound(M) % Max_k rho( M{k} )
        lb = max(rho(M));
    end


    % Find better gamma
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % We compute the largest gamma (given matices P) such that 
    %
    %                 gamma^2 M_k' P_j M_k-P_i <= 0 (SDP)
    %
    % It can be shown that 
    %
    %       gamma^2 = max_{(i,j,k)} lambda_max( inv(P_i)*M_k'*P_j*M_k )
    %
    % where (i,j,k) is a edge presents in the path-complete graph.
    % 
    % We can deduce a better gamma than the tested gamma, because we solve
    % a feasibility problem and constraints are not always tight.

    function Up = BoundJSRApproxGivenP(P,M,graph)
        Up = -inf ;
        nEdges = size(graph.edges,1);
        for edge=1:nEdges
            i = graph.edges(edge,1);
            j = graph.edges(edge,2);
            k = graph.edges(edge,3);

            Mk = M{k};
            Pi = P{i};
            Pj = P{j};

            Matr = Mk'*Pj*Mk/Pi;
            val = sqrt(max(real(eig(Matr)))); % real : sometimes numerical errors

            if val > Up
                Up = val;
            end
        end
    end

    % Convert solution vector X to Pcell
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Pcell = convertSolutionToCell(DualVec,n_nodes,sizeMatrix)
        mapIdx = zeros(sizeMatrix);
        counter = 0;
        % We create the same map than get_standard_optimisation_form
        for i=1:sizeMatrix;
            counter = counter + 1;
            mapIdx(i,i) = counter;
            for j=(i+1):sizeMatrix;
                counter = counter + 1;
                mapIdx(i,j) = counter;
                mapIdx(j,i) = counter;
            end
        end


        nElemMatrix = sizeMatrix*(sizeMatrix+1)/2;
        Pvec = DualVec(1:n_nodes*nElemMatrix);
        n_P = n_nodes;
        Pcell = cell(n_P,1);

        for i=1:n_P
            Pcell{i} = zeros(sizeMatrix);
            for j=1:sizeMatrix
                for k=1:sizeMatrix
                    Pcell{i}(j,k) = Pvec(nElemMatrix*(i-1)+mapIdx(j,k));
                end
            end
            Pcell{i} = 0.5*Pcell{i} + 0.5*Pcell{i}'; % Symetric part.
        end
    end


    % Compute new gamma
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function out = IsSolutionDefinitePositive(x)
        out = 1;
        for i=1:length(x)
            if(min(eig(x{i})) <= 0)
                out = 0;
                return;
            end
        end
    end
    
    % Compute new gamma
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function out = getNewGamma(info,Lb,Ub,options) 
        % There is more inputs than needed because we can 
        % maybe do something better with more information.
        out = 2/(Lb+Ub); % bisection
    end

end
