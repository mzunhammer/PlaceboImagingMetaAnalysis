function [K,Likelihoodtheory,Likelihoodnull]= bayesfactor(effect,se,uniform,varargin)

% Function for calculating the Bayes factor for uniform, half-normal or normal priors
% accordding to Dienes (2014) Frontiers in Psychology, Vol 5, July, p1-17.;
% adapted  by Matthias Zunhammer (February 2017).
%
% Required arguments:
% ? effect
%   The observed effect size, or mean, whereas positive values indicate effects in the
%   direction supporting H1 and negative values indicate effects in the
%   opposite direction.
% ? se
%   Observed standard error of the effect size. Can be calculated
%   as "effect/t" if only the t-value and the effect size are available
% - 'uniform'
%   Choose 'uniform' for a uniform distribution under H0, i.e. when all values in a certain range (between an upper and an lower bound) are
%   equally plausible. In addition to the 'uniform' argument, enter the lower and upper bound of uniformly distributed H0 as a two-element vector, e.g.:
%   'uniform', [0,1] ... for a H0 where all effects between 0 and 1 are equally plausible.
% - 'normal'
%   Choose 'normal' when values near a certain value (often the population mean) are more likely than values far from that value.
%   In addition to the 'normal' argument, enter the  population mean, SE
%   and number of tails for the normal HO as a three-element vector.
%   Example 1: [0,1,1] for a H0 where there is no population mean effect, an SD of 1 and
%   effects are only expected in one direction.
%   Example 2: [1,0.5,2] for a H0 where there is a population mean effect of 1 is expected, with a SD of 0.5 and
%   both positive or negative effects.
% Optional arguments:
% 'verbose' 1, 0
% For more information see:
% http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/inference/Bayesfactor.html

%%


isbool = @(x) x==1||x==0||islogical(x);
%Check effect 
if ~isnumeric(effect)
    disp('"effect" not entered; "effect" must be numeric')
    return
end
if ~isnumeric(se)
    disp('"se" not entered; "se" must be numeric')
    return
end
if se==0
    disp('"se" equals 0, indicating that the data does not vary. No calculation possible.')
    return
end
if ~isbool(uniform)
    disp('"uniform" not entered; "uniform" must be boolean (0,1,false, or true)')
    return
end

if uniform
   bounds=varargin{1};
   if numel(bounds)~=2
       disp('normal prior desired, but bounds not entered correctly. bounds must be a two-element vector of the form [lower,upper].')
       return
   end 
else
   popnorm=varargin{1};
   if numel(popnorm)~=3
       disp('normal prior desired, but popnorm not entered correctly. popnorm must be a three element vector of the form [mean,se,tails].')
       return
   end    
end

verbose=1;
if any(strcmp(varargin,'verbose'))
    iverbose=find(strcmp(varargin,'verbose'));
    verbose=varargin{iverbose+1};
end

normaly = @(mn, variance, x) 2.718283^(- (x - mn)*(x - mn)/(2*variance))/realsqrt(2*pi*variance);
 
      sd = se;
      sd2 = sd*sd;
      obtained = effect;
     
     if ~uniform
          meanoftheory = popnorm(1);
          sdtheory = popnorm(2);
          omega = sdtheory*sdtheory;   
          tail = popnorm(3);
     end
    
     if uniform
          lower = bounds(1);
          upper = bounds(2);
     end
    
     area = 0;
     if uniform
         theta = lower;
     else
         theta = meanoftheory - 5*(omega)^0.5;
     end
     if uniform
          incr = (upper- lower)/2000;
     else
          incr =  (omega)^0.5/200;
     end
        
     for A = -1000:1000
          theta = theta + incr;
          if uniform
              dist_theta = 0;
              if and(theta >= lower, theta <= upper)
                  dist_theta = 1/(upper-lower);
              end              
          else %distribution is normal
              if tail == 2
                  dist_theta = normaly(meanoftheory, omega, theta);
              else
                  dist_theta = 0;
                  if theta > 0
                      dist_theta = 2*normaly(meanoftheory, omega, theta);
                  end
              end
          end
         
          height = dist_theta * normaly(theta, sd2, obtained); %p(population value=theta|theory)*p(data|theta)
          area = area + height*incr; %integrating the above over theta
     end
    
    
     Likelihoodtheory = area;
     Likelihoodnull = normaly(0, sd2, obtained);
     K = Likelihoodtheory/Likelihoodnull;

if verbose==1     
    fprintf('\n\nThe likelihood of the obtained data given the theory (H1) is: %5.3f.\n',Likelihoodtheory);
    fprintf('The likelihood of the obtained data given the null hypothesis (H0) is: %5.3f.\n',Likelihoodnull);
    fprintf('The Bayes factor is: %5.3g.\n',K);

    % Provide interpretation according to:
    % Jarosz & Wiley 2014, The Journal of Problem  Solving 7,1,pp.2-9
    if K>=1
    fprintf('This Bayes factor indicates that the data are %5.3g-times more likely under the H1 than under the H0.\n',K);
        if K<3
            disp('A Bayes factor of this size is considered weak/anecdotal support for H1.\n');
        elseif K>=3&&K<10
            disp('A Bayes factor of this size is considered positive/substantial support for H1.\n');
        elseif K>=10&&K<20
            disp('A Bayes factor of this size is considered positive/strong support for H1.\n');
        elseif K>=20&&K<30
            disp('A Bayes factor of this size is considered strong support for H1.\n');
        elseif K>=30&&K<100
            disp('A Bayes factor of this size is considered strong to very strong support for H1.\n');
        elseif K>=100&&K<150
            disp('A Bayes factor of this size is considered strong to decisive support for H1.\n');
        elseif K>150
            disp('A Bayes factor of this size is considered very strong to decisive support for H1.\n');
        end
    elseif K<1
    fprintf('This Bayes factor indicates that the data are %5.3f-times more likely under the H0 than under the H1.\n',1/K);
        if K>1/3
            disp('A Bayes factor of this size is considered weak/anecdotal support for H0.\n');
        elseif K<=1/3&&K>0.1
            disp('A Bayes factor of this size is considered positive/substantial support for H0.\n');
        elseif K<=0.1&&K>0.05
            disp('A Bayes factor of this size is considered positive/strong support for H0.\n');
        elseif K<=0.05&&K>0.03
            disp('A Bayes factor of this size is considered strong support for H0.\n');
        elseif K<=0.03&&K>0.01
            disp('A Bayes factor of this size is considered strong to very strong support for H0.\n');
        elseif K<=0.01&&K>0.0067
            disp('A Bayes factor of this size is considered strong to decisive support for H0.\n');
        elseif K<0.0067
            disp('A Bayes factor of this size is considered very strong to decisive support for H0.\n');
        end
    end
end
end