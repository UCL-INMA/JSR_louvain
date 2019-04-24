function [bounds, info] = jsr_norm_linearRelaxation2D(M, varargin)

% JSR_NORM_LINEARRELAXATION2D Approximates the jsr using Linear-Relaxation in 2D.
%
%    [BOUNDS, INFO] = JSR_NORM_LINEARRELAXATION2D(M)
%      returns lower and upper bounds on the jsr of M using Linear-Relaxation
%      scheme (heuristically).
%      The set M must be a cell array containing the considered 2x2 matrices.
%      Uses default values of the parameters (see below).
%
%    [BOUNDS, INFO] = JSR_NORM_LINEARRELAXATION2D(M, STEP, LAMBDA)
%      Does the same but with specified parameters.
%      The parameter STEP corresponds to the discretization step of the
%      angular interval [-pi, +pi]. Default is 2*pi/10000.
%      The parameter LAMBDA corresponds to the convex combination coefficient.
%      It is supposed to be constant, between 0 and 1 here. Default is 0.42.
%  
%    [BOUNDS, INFO] = JSR_NORM_LINEARRELAXATION2D(M, OPTIONS)
%      Does the same but with the values of the parameters defined in
%      OPTIONS. See below and help JSRSETTINGS for the available
%      parameters. 
%
%      BOUNDS contains the lower and upper bounds on the JSR
%
%      INFO is a structure containing various data about the iterations :
%         info.status         - = 0 if normal termination, 1 if maxiter
%                               reached, 2 if stopped in iteration
%                               (CTRL-C or options.maxTime reached)                              
%         info.elapsedtime 
%         info.niter          - number of iterations
%         info.timeIter       - cputtime - start time in s. at the end of 
%                               each iteration. Note : diff(info.timeIter)                             
%                               gives the time taken by each iteration.
%         info.Phi            - Phi = -pi:step:pi
%         info.R              - Such that 
%                                R(i) = ||(cos Phi(i), sin Phi(i))||
%         info.allLb          - evolution of the lower bound  [1x(niter) double]
%         info.allUb          - evolution of the upper bound  [1x(niter) double]
%         info.opts           - the structure of options used
%
%
%  The field opts.linrel (generated by jsrsettings) can be used to
%  tune the method :
%
%      linrel.step           - discretization step of the angular interval
%                              [-pi, +pi]. (2*pi/10000)
%      linrel.lambda         - convex combination coefficient. It is supposed
%                              to be constant, between 0 and 1 here. (0.42)
%      linrel.maxiter        - maximum number of iterations, (1000)
%
%      linrel.tol            - tolerance for stopping condition, stops when
%                              upperBound-lowerBound < tol, (1e-10)
%
%      linrel.plotBounds     - if 1 plots the evolution of the bounds, (0)
%
%      linrel.plotEllips     - if 1 plots the unit ball, (0)
%
%      linrel.plotTime       - if 1 plots evolution of the bounds w.r.t.
%                              time of computation, (0)
%                                                           
%
% See also JSRSETTINGS
%
% REMARK : This method returns heuristic estimates based on [1]
%
% REFERENCES
% [1] V.Kozyakin, 
%       "A relaxation scheme for computation of the joint spectral
%        radius of matrix sets",
%       arXiv:0810.4230v2 [math.RA], 27 Jan. 2009


if (nargin > 1)
    if (length(varargin) > 1)
        opts = jsrsettings('linrel.step',varargin{1},'linrel.lambda',varargin{2});
    elseif isnumeric(varargin{1})
        opts = jsrsettings('linrel.step',varargin{1});
    else
        opts = varargin{1};
    end
else
    opts = jsrsettings;
end

% logfile opening
close =1;
if (ischar(opts.logfile) )    
    logFile = fopen(opts.logfile,'wt');
    if (logFile == -1)
        warning(sprintf('Could not open file %s',opts.logfile));
    end
elseif isnumeric(opts.logfile)
    if (opts.logfile==0)
        logFile = -1;
    elseif (opts.logfile==1)
        logFile = fopen('log_linearRelaxation2D','wt');
        if (logFile == -1)
            warning('Could not open logfile')
        end
    else
        logFile = opts.logfile;
        close =0;
    end
else
    logFile = fopen('log_linearRelaxation2D','wt');
    if (logFile == -1)
        warning('Could not open logfile')
    end
end

if (logFile~=-1)
    fprintf(logFile,[datestr(now) '\n\n']);
end

msg(logFile,opts.verbose>1,'\n \n******** Starting jsr_norm_linearRelaxation2D ******** \n \n')
starttime = cputime;

% Parameters
lambda = opts.linrel.lambda;
step = opts.linrel.step;
tol = opts.linrel.tol;
maxiter = opts.linrel.maxiter;
m = length(M);

% Initialization
status = 2;
lowerRho = zeros(1,maxiter);
upperRho = zeros(1,maxiter);
timeIter = zeros(1,maxiter);

% Discretization
n = 2*ceil(round(2*pi/step)/2);
Phi = linspace(-pi, pi, n+1);
R = ones(1, n+1);
keyZERO = n/2 + 1;

