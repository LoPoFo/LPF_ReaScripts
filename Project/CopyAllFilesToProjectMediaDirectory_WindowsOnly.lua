--[[
  @author LPF
  @description Copy All Files To Project Media Directory (Windows Only)
  @link
    Github Repository https://github.com/LoPoFo/LPF_ReaScripts
  @version 1.0
  @changelog
    Add script.
  @about
    The script implements "Project Bay > Copy file to project media directory". 
    But ignore empty item, MIDI take and rpp media.
    You must put fileops.dll into your Userplugins folder. 
	Get it from https://forum.cockos.com/showthread.php?t=225701
]]
local mediaPath = reaper.GetProjectPath("")
local CopyFile = package.loadlib(reaper.GetResourcePath().."\\UserPlugins\\fileops.dll", "copyFile")

local function FileContent(path)
    local file = io.open(path, "rb")
    local content = file:read("*a")
    file:close()
    return content
end

local function CopyFileAfterComparison(srcPath,desPath,postfix)
    local newPath = desPath
    local compareRes = false
    while(reaper.file_exists(newPath) and not compareRes and postfix<1000) do
        compareRes = FileContent(srcPath)==FileContent(newPath)
        if not compareRes then
            postfix = postfix + 1
            local p, pf = desPath:match("(.+)%.(.+)")
            newPath = p.."-"..string.format("%.3o",postfix).."."..pf;
        end
    end	
    if not compareRes then CopyFile(srcPath,newPath) end
    return newPath
end

local function SourcePath(take)
    -- https://forums.cockos.com/showthread.php?t=231606
    -- Ignore MIDI take
    if reaper.TakeIsMIDI(take) then return false end
    local src = reaper.GetMediaItemTake_Source(take)
    local srcP = reaper.GetMediaSourceParent(src)
    if srcP then src = srcP end
    return reaper.GetMediaSourceFileName(src,"")
end

local function CopyAllFilesToProjMediaDir()
    local ci = reaper.CountMediaItems(0)
    for i = 1, ci do
        local item = reaper.GetMediaItem(0,i-1)
        local ct = reaper.CountTakes(item)
        -- empty item has no take
        for j = 1, ct do
            local take = reaper.GetMediaItemTake(item,j-1)
            local srcPath = SourcePath(take)
            if srcPath then
                local path,name = srcPath:match("(.+)[/\\](.+)")
                local desPath = mediaPath.."\\"..name
                -- Ignore rpp media
                if not string.find(name, ".rpp") and srcPath ~= desPath then
                    local newPath = CopyFileAfterComparison(srcPath,desPath,0)
                    reaper.BR_SetTakeSourceFromFile2(take,newPath,false,true)
                end
            end
        end
    end
end

reaper.Undo_BeginBlock()
CopyAllFilesToProjMediaDir()
reaper.Undo_EndBlock("Copy All Files To Project Media Directory", -1)
