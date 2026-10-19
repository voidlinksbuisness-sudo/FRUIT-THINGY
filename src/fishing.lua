do
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

    local FishConfig = {
        CastTarget     = 0.96,
        WaitBeforeReel = 0.2,
        DeadZone       = 0.35,
        BiteTimeout    = 20,
        ResetDelay     = 2,
    }

    local FishState = {
        Running        = false,
        IsHolding      = false,
        CastComplete   = false,
        FishDetected   = false,
        WaitingForUI   = false,
        ReelingStarted = false,
        WaitStart      = 0,
        Clicks         = 0,
        FishCaught     = 0,
        LastCastTime   = 0,
        BiteClickTime  = 0,
    }

    local function fish_hold()
        if not FishState.IsHolding then FishState.IsHolding=true; pcall(mouse1press); FishState.Clicks=FishState.Clicks+1 end
    end
    local function fish_release()
        if FishState.IsHolding then FishState.IsHolding=false; pcall(mouse1release) end
    end
    local function fish_click()
        pcall(mouse1click); FishState.Clicks=FishState.Clicks+1
    end

    local function fish_fullReset()
        fish_release()
        FishState.CastComplete=false
        FishState.FishDetected=false
        FishState.WaitingForUI=false
        FishState.ReelingStarted=false
        FishState.WaitStart=0
        FishState.LastCastTime=0
        FishState.BiteClickTime=0
        task.wait(FishConfig.ResetDelay)
    end

    local function fish_getCastFrame()
        local char=LocalPlayer.Character; if not char then return nil end
        local part=char:FindFirstChild("Fishing_Cast Meter"); if not part then return nil end
        local meter=part:FindFirstChild("CastMeter"); if not meter then return nil end
        local bar=meter:FindFirstChild("Bar"); if not bar then return nil end
        return bar:FindFirstChild("Frame")
    end

    local function fish_getCastFill()
        local frame=fish_getCastFrame(); if not frame then return 0 end
        local ok1,size=pcall(function() return frame.AbsoluteSize.Y end)
        local ok2,max=pcall(function() return frame.Parent.AbsoluteSize.Y end)
        if ok1 and ok2 and size and max and max>0 then return size/max end
        return 0
    end

    local function fish_getReelUI()
        if not PlayerGui or not PlayerGui.Parent then PlayerGui=LocalPlayer:FindFirstChild("PlayerGui") end
        if not PlayerGui then return nil end
        local ui=PlayerGui:FindFirstChild("Fishing_Reeling"); if not ui then return nil end
        local mini=ui:FindFirstChild("Minigame") or ui:FindFirstChild("MiniGame"); if not mini then return nil end
        local con=mini:FindFirstChild("Container"); if not con then return nil end
        local treasure=con:FindFirstChild("Treasure")
        local treasureIcon=treasure and (treasure:FindFirstChild("UnopenedIcon") or treasure:FindFirstChild("OpenedIcon")) or nil
        return {
            Fish=con:FindFirstChild("Fish"),
            Treasure=treasureIcon,
            Zone=con:FindFirstChild("ReelZone") or con:FindFirstChild("Zone")
        }
    end

    local function fish_isReelOpen()
        if not PlayerGui or not PlayerGui.Parent then PlayerGui=LocalPlayer:FindFirstChild("PlayerGui") end
        return PlayerGui and PlayerGui:FindFirstChild("Fishing_Reeling") ~= nil
    end

    local function fish_getCenter(obj)
        if not obj then return 0 end
        local ok1,x=pcall(function() return obj.AbsolutePosition.X end)
        local ok2,w=pcall(function() return obj.AbsoluteSize.X end)
        if ok1 and ok2 and x and w then return x+w/2 end
        return 0
    end

    local function fish_getFishSound()
        local char=LocalPlayer.Character; if not char then return nil end
        local rod=char:FindFirstChild("Fishing Rod"); if not rod then return nil end
        local part=rod:FindFirstChild("Fishing Rod"); if not part then return nil end
        local metal=part:FindFirstChild("Metal"); if not metal then return nil end
        return metal:FindFirstChild("FishOnLine")
    end

    local function fish_isBiting()
        if fish_getFishSound() then return true end
        local char=LocalPlayer.Character
        if not char then return false end
        local okDesc,descendants=pcall(function() return char:GetDescendants() end)
        if not okDesc or not descendants then return false end
        for _,object in pairs(descendants) do
            local okName,name=pcall(function() return string.lower(object.Name or "") end)
            if okName and (string.find(name,"fishonline",1,true) or string.find(name,"fish on line",1,true)) then
                return true
            end
        end
        return false
    end

    local function fish_isZoneLeft(ui)
        if not ui then return false end
        local fish=fish_getCenter(ui.Treasure or ui.Fish); local zone=fish_getCenter(ui.Zone)
        if fish==0 or zone==0 then return false end
        return zone < fish - FishConfig.DeadZone
    end

    local function fish_mainLoop()
        FishState.WaitStart=0
        local ending=false; local endTimer=0; local wasOpen=false
        while FishState.Running do
            task.wait(0.05)
            if farmPriorityBlocked() then
                fish_release()
                FishState.CastComplete=false
                FishState.FishDetected=false
                FishState.WaitingForUI=false
                FishState.ReelingStarted=false
                FishState.WaitStart=0
                continue
            end
            if not FishState.CastComplete then
                local frame=fish_getCastFrame()
                if frame then
                    fish_hold()
                    if fish_getCastFill()>=FishConfig.CastTarget then
                        fish_release()
                        FishState.CastComplete=true; FishState.FishDetected=false
                        FishState.WaitingForUI=false; FishState.ReelingStarted=false
                        FishState.WaitStart=0; FishState.LastCastTime=os.clock()
                        ending=false; wasOpen=false
                    end
                else
                    if not FishState.IsHolding then fish_click(); task.wait(0.1) end
                end
                continue
            end
            if FishState.CastComplete and not FishState.FishDetected then
                if os.clock()-FishState.LastCastTime>FishConfig.BiteTimeout then
                    fish_fullReset()
                    continue
                end
                if fish_isBiting() then
                    FishState.FishDetected=true
                    FishState.BiteClickTime=os.clock()
                    fish_click(); task.wait(0.14); fish_click(); task.wait(0.14); fish_click()
                end
                continue
            end
            if FishState.FishDetected then
                local open=fish_isReelOpen()
                if open then
                    wasOpen=true
                    local ui=fish_getReelUI()
                    if ui then
                        if not FishState.WaitingForUI then
                            FishState.WaitingForUI=true; FishState.ReelingStarted=false
                            FishState.WaitStart=os.clock(); ending=false
                        end
                        if not FishState.ReelingStarted then
                            if os.clock()-FishState.WaitStart>=FishConfig.WaitBeforeReel then
                                FishState.ReelingStarted=true; fish_click(); task.wait(0.2); fish_click()
                            end
                            continue
                        end
                        if FishState.ReelingStarted then
                            if fish_isZoneLeft(ui) then fish_hold() else fish_release() end
                        end
                    end
                else
                    if not wasOpen and os.clock()-FishState.BiteClickTime>3 then
                        fish_fullReset()
                        continue
                    end
                    if wasOpen and not ending then
                        ending=true; endTimer=os.clock()
                        FishState.FishCaught=FishState.FishCaught+1
                        fish_release()
                        notify("Fish caught! ("..FishState.FishCaught..")", "laced.club", 2)
                    end
                    if ending then
                        local el=os.clock()-endTimer
                        if el>=0 and el<0.05 then fish_click()
                        elseif el>=0.2 and el<0.25 then fish_click()
                        elseif el>=0.4 and el<0.45 then fish_click()
                        elseif el>=0.5 then
                            FishState.CastComplete=false; FishState.FishDetected=false
                            FishState.WaitingForUI=false; FishState.ReelingStarted=false
                            FishState.WaitStart=0; ending=false; wasOpen=false
                        end
                    end
                    FishState.WaitStart=os.clock()
                end
            end
        end
    end

    mainTab:AddToggle("auto_fish", {
        Text="Auto Fish", Description="Automatically casts, detects fish, and reels.",
        Default=false, Keybind=true, Column=2,
        Callback=function(v)
            S.autoFish=v
            if v then
                S.autoRepair=false
                pcall(function() Window:Set("auto_ship_repair",false) end)
                FishState.Running=true; FishState.CastComplete=false; FishState.FishDetected=false
                FishState.WaitingForUI=false; FishState.ReelingStarted=false
                FishState.WaitStart=0; FishState.Clicks=0; FishState.FishCaught=0
                FishState.LastCastTime=0; FishState.BiteClickTime=0
                task.spawn(fish_mainLoop)
                notify("Auto Fish started!", "laced.club", 2)
            else
                FishState.Running=false; fish_release()
                notify("Auto Fish stopped. Fish: "..FishState.FishCaught, "laced.club", 2)
            end
        end
    })
end

