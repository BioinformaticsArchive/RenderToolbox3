%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Try to render an unknown, complex scene without totally barfing.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
%sceneFile = 'cup.dae';
sceneFile = 'interior.dae';

%% Use the automatic, default mappings file.
colors = { ...
    'mccBabel-1.spd', ...
    'mccBabel-2.spd', ...
    'mccBabel-3.spd', ...
    'mccBabel-4.spd', ...
    };
mappingsFile = WriteDefaultMappingsFile(sceneFile, '', '', colors);

%% Choose batch renderer options.
hints.imageHeight = 480;
hints.imageWidth = 640;
hints.isDeleteTemp = true;

%% Render with Mitsuba and PBRT
toneMapFactor = 10;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    outFiles = BatchRender(sceneFile, '', mappingsFile, hints);
    montageName = sprintf('%s (%s)', 'ComplexScene', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
