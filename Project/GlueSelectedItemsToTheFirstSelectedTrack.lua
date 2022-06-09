--[[
 * ReaScript Name: Glue selected items to the first selected track
 * Instructions: Glue them. Then delete empty tracks.
 * Version: 1.0
 * Author: LPF
 * REAPER: 6.57
--]]

function Msg(param) reaper.ShowConsoleMsg(tostring(param) .. "\n") end

function Main()
    local count = reaper.CountSelectedMediaItems(0)
    local tracks = {}
    if count > 0 then
        local item = reaper.GetSelectedMediaItem(0, 0)
        local firstTrack = reaper.GetMediaItem_Track(item)
        for i = 1, count - 1 do
            item = reaper.GetSelectedMediaItem(0, i)
		    
            track = reaper.GetMediaItem_Track(item);
            table.insert(tracks, track)
            
            reaper.MoveMediaItemToTrack(item, firstTrack)
        end
        end
    
    tracks = DeleteTheSameElement(tracks)
    for _, value in pairs(tracks) do
        DeleteEmptyTrack(value)
    end
  
    reaper.Main_OnCommand(40362, 0)
end

function DeleteTheSameElement(t)
    local exist = {}
    for v, value in pairs(t) do
        exist[value] = true
    end
    local newTable = {}
    for v, k in pairs(exist) do
        table.insert(newTable, v)
    end
    return newTable 
end

function DeleteEmptyTrack(track)
    if IsEmptyTrack(track) then reaper.DeleteTrack(track) end
end

function IsEmptyTrack(track)
    return reaper.CountTrackMediaItems(track) == 0
end

reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Set Decreasing Velocity", 0)
