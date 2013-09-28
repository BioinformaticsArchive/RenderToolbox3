%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert mappings objects to native adjustments for the PBRT.
%   @param objects mappings objects as returned from MappingsToObjects()
%   @param adjustments native adjustments to be updated, if any
%
% @details
% This is the RenderToolbox3 "ApplyMappings" function for PBRT.
%
% @details
% For more about ApplyMappings functions, see
% RTB_ApplyMappings_SampleRenderer().
%
% @details
% Usage:
%   adjustments = RTB_ApplyMappings_PBRT(objects, adjustments)
%
% @ingroup RendererPlugins
function adjustments = RTB_ApplyMappings_PBRT(objects, adjustments)

% PBRT default adjustments is an XML adjustments file name.
if isempty(adjustments)
    adjustments = getpref('PBRT', 'adjustments');
end

if isempty(objects)
    return;
end

% convert generic mappings object names and values to pbrt-native
if strcmp('Generic', objects(1).blockType)
    objects = GenericObjectsToPBRT(objects);
end

% add mappings data to the pbrt adjustments XML file
[adjustDoc, adjustIDMap] = ReadSceneDOM(adjustments);
ApplyPBRTObjects(adjustIDMap, objects);
WriteSceneDOM(adjustments, adjustDoc);