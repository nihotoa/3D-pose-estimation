%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
almost same as 'uigetfile.m'
However, it returns an error message when cancel is pressed
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [file_name, file_path] = uigetfileEX(varargin)
switch nargin
    case 1
        common_path = varargin{1};
    case 0
        common_path = pwd;
end
[file_name, file_path] = uigetfile(common_path);
if ~file_name
    error('user press canceled')
end
end

