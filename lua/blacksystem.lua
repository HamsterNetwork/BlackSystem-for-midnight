local log_file_name = "blacklist_"..os.date("%d_%m_%Y_%H_%M_%S")..".log"
local json = require("lib/json")
local files = require("lib/files")
local path = fs.get_dir_product() .. "blacksystem\\"
print(fs.get_dir_product().."config/config.json")
local config = json.decode(files.load_file(fs.get_dir_product().."config/config.json"))["blacksystem"]
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
                if config["crash"] then
                    player.crash_himiko_start(ply)
                    player.crash_izuku_start(ply)
                end
                utils.notify("踢出玩家 "..player.get_name(ply),"踢出原因: "..reason,10,4)
                utils.send_chat("踢出玩家: "..player.get_name(ply).."  踢出原因: "..reason, false)
            end
        end
    end,
    outputkicklog = function(ply,word,text)
        if files.load_file(path..log_file_name) == "" then
            if string.find(files.load_file(path..log_file_name),"Rid: "..player.get_rid(ply)) == nil then
                files.write_file(path..log_file_name, "["..os.date("%d.%m.%Y %H:%M:%S").."] Rid: "..player.get_rid(ply).."\n["..os.date("%d.%m.%Y %H:%M:%S").."]原因: 发出违禁词("..word..")\n["..os.date("%d.%m.%Y %H:%M:%S").."]内容: "..text)
            end
        else
            if string.find(files.load_file(path..log_file_name),"Rid: "..player.get_rid(ply)) == nil then
                files.append_file(path..log_file_name, "\n----------------------------------------------\n["..os.date("%d.%m.%Y %H:%M:%S").."]Rid: "..player.get_rid(ply).."\n["..os.date("%d.%m.%Y %H:%M:%S").."]原因: 发出违禁词("..word..")\n["..os.date("%d.%m.%Y %H:%M:%S").."]内容: "..text)
            end
        end
    end,
    outputlog = function(text)
        files.write_file(path..log_file_name, "["..os.date("%d.%m.%Y %H:%M:%S").."] "..text)
    end,
    blackwords = {},
    whitewords = {},
    blackplayername = {},
    blackplayer = {},
    whiteplayer = {},
}

function refresh_cfg()
    blacklist.blackwords = split(files.load_file(path..config["file_name"]["blackwords"]),"\r")
    blacklist.whitewords = split(files.load_file(path..config["file_name"]["whitewords"]),"\r")
    blacklist.blackplayername = split(files.load_file(path..config["file_name"]["blackplayername"]),"\r")
    blacklist.blackplayer["广告机"] = split(files.load_file(path..config["file_name"]["blackplayer"]["广告机"]),"\r")
    blacklist.blackplayer["custom"] = split(files.load_file(path..config["file_name"]["blackplayer"]["custom"]),"\r")
    blacklist.whiteplayer = split(files.load_file(path..config["file_name"]["whiteplayer"]),"\r")
end
function kick_player(ply)
    refresh_cfg()
    blacklist.kickplayerbythis(blacklist.blackplayer["custom"],tostring(player.get_rid(ply)),"黑名单",ply)
    blacklist.kickplayerbythis(blacklist.blackplayer["广告机"],tostring(player.get_rid(ply)),"广告机",ply)
    blacklist.kickplayerbythis(blacklist.blackplayername,player.get_name(ply),"黑名单名字",ply)
    return
end


function OnChatMsg(ply, text)
    if not config["enable"] then return end
    refresh_cfg()
    for x = 1,#blacklist.whiteplayer do
        if blacklist.whiteplayer[x] == tostring(player.get_rid(ply)) then
            utils.notify("踢出玩家 "..player.get_name(ply),"白名单",10,4)
        else
            for i = 1,#blacklist.blackwords do 
                files.write_file(path.."test.txt", blacklist.blackwords[i])
                if string.find(text, blacklist.blackwords[i]) ~= nil then
                    
                    for y = 1,#blacklist.whitewords do
                        
                        if string.find(text, blacklist.whitewords[y]) == nil then
                            if not player.is_local(ply) then
                                player.kick(ply)
                                player.kick_idm(ply)
                                player.kick_brute(ply)
                                if config["crash"] then
                                    player.crash_himiko_start(ply)
                                    player.crash_izuku_start(ply)
                                end
                                utils.notify("踢出玩家 "..player.get_name(ply),"踢出原因: 发出违禁词("..blacklist.blackwords[i]..")",10,4)
                                utils.send_chat("踢出玩家: "..player.get_name(ply).."  踢出原因: 发出违禁词("..blacklist.blackwords[i]..")", false)
                                if config["output_log"] then
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
    if not config["enable"] then return end
    kick_player(ply)
end
function OnScriptEvent(ply, event, args)
    if not config["enable"] then return end
    kick_player(ply)
end
function OnNetworkEvent(ply, event, buf)
    if not config["enable"] then return end
    kick_player(ply)
end
function OnInit()
    utils.notify("黑名单","加载完毕",19,1)
    if config["output_log"] then
        blacklist.outputlog("加载脚本完毕")
    end
end
function OnDone()
    utils.notify("黑名单","卸载完毕",19,1)
    if config["output_log"] then
        blacklist.outputlog("卸载脚本完毕")
    end
end

local key_index = 1
local title_index = 1
local titles = {
"Players",
"AddBlack",
"AddWhite",
"Kick",
"Crash"
}
local function draw_rect(x,y,x1,y1,r, g, b,size)
    draw.set_color(0,r, g, b)
    for i = 1, size do
        draw.rect(x+0.1*i, y+0.1*i, x1-0.1*i, y1-0.1*i)
    end
