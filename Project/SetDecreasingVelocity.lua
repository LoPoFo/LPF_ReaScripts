--[[
 * ReaScript Name: Set Decreasing Velocity
 * Instructions: Open MIDI Editor. Select some notes. Then run this script.
 * Version: 1.0
 * Author: LPF
 * REAPER: 6.57
--]]

function Msg(param) reaper.ShowConsoleMsg(tostring(param) .. "\n") end

function GetAllSelectedNotesIndex(take)
  _, notecnt, _, _ = reaper.MIDI_CountEvts(take) 
  local list = {}
  for i = 1, notecnt do
    _, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i - 1)
    if selected then
      table.insert(list,i-1)
    end
  end
  return list
end

function GetNoteVelocity(take,index)
	_, _, _, _, _, _, _, vel = reaper.MIDI_GetNote(take, index)
	return vel
end

function SetNoteVelocity(take,index,velocity)
    _, selected, muted, startppqpos, endppqpos, chan, pitch, _ = reaper.MIDI_GetNote(take, index)
    reaper.MIDI_SetNote(take, index, selected, muted, startppqpos, endppqpos, chan, pitch, velocity, false)
end

function round(n)
    return math.floor(n+0.5)
end

function Main()
  local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
  local list = GetAllSelectedNotesIndex(take);
  local count = #list
  if count > 2 then
    local velMax = GetNoteVelocity(take,list[1])
    local velMin = velMax * 0.5
    local offset = (velMax - velMin)/(count - 1)
    for i = 2, count do
       SetNoteVelocity(take, list[i], round(velMax - (i-1)*offset))
    end
  end
end

reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Set Decreasing Velocity", 0)
--reaper.UpdateArrange()


