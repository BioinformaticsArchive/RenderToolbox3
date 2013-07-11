%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
% Collect revision information about RenderToolbox3 and dependencies.
%
% @details
% Gets revision and data information about RenderTooblox3 and its
% dependencies, including Psychtoolbox, the David Brainard lab toolbox,
% Matlab, the computer, PBRT, and Mitsuba.
%
% @details
% Returns a struct that contains information collected about each
% component.
function info = GetRenderToolbox3VersionInfo()

% Git info about RenderToolbox3
try
    info.RenderToolbox3GitInfo = GetGitInfo(RenderToolboxRoot());
catch err
    info.RenderToolbox3GitInfo = err;
end

% SVN info about Psychtoolbox
try
    info.PsychtoolboxSVNInfo = GetSVNInfo(PsychtoolboxRoot());
catch err
    info.PsychtoolboxSVNInfo = err;
end

% SVN info about Brainard Lab common toolbox
try
    toolboxPath = fileparts(which('GetSVNInfo'));
    info.BrainardLabToolboxSVNInfo = GetSVNInfo(toolboxPath);
catch err
    info.BrainardLabToolboxSVNInfo = err;
end

% Matlab version
try
    info.MatlabVersion = version();
catch err
    info.MatlabVersion = err;
end

% Matlab tooblox versions
try
    info.MatlabToolboxVersions = ver();
catch err
    info.MatlabToolboxVersions = err;
end

% Text that includes OS version
try
    info.OSVersion = evalc('ver');
catch err
    info.OSVersion = err;
end

% RenderToolbox3 preferences
try
    info.PBRTPreferences = getpref('RenderToolbox3');
    info.PBRTPreferences = getpref('PBRT');
    info.MitsubaPreferences = getpref('Mitsuba');
catch err
    info.PBRTPreferences = err;
    info.PBRTPreferences = err;
    info.MitsubaPreferences = err;
end

% PBRT executable date stamp
try
    info.PBRTDirInfo = dir(getpref('PBRT', 'executable'));
catch err
    info.PBRTDirInfo = err;
end

% Mitsuba executable date stamp
try
    mitsuba = fullfile( ...
        getpref('Mitsuba', 'app'), ...
        getpref('Mitsuba', 'executable'));
    info.MitsubaDirInfo = dir(mitsuba);
catch err
    info.MitsubaDirInfo = err;
end