H = zeros(m, n+1);
PHI = zeros(m, n+1);
keyPhi = zeros(m, n+1);
msg(logFile,opts.verbose>1,'Starting to compute the images of the points');
for i = 1:m,
    H(i, :) = sqrt( (M{i}(1,1)*cos(Phi) + M{i}(1,2)*sin(Phi)).^2 + (M{i}(2,1)*cos(Phi) + M{i}(2,2)*sin(Phi)).^2 );
    PHI(i, :) = atan2(  M{i}(2,1)*cos(Phi) + M{i}(2,2)*sin(Phi), M{i}(1,1)*cos(Phi) + M{i}(1,2)*sin(Phi)  );
    keyPhi(i, :) = round((PHI(i, :) + pi)*n/(2*pi) + 1);
end

% Iteration
msg(logFile,opts.verbose>1,'Starting iteration \n');
for iter = 1:maxiter,
    Rall = H .* R(keyPhi);
    Rstar = max(Rall, [], 1);
    RHOup = max(Rstar./R);
    RHOdown = min(Rstar./R);
    invGamma = 1/max(Rstar(:, keyZERO));
    R = lambda * R + (1-lambda) * invGamma *  Rstar;
    
    
    if (iter>1000)
        if (mod(iter,100)==0)
    msg(logFile,opts.verbose>0,'> Iteration %3.0f - current bounds: [%.15g, %.15g] \n', iter, RHOdown, RHOup);
        end
    elseif (iter>150)
        if (mod(iter,50)==0)
    msg(logFile,opts.verbose>0,'> Iteration %3.0f - current bounds: [%.15g, %.15g] \n', iter, RHOdown, RHOup);
        end
    elseif (iter>20)
        if (mod(iter,10)==0)
    msg(logFile,opts.verbose>0,'> Iteration %3.0f - current bounds: [%.15g, %.15g] \n', iter, RHOdown, RHOup);
        end
    else
        msg(logFile,opts.verbose>0,'> Iteration %3.0f - current bounds: [%.15g, %.15g] \n', iter, RHOdown, RHOup);
    end

    
    lowerRho(iter) = RHOdown;
    upperRho(iter) = RHOup;   
    timeIter(iter) = cputime-starttime;
    
    % Save to file option
    if (ischar(opts.saveinIt))
        if (iter==maxiter);status=1;end
        bounds = [RHOdown, RHOup];
        elapsedtime = cputime - starttime;
        
        info.status = status;
        info.elapsedtime = elapsedtime;
        info.niter = iter;
        info.timeIter = timeIter(1:niter);
        info.Phi = Phi;
        info.R = R;
        info.allLb = lowerRho(1:iter);
        info.allUb = upperRho(1:iter);
        info.opts = opts;

        save([opts.saveinIt '.mat'],'bounds','info')
    end
    
    if (RHOup - RHOdown < tol),
        break;
    end
    
    if (timeIter(iter)>=opts.maxTime)
        msg(logFile,opts.verbose>0,'\nopts.maxTime reached\n');
        break;
    end
end

% Post-processing
if (iter==maxiter)
    status = 1;
elseif (timeIter(iter)>=opts.maxTime)
    status = 2;
else
    status = 0;
end

msg(logFile,opts.verbose>0,'\n> Bounds on the jsr: [%.15g, %.15g]', RHOdown, RHOup);
bounds = [RHOdown, RHOup];
elapsedtime = cputime - starttime;

msg(logFile,opts.verbose>1,'\n End of algorithm after %5.2f s',elapsedtime)

if (logFile~=-1 && close)
    fclose(logFile);
end

info.status = status;
info.elapsedtime = elapsedtime;
info.niter = iter;
info.timeIter = timeIter(1:iter);
info.Phi = Phi;
info.R = R;
info.allLb = lowerRho(1:iter);
info.allUb = upperRho(1:iter);
info.opts = opts;

% Save output option
if (ischar(opts.saveEnd))
   save([opts.saveEnd '.mat'],'bounds','info')
end

% Figures
if(opts.linrel.plotBounds)
    figure
    it = 1:iter;
    plot(it,info.allUb,'-*r',it,info.allLb,'-g+')
    title('linrel : Evolution of the bounds on the JSR')
    legend('Upper bound','Lower bound')
    xlabel('Iterations')
end

if(opts.linrel.plotEllips)
    figure
    axis equal;
    axis([-rngAxis, rngAxis, -rngAxis, rngAxis]);
    hbar = plot(cos(Phi)./R, sin(Phi)./R, 'k-', 'Linewidth', 1.5);
    legend(hbar, '||x||=1');
    title('Representation of the unit ball')
end

if (opts.linrel.plotTime)
    figure
    if (info.timeIter(end) > 600)
        time = info.timeIter/60;
        plot(time,info.allLb,'-+g',time,info.allUb,'-*r','MarkerSize',10);
        xlabel('time from start in min')
    else
        plot(info.timeIter,info.allLb,'-+g',info.timeIter,info.allUb,'-*r','MarkerSize',10)
        xlabel('time from start in s')
    end
    title('linRel2D : Evolution of the bounds w.r.t. time')
    legend('Lower bound','Upper bound')   
end

end