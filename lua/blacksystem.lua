local log_file_name = "blacklist_"..os.date("%d_%m_%Y_%H_%M_%S")..".log"
local enable_log = false
function split(str,reps)
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function (w)
        word = string.gsub(w, "\n", "")
        table.insert(resultStrList,word)
    end)
    return resultStrList
end
local blacklist = {
    kickplayerbythis = function(grl,this,reason,ply)
        if grl == nil then return end
        for i=1,#grl do
            if grl[i] == this then
                player.kick(ply)
                player.kick_idm(ply)
                player.kick_brute(ply)
                utils.notify("踢出玩家 "..player.get_name(ply),"踢出原因: "..reason,10,4)
                utils.send_chat("踢出玩家: "..player.get_name(ply).."  踢出原因: "..reason, false)
            end
        end
    end,
    outputkicklog = function(ply,word,text)
        if fs.file_load_txt(log_file_name) == "" then
            if string.find(fs.file_load_txt(log_file_name),"Rid: "..player.get_rid(ply)) == nil then
                fs.file_write(log_file_name, "["..os.date("%d.%m.%Y %H:%M:%S").."] Rid: "..player.get_rid(ply).."\n["..os.date("%d.%m.%Y %H:%M:%S").."]原因: 发出违禁词("..word..")\n["..os.date("%d.%m.%Y %H:%M:%S").."]内容: "..text)
            end
        else
            if string.find(fs.file_load_txt(log_file_name),"Rid: "..player.get_rid(ply)) == nil then
                fs.file_append(log_file_name, "\n----------------------------------------------\n["..os.date("%d.%m.%Y %H:%M:%S").."]Rid: "..player.get_rid(ply).."\n["..os.date("%d.%m.%Y %H:%M:%S").."]原因: 发出违禁词("..word..")\n["..os.date("%d.%m.%Y %H:%M:%S").."]内容: "..text)
            end
        end
    end,
    outputlog = function(text)
        fs.file_write(log_file_name, "["..os.date("%d.%m.%Y %H:%M:%S").."] "..text)
    end,
    blackwords = {},
    whitewords = {},
    blackplayername = {},
    blackplayer = {},
    whiteplayer = {},
    file_name = {
        blackwords = "blackwords.cfg",
        whitewords = "whitewords.cfg",
        blackplayername = "blackplayername.cfg",
        blackplayer = {
            ["广告机"] = "blackplayer_ads.cfg",
            ["custom"] = "blackplayer_custom.cfg"
        },
        whiteplayer = "whiteplayer.cfg"
    }
}

function refresh_cfg()
    blacklist.blackwords = split(fs.file_load_txt(blacklist.file_name.blackwords),"\r")
    blacklist.whitewords = split(fs.file_load_txt(blacklist.file_name.whitewords),"\r")
    blacklist.blackplayername = split(fs.file_load_txt(blacklist.file_name.blackplayername),"\r")
    blacklist.blackplayer["广告机"] = split(fs.file_load_txt(blacklist.file_name.blackplayer["广告机"]),"\r")
    blacklist.blackplayer["custom"] = split(fs.file_load_txt(blacklist.file_name.blackplayer["custom"]),"\r")
    blacklist.whiteplayer = split(fs.file_load_txt(blacklist.file_name.whiteplayer),"\r")
end
function kick_player(ply)
    refresh_cfg()
    blacklist.kickplayerbythis(blacklist.blackplayer["custom"],tostring(player.get_rid(ply)),"黑名单",ply)
    blacklist.kickplayerbythis(blacklist.blackplayer["广告机"],tostring(player.get_rid(ply)),"广告机",ply)
    blacklist.kickplayerbythis(blacklist.blackplayername,player.get_name(ply),"黑名单名字",ply)
    return
end


function OnChatMsg(ply, text)
    refresh_cfg()
    for x = 1,#blacklist.whiteplayer do
        if blacklist.whiteplayer[x] == tostring(player.get_rid(ply)) then
            utils.notify("踢出玩家 "..player.get_name(ply),"白名单",10,4)
        else
            for i = 1,#blacklist.blackwords do 
                fs.file_write("test.txt", blacklist.blackwords[i])
                if string.find(text, blacklist.blackwords[i]) ~= nil then
                    
                    for y = 1,#blacklist.whitewords do
                        
                        if string.find(text, blacklist.whitewords[y]) == nil then
                            if not player.is_local(ply) then
                                player.kick(ply)
                                player.kick_idm(ply)
                                player.kick_brute(ply)
                                utils.notify("踢出玩家 "..player.get_name(ply),"踢出原因: 发出违禁词("..blacklist.blackwords[i]..")",10,4)
                                utils.send_chat("踢出玩家: "..player.get_name(ply).."  踢出原因: 发出违禁词("..blacklist.blackwords[i]..")", false)
                                if enable_log then
                                    blacklist.outputkicklog(ply,blacklist.blackwords[i],text)
                                end
                                return
                            end
                        else
                            utils.notify("踢出玩家 "..player.get_name(ply),"非恶意关键词",10,4)
                            return
                        end
                    end
                end
            end
        end
    end
end

function OnPlayerJoin(ply)
    kick_player(ply)
end
function OnScriptEvent(ply, event, args)
    kick_player(ply)
end
function OnNetworkEvent(ply, event, buf)
    kick_player(ply)
end
function OnInit()
    utils.notify("黑名单","加载完毕",19,1)
    if enable_log then
        blacklist.outputlog("加载脚本完毕")
    end
end
function OnDone()
    utils.notify("黑名单","卸载完毕",19,1)
    if enable_log then
        blacklist.outputlog("卸载脚本完毕")
    end
end