%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render a Ward sphere under a point light and orthogonal optics.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
sceneFile = 'SimpleSphere.dae';
mappingsFile = 'SimpleSphereMappings.txt';

%% Choose batch renderer options.
hints.imageWidth = 201;
hints.imageHeight = 201;
hints.isAbsoluteResourcePaths = false;

%% Render with Mitsuba and PBRT
toneMapFactor = 10;
isScale = true;
for renderer = {'PBRT'}
    hints.renderer = renderer{1};
    sceneFiles = MakeSceneFiles(sceneFile, '', mappingsFile, hints);
    outFiles = BatchRender(sceneFiles, hints);
    montageName = sprintf('%s (%s)', 'SimpleSphere', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
