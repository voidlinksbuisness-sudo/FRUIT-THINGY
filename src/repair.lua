do
    local RepairState={holding=false}

    local function repairRelease()
        if RepairState.holding then
            RepairState.holding=false
            pcall(mouse1release)
        end
    end

    local function repairHold()
        if not RepairState.holding then
            RepairState.holding=true
            pcall(mouse1press)
        end
    end

    local function getRepairBarInfo()
        local playerGui=LocalPlayer:FindFirstChild("PlayerGui")
        local main=playerGui and playerGui:FindFirstChild("Main") or nil
        local bottom=main and main:FindFirstChild("BottomHUDList") or nil
        local mini=bottom and bottom:FindFirstChild("RepairMiniGame") or nil
        local progress=mini and mini:FindFirstChild("ProgressBar") or nil
        local fill=progress and progress:FindFirstChild("Fill") or nil
        local goal=progress and progress:FindFirstChild("Goal") or nil
        if not fill or not goal then return nil end

        local ok,fillPosition,fillSize,goalPosition,goalSize=pcall(function()
            return fill.AbsolutePosition,fill.AbsoluteSize,goal.AbsolutePosition,goal.AbsoluteSize
        end)
        if not ok or not fillPosition or not fillSize or not goalPosition or not goalSize then return nil end
        return {
            fillRight=fillPosition.X+fillSize.X,
            goalLeft=goalPosition.X,
            goalRight=goalPosition.X+goalSize.X
        }
    end

    task.spawn(function()
        while true do
            if S.autoRepair then
                local info=getRepairBarInfo()
                if info then
                    if info.fillRight>=info.goalLeft-8 and info.fillRight<=info.goalRight+14 then
                        repairRelease()
                        task.wait(0.35)
                    else
                        repairHold()
                    end
                else
                    repairRelease()
                end
                task.wait(0.02)
            else
                repairRelease()
                task.wait(0.2)
            end
        end
    end)
end

