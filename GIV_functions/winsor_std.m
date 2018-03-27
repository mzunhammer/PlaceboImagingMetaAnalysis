function[y,varargout] = winsor_std(x,std)
% WINSOR     Winsorize a vector 
% INPUTS   : x - n*1 data vector
%            std - 1*1 vector denoting the standard-deviation cutoff
% OUTPUTS  : y - winsorized x, n*1 vector
%            i - (optional) n*1 value-replaced-indicator vector

% EXAMPLE  : x = rand(10,1), y = winsor(x,3)
% AUTHOR   : Dimitri Shvorob, dimitri.shvorob@vanderbilt.edu, 4/15/07
% Adapted for std by Matthias Zunhammer matthias.zunhammer@uk-essen.de 26.03.2018
if ~isvector(x)
   error('Input argument "x" must be a vector')
end  
if nargin < 2
   error('Input argument "std" is undefined')
end 
if ~isvector(std)
   error('Input argument "std" must be a vector')
end  
if length(std) ~= 1
   error('Input argument "std" must be a 1*1 vector')
end 

z = zscore(x);
i1 = z < std*-1; v1 = min(x(~i1));
i2 = z > std; v2 = max(x(~i2));
y = x;
y(i1) = v1;
y(i2) = v2;
if nargout > 1
   varargout(1) = {i1 | i2};
end   