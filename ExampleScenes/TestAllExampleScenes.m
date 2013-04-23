%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Run all "Make*" functions in the ExampleScenes/ folder.
%   @param outputRoot base path where to save output data
%   @param outputName trailing path where to save output data
%   @param makeFunctions cell array of "Make" functions for example scenes
%   @param isDryRun whether to skip rendering as a "dry run"
%
% @details
% Finds all m-files named "Make* in the RenderToolbox3 ExampleScenes/
% folder, and executes each one.  Attempts to trap and save any errors that
% occur.
%
% @details
% @a outputRoot is the base path under which all output data should be
% saved.  If outputRoot is missing or empty, uses default folders from
% getpref('RenderToolbox3').  Outputs will be saved in subfolders of @a
% outputRoot, one for each subfolder of ExampleScenes/.
%
% @details
% If @a outputName is provided, it should be the name of a folder to append
% to each subfolder of @a outputRoot.  This allows multiple test runs to be
% saved under the same @a outputRoot.
%
% @details
% By default, renders example scenes by invoking all of the "Make*" scripts
% found within the ExampleScenes/ folder.  If @a makeFunctions is provided,
% it must be a cell array of scripts to invoke instead.
%
% @details
% If @a isDryRun is provided and true, no rendering will happen, but
% "Make*" files will still be executed.
%
% @details
% Returns a struct with information about each "Make*" file, whether the
% file executed successfully, and any Matlab error struct that was trapped.
%
% @details
% Saves a .mat file with several variables about the test parameters and
% results:
%   - outputRoot, the given @a outputRoot
%   - outputName, the given @a outputName
%   - makeFunctions, the given @a makeFunctions
%   - isDryRun, the given @a isDryRun
%   - hints, RenderToolbox3 options, as returned from GetDefaultHints()
%   - results, the returned struct of results about each "Make*" file
% .
% @details
% The .mat file will be saved in the given @a outputRoot folder.  It will
% have a name that that includes the name of this m-file, plus the given @a
% outputName, if any, plus the date and time.  For example,
%
% @details
% Usage:
%   results = TestAllExampleScenes(outputRoot, outputName, makeFunctions, isDryRun)
%
% @ingroup ExampleScenes
function results = TestAllExampleScenes(outputRoot, outputName, makeFunctions, isDryRun)

if nargin < 1  || isempty(outputRoot)
    outputRoot = '';
end

if nargin < 2 || isempty(outputName)
    outputName = '';
end

if nargin < 3 || isempty(makeFunctions)
    % find all the m-functions named "Make*", in ExampleScenes/
    exampleRoot = fullfile(RenderToolboxRoot(), 'ExampleScenes');
    makeFunctions = FindFiles(exampleRoot, 'Make\w+\.m');
end

if nargin < 4 || isempty(isDryRun)
    isDryRun = getpref('RenderToolbox3', 'isDryRun');
end

testTic = tic();

% allocate a struct for test results
results = struct( ...
    'makeFile', makeFunctions, ...
    'isSuccess', false, ...
    'error', [], ...
    'elapsed', []);

% remember original folder and preferences
%   which might change during testing
originalFolder = pwd();
originalPrefs = getpref('RenderToolbox3');

% dry runs or real rendering?
setpref('RenderToolbox3', 'isDryRun', isDryRun);

% try to render each example scene
for ii = 1:numel(makeFunctions)
    
    % choose where to put outputs for this scene
    [makePath, makeName, makeExt] = fileparts(makeFunctions{ii});
    subfolder = makeName;
    if isempty(outputRoot)
        % put files in subfolders of the default output folders
        tempFolder = fullfile( ...
            getpref('RenderToolbox3', 'tempFolder'), ...
            subfolder, outputName);
        outputDataFolder = fullfile( ...
            getpref('RenderToolbox3', 'outputDataFolder'), ...
            subfolder, outputName);
        outputImageFolder = fullfile( ...
            getpref('RenderToolbox3', 'outputImageFolder'), ...
            subfolder, outputName);
        
    else
        % put all files under the given output root
        tempFolder = fullfile(outputRoot, 'temp', subfolder, outputName);
        outputDataFolder = fullfile(outputRoot, 'data', subfolder, outputName);
        outputImageFolder = fullfile(outputRoot, 'images', subfolder, outputName);
    end
    
    % let the Make* function use new default output folders
    setpref('RenderToolbox3', 'tempFolder', tempFolder);
    setpref('RenderToolbox3', 'outputDataFolder', outputDataFolder);
    setpref('RenderToolbox3', 'outputImageFolder', outputImageFolder);
    
    try
        % make the example scene!
        evalin('base', 'clear');
        evalin('base', ['run ' fullfile(makePath, makeName)]);
        results(ii).isSuccess = true;
        
    catch err
        % trap the error
        results(ii).isSuccess = false;
        results(ii).error = err;
    end
    
    % keep track of timing
    results(ii).elapsed = toc(testTic);
end

% how did it go?
isExampleSuccess = [results.isSuccess];
fprintf('\n%d scenes succeeded.\n\n', sum(isExampleSuccess));
for ii = find(isExampleSuccess)
    disp(sprintf('%d %s', ii, results(ii).makeFile))
end

fprintf('\n%d scenes failed.\n\n', sum(~isExampleSuccess));
for ii = find(~isExampleSuccess)
    disp('----')
    disp(sprintf('%d %s', ii, results(ii).makeFile))
    disp(results(ii).error)
    disp(' ')
end

toc(testTic)

% restore original folder and preferences
%   which might have changed
cd(originalFolder)
setpref('RenderToolbox3', ...
    fieldnames(originalPrefs), struct2cell(originalPrefs));

%% Save lots of results to a .mat file.
hints = GetDefaultHints();
if ~isempty(outputRoot) && ~exist(outputRoot, 'dir')
    mkdir(outputRoot);
end
baseName = mfilename();
dateTime = datestr(now(), 30);
if isempty(outputName)
    resultsBase = sprintf('%s-%s', baseName, dateTime);
else
    resultsBase = sprintf('%s-%s-%s', baseName, outputName, dateTime);
end
resultsFile = fullfile(outputRoot, resultsBase);
save(resultsFile, 'outputRoot', 'outputName', 'makeFunctions', ...
    'isDryRun', 'results', 'hints');