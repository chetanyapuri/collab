function [params, names] = rbfadditionalKernExtractParam(kern)

% RBFADDITIONALKERNEXTRACTPARAM Extract parameters from the RBF with side
% information kernel structure.
% FORMAT
% DESC Extract parameters from the radial basis function with side
% information kernel structure into a vector of parameters for optimisation.
% ARG kern : the kernel structure containing the parameters to be
% extracted.
% RETURN param : vector of parameters extracted from the kernel. If
% the field 'transforms' is not empty in the kernel matrix, the
% parameters will be transformed before optimisation (for example
% positive only parameters could be logged before being returned).
%
% FORMAT
% DESC Extract parameters and parameter names from the radial basis
% function with side information kernel structure.
% ARG kern : the kernel structure containing the parameters to be
% extracted.
% RETURN param : vector of parameters extracted from the kernel. If
% the field 'transforms' is not empty in the kernel matrix, the
% parameters will be transformed before optimisation (for example
% positive only parameters could be logged before being returned).
% RETURN names : cell array of strings giving names to the parameters.
%
% SEEALSO rbfadditionalKernParamInit, rbfadditionalKernExpandParam, kernExtractParam, scg, conjgrad
%
% COPYRIGHT : Neil D. Lawrence, 2004, 2005, 2006
%
% COPYRIGHT : Raquel Urtasun, 2009

% COLLAB
  
params = [kern.inverseWidth kern.variance];
if nargout > 1
  names={'inverse width', 'variance'};
end