end
function execute_black()
    local players = player.get_hosts_queue()
    if player.is_local(players[key_index]) then
        utils.notify("黑名单","不可添加本地玩家",16,2)
        return
    end
    if title_index == 2 then
        if files.load_file(path..config["file_name"]["blackplayer"]["custom"]) == "" then
            if string.find(files.load_file(path..config["file_name"]["blackplayer"]["custom"]),tostring(player.get_rid(players[key_index]))) == nil then
                files.write_file(path..config["file_name"]["blackplayer"]["custom"], "\r"..tostring(player.get_rid(players[key_index])))
                utils.notify("黑名单","黑名单添加成功",16,1)
            else
                utils.notify("黑名单","黑名单已存在",16,2)
            end
        else
            if string.find(files.load_file(path..config["file_name"]["blackplayer"]["custom"]),tostring(player.get_rid(players[key_index]))) == nil then
                files.append_file(path..config["file_name"]["blackplayer"]["custom"], "\r"..tostring(player.get_rid(players[key_index])))
                utils.notify("黑名单","黑名单添加成功",16,1)
            else
                utils.notify("黑名单","黑名单已存在",16,2)
            end
        end
    end
    if title_index == 3 then
        if files.load_file(path..config["file_name"]["whiteplayer"]) == "" then
            
            if string.find(files.load_file(path..config["file_name"]["whiteplayer"]),tostring(player.get_rid(players[key_index]))) == nil then
                files.write_file(path..config["file_name"]["whiteplayer"], "\r"..tostring(player.get_rid(players[key_index])))
                utils.notify("黑名单","白名单添加成功",16,1)
            else
                utils.notify("黑名单","白名单已存在",16,2)
            end
        else
            if string.find(files.load_file(path..config["file_name"]["whiteplayer"]),tostring(tostring(player.get_rid(players[key_index])))) == nil then
                files.append_file(path..config["file_name"]["whiteplayer"], "\r"..tostring(player.get_rid(players[key_index])))
                utils.notify("黑名单","白名单添加成功",16,1)
            else
                utils.notify("黑名单","白名单已存在",16,2)
            end
        end
    end
    if title_index == 4 then
        player.kick(players[key_index])
        player.kick_idm(players[key_index])
        player.kick_brute(players[key_index])
    end
    if title_index == 5 then
        player.crash_himiko_start(players[key_index])
        player.crash_izuku_start(players[key_index])
    end
end
function OnFrame()
    config = json.decode(files.load_file(fs.get_dir_product().."config\\config.json"))["blacksystem"]
    if not config["enable"] then return end
    if menu.is_menu_opened() then
        local players = player.get_hosts_queue()
        local x = 0
        local y = 0
        local long_size = 0
        local text_size = draw.get_text_size(player.get_name(player.index()))
        for i=1,#players do
            ply = players[i]
            
            if long_size < draw.get_text_size_x(player.get_name(ply)) then
                long_size = draw.get_text_size_x(player.get_name(ply))
            end
            
        end
        
        for i=1,#players do
            ply = players[i]
            if player.get_name(ply) == player.get_name(players[key_index]) then
                target_text_size = draw.get_text_size(player.get_name(ply))
                draw.set_color(0,34,34,38)
                draw.rect_filled(menu.get_main_menu_pos().x+menu.get_main_menu_size().x, menu.get_main_menu_pos().y, menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size+10, menu.get_main_menu_pos().y+target_text_size.y)
                draw.rect_filled(menu.get_main_menu_pos().x+menu.get_main_menu_size().x, menu.get_main_menu_pos().y+target_text_size.y, menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size+10, menu.get_main_menu_pos().y+target_text_size.y*2)
                draw.set_color(0, 230, 230 ,230)
                oneline_text = "Online:"..#players.."/30"
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size/2-draw.get_text_size_x(oneline_text)/2, menu.get_main_menu_pos().y, oneline_text)
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size/2-draw.get_text_size_x(oneline_text)/2, menu.get_main_menu_pos().y, oneline_text)
                title_text = titles[title_index].."("..title_index.."/"..#titles..")"
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size/2-draw.get_text_size_x(title_text)/2, menu.get_main_menu_pos().y+target_text_size.y, title_text)
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size/2-draw.get_text_size_x(title_text)/2, menu.get_main_menu_pos().y+target_text_size.y, title_text)
                draw_rect(menu.get_main_menu_pos().x+menu.get_main_menu_size().x, menu.get_main_menu_pos().y+target_text_size.y+target_text_size.y*key_index, menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size+10, menu.get_main_menu_pos().y+target_text_size.y+target_text_size.y*(key_index+1),119,119,119,15)
                
            end
            if menu.get_main_menu_pos().y+text_size.y*x < menu.get_main_menu_pos().y+menu.get_main_menu_size().y then

                draw.set_color(0, 230, 230 ,230)
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+5, menu.get_main_menu_pos().y+text_size.y+text_size.y*i, player.get_name(ply))
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+5, menu.get_main_menu_pos().y+text_size.y+text_size.y*i, player.get_name(ply)) 
            end
        end
        
    end
end

function OnKeyPressed(key, down)
    if not config["enable"] then return end
    if menu.is_menu_opened() then
        local players = player.get_hosts_queue()
        if key == 37 then --left
            if down then
                if title_index > 1 then
                    title_index = title_index - 1
                end
            end
        end
        if key == 38 then --up
            if down then
                if key_index > 1 then
                    key_index = key_index - 1
                end
            end
        end
        if key == 39 then --right
            if down then
                if title_index < #titles then
                    title_index = title_index + 1
                end
            end
        end
        if key == 40 then --down
            if down then
                if key_index < #players then
                    key_index = key_index + 1
                end
            end
        end
        if key == 13 then --enter
            if down then
                execute_black(key_index,title_index)
            end
        end
    end
end