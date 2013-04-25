%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Run all "Make*" functions in the ExampleScenes/ folder.
%   @param outputRoot base path where to save output data
%   @param makeFunctions cell array of rendering scripts to invoke
%
% @details
% By default, renders example scenes by invoking all of the "Make*" scripts
% found within the ExampleScenes/ folder.  If @a makeFunctions is provided,
% it must be a cell array of rendering scripts to invoke instead.
%
% @details
% @a outputRoot is the base path under which all output data should be
% saved.  If outputRoot is missing or empty, uses default folders from
% getpref('RenderToolbox3').  Outputs will be saved in subfolders of @a
% outputRoot, one for each rendering script.
%
% @details
% Returns a struct with information about each rendering script, such as
% whether the script executed successfully, any Matlab error struct that
% was thrown, and when the script completed.
%
% @details
% Saves a .mat file with several variables about the test parameters and
% results:
%   - outputRoot, the given @a outputRoot
%   - makeFunctions, the given @a makeFunctions
%   - hints, RenderToolbox3 options, as returned from GetDefaultHints()
%   - results, the returned struct of results about rendering scripts
% .
% @details
% The .mat file will be saved in the given @a outputRoot folder.  It will
% have a name that that includes the name of this m-file, plus the date and
% time.
%
% @details
% Usage:
%   results = TestAllExampleScenes(outputRoot, makeFunctions)
%
% @ingroup ExampleScenes
function results = TestAllExampleScenes(outputRoot, makeFunctions)

if nargin < 1  || isempty(outputRoot)
    outputRoot = '';
end

if nargin < 2 || isempty(makeFunctions)
    % find all the m-functions named "Make*", in ExampleScenes/
    exampleRoot = fullfile(RenderToolboxRoot(), 'ExampleScenes');
    makeFunctions = FindFiles(exampleRoot, 'Make\w+\.m');
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

% choose where to write all outputs
if isempty(outputRoot)
    tempRoot = getpref('RenderToolbox3', 'tempFolder');
    dataRoot = getpref('RenderToolbox3', 'outputDataFolder');
    imageRoot = getpref('RenderToolbox3', 'outputImageFolder');
    
else
    tempRoot = fullfile(outputRoot, 'temp');
    dataRoot = fullfile(outputRoot, 'data');
    imageRoot = fullfile(outputRoot, 'images');
end


% try to render each example scene
for ii = 1:numel(makeFunctions)
    
    % choose where to write outputs for this scene
    [makePath, makeName, makeExt] = fileparts(makeFunctions{ii});
    subfolder = makeName;
    
    % let the Make* function use new default output folders
    setpref('RenderToolbox3', 'tempFolder', fullfile(tempRoot, subfolder));
    setpref('RenderToolbox3', 'outputDataFolder', fullfile(dataRoot, subfolder));
    setpref('RenderToolbox3', 'outputImageFolder', fullfile(imageRoot, subfolder));
    
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
resultsBase = sprintf('%s-%s', baseName, dateTime);
resultsFile = fullfile(outputRoot, resultsBase);
save(resultsFile, 'outputRoot', 'makeFunctions', 'results', 'hints');