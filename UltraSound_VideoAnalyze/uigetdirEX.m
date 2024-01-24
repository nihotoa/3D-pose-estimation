%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
almost same as 'uigetdir.m'
However, it returns an error message when cancel is pressed
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dir_path] = uigetdirEX(varargin)
switch nargin
    case 1
        common_path = varargin{1};
    case 0
        common_path = pwd;
end
[dir_path] = uigetdir(common_path);
if ~dir_path
    error('user press canceled')
end
end

