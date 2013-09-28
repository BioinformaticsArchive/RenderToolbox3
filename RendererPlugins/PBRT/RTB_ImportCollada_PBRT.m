%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada parent scene file the PBRT native format
%   @param colladaFile input Collada parent scene file name or path
%   @param adjustments native adjustments data, or file name or path
%   @param outputFolder folder where to write new files
%   @param imageName the name to use for this scene and new files
%   @param hints struct of RenderToolbox3 options
%
% @details
% This is the RenderToolbox3 "ImportCollada" function for PBRT.
%
% @details
% For more about ImportCollada functions see
% RTB_ImportCollada_SampleRenderer().
%
% @details
% Usage:
%   [scene, requiredFiles] = RTB_ImportCollada_PBRT(colladaFile, adjustments, outputFolder, imageName, hints)
%
% @ingroup RendererPlugins
function [scene, requiredFiles] = RTB_ImportCollada_PBRT(colladaFile, adjustments, outputFolder, imageName, hints)

% declare new and required files
scene.colladaFile = colladaFile;
scene.pbrtFile = fullfile(outputFolder, [imageName '.pbrt']);
scene.pbrtXMLFile = fullfile(outputFolder, [imageName '.pbrt.xml']);
scene.adjustments = adjustments;
requiredFiles = {scene.colladaFile, scene.pbrtFile, ...
    scene.pbrtXMLFile, scene.adjustments};

% image is a safe default film for PBRT
if isempty(hints.filmType)
    hints.filmType = 'image';
end

%% Invoke several Collada to PBRT utilities.
fprintf('Converting %s\n  to %s.\n', colladaFile, scene.pbrtFile);

% run in the destination folder to capture all ouput there
originalFolder = pwd();
cd(outputFolder);

% read the collada file
[colladaDoc, colladaIDMap] = ReadSceneDOM(colladaFile);

% create a new PBRT-XML document
[pbrtDoc, pbrtIDMap] = CreateStubDOM(colladaIDMap, 'pbrt_xml');
PopulateStubDOM(pbrtIDMap, colladaIDMap, hints);

% add a film node to the to the adjustments document
filmNodeID = 'film';
filmPBRTIdentifier = 'Film';
[adjustDoc, adjustIDMap] = ReadSceneDOM(scene.adjustments);
adjustRoot = adjustDoc.getDocumentElement();
filmNode = CreateElementChild(adjustRoot, filmPBRTIdentifier, filmNodeID);
adjustIDMap(filmNodeID) = filmNode;

% fill in the film parameters
SetType(adjustIDMap, filmNodeID, filmPBRTIdentifier, hints.filmType);
AddParameter(adjustIDMap, filmNodeID, ...
    'xresolution', 'integer', hints.imageWidth);
AddParameter(adjustIDMap, filmNodeID, ...
    'yresolution', 'integer', hints.imageHeight);

% write the adjusted PBRT-XML document to file
MergeAdjustments(pbrtDoc, adjustDoc);
WriteSceneDOM(scene.pbrtXMLFile, pbrtDoc);

% dump the PBRT-XML document into a .pbrt text file
WritePBRTFile(scene.pbrtFile, scene.pbrtXMLFile, hints);

cd(originalFolder)

%% Detect auxiliary geometry files.
auxiliaryFiles = FindFiles(outputPath, 'mesh-data-[^\.]+.pbrt');
requiredFiles = cat(2, requiredFiles, auxiliaryFiles);
