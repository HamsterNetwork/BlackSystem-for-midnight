local log_file_name = "blacklist_"..os.date("%d_%m_%Y_%H_%M_%S")..".log"
local json = require("lib/json")
local files = require("lib/files")
local path = fs.get_dir_product() .. "blacksystem\\"
local config_path = fs.get_dir_product().."config/blacksystem/config.json"
local config = json.decode(files.load_file(config_path))
local language = json.decode(files.load_file(fs.get_dir_product().."language/blacksystem/"..config["language"]..".json"))
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
                if config["notify"] then
                    utils.notify(string.format(language["kicktitle"],player.get_name(ply)),string.format(language["kickreson"],reason),10,4)
                end
                if config["nofify_chat"] then
                    utils.send_chat(string.format(language["kicktitle"],player.get_name(ply))..string.format("  "..language["kickreson"],reason), false)
                end
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
    blacklist.blackwords = split(files.load_file(path..config["file_name"]["blackwords"]),"\n")
    blacklist.whitewords = split(files.load_file(path..config["file_name"]["whitewords"]),"\n")
    blacklist.blackplayername = split(files.load_file(path..config["file_name"]["blackplayername"]),"\n")
    blacklist.blackplayer["广告机"] = split(files.load_file(path..config["file_name"]["blackplayer"]["广告机"]),"\n")
    blacklist.blackplayer["custom"] = split(files.load_file(path..config["file_name"]["blackplayer"]["custom"]),"\n")
    blacklist.whiteplayer = split(files.load_file(path..config["file_name"]["whiteplayer"]),"\n")
    config = json.decode(files.load_file(config_path))
    language = json.decode(files.load_file(fs.get_dir_product().."language/blacksystem/"..config["language"]..".json"))
end
refresh_cfg()
function kick_player(ply)
    refresh_cfg()
    blacklist.kickplayerbythis(blacklist.blackplayer["custom"],tostring(player.get_rid(ply)),language["blacklist"],ply)
    blacklist.kickplayerbythis(blacklist.blackplayer["广告机"],tostring(player.get_rid(ply)),"广告机",ply)
    blacklist.kickplayerbythis(blacklist.blackplayername,player.get_name(ply),language["blackname"],ply)
    return
end
local function ToCol(col)
	return math.floor(col.x * 255), math.floor(col.y * 255), math.floor(col.z * 255), math.floor(col.w * 255)
end

function OnChatMsg(ply, text)
    if not config["enable"] then return end
    refresh_cfg()
    for x = 1,#blacklist.whiteplayer do
        if blacklist.whiteplayer[x] == tostring(player.get_rid(ply)) then
            if config["notify"] then
                utils.notify(string.format(language["kicktitle"],player.get_name(ply)),language["whitelist"],10,4)
            end
        else
            for i = 1,#blacklist.blackwords do 
                if string.find(text, blacklist.blackwords[i]) ~= nil then
                    for y = 1,#blacklist.whitewords do
                        if string.find(text, blacklist.whitewords[y]) == nil then
                            if not player.is_local(ply) then
                                if config["clear_chat"] then
                                    utils.send_chat("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", false)
                                end
                                player.kick(ply)
                                player.kick_idm(ply)
                                player.kick_brute(ply)
                                if config["crash"] then
                                    player.crash_himiko_start(ply)
                                    player.crash_izuku_start(ply)
                                end
                                if config["notify"] then
                                    utils.notify(string.format(language["kicktitle"],player.get_name(ply)),string.format(language["kicksentblackword"],blacklist.blackwords[i]),10,4)
                                end
                                if config["nofify_chat"] then
                                    utils.send_chat(string.format(language["kicktitle"],player.get_name(ply))..string.format("  "..language["kicksentblackword"],blacklist.blackwords[i]), false)
                                end
                                if config["output_log"] then
                                    blacklist.outputkicklog(ply,blacklist.blackwords[i],text)
                                end
                                return
                            end
                        else
                            if config["notify"] then
                                utils.notify(string.format(language["kicktitle"],player.get_name(ply)),language["nobaleful"],10,4)
                            end
                            return
                        end
                    end
                end
            end
        end
    end
end
function kick_player_a()
    if not config["enable"] then return end
    local players = player.get_hosts_queue()
    for i=1,#players do
        kick_player(player.get_index(players[i]))
    end
end

function OnInit()
    if config["notify"] then
        utils.notify(language["title"],language["loaded"],19,1)
    end
    if config["output_log"] then
        blacklist.outputlog("加载脚本完毕")
    end
end
function OnDone()
    if config["notify"] then
        utils.notify(language["title"],language["unloaded"],19,1)
    end
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
"Crash",
"Bounty",
"Teleport"
}
local function draw_rect(x,y,x1,y1,r, g, b,a,size)
    draw.set_color(0,r, g, b,a)
    for i = 1, size do
        draw.rect(x+0.1*i, y+0.1*i, x1-0.1*i, y1-0.1*i)
    end
end
function execute_black()
    local players = player.get_hosts_queue()
    if player.is_local(players[key_index]) then
        if config["notify"] then
            utils.notify(language["title"],language["cantaddlocal"],16,2)
        end
        return
    end
    if title_index == 2 then
        if files.load_file(path..config["file_name"]["blackplayer"]["custom"]) == "" then
            if string.find(files.load_file(path..config["file_name"]["blackplayer"]["custom"]),tostring(player.get_rid(players[key_index]))) == nil then
                files.write_file(path..config["file_name"]["blackplayer"]["custom"], "\n"..tostring(player.get_rid(players[key_index])))
                if config["notify"] then
                    utils.notify(language["title"],language["blackadded"],16,1)
                end
            else
                if config["notify"] then
                    utils.notify(language["title"],language["blackexists"],16,2)
                end
            end
        else
            if string.find(files.load_file(path..config["file_name"]["blackplayer"]["custom"]),tostring(player.get_rid(players[key_index]))) == nil then
                files.append_file(path..config["file_name"]["blackplayer"]["custom"], "\n"..tostring(player.get_rid(players[key_index])))
                if config["notify"] then
                    utils.notify(language["title"],language["blackadded"],16,1)
                end
            else
                if config["notify"] then
                    utils.notify(language["title"],language["blackexists"],16,2)
                end
            end
        end
    end
    if title_index == 3 then
        if files.load_file(path..config["file_name"]["whiteplayer"]) == "" then
            
            if string.find(files.load_file(path..config["file_name"]["whiteplayer"]),tostring(player.get_rid(players[key_index]))) == nil then
                files.write_file(path..config["file_name"]["whiteplayer"], "\n"..tostring(player.get_rid(players[key_index])))
                if config["notify"] then
                    utils.notify(language["title"],language["whiteadded"],16,1)
                end
            else
                if config["notify"] then
                    utils.notify(language["title"],language["whiteexists"],16,2)
                end
            end
        else
            if string.find(files.load_file(path..config["file_name"]["whiteplayer"]),tostring(tostring(player.get_rid(players[key_index])))) == nil then
                files.append_file(path..config["file_name"]["whiteplayer"], "\n"..tostring(player.get_rid(players[key_index])))
                if config["notify"] then
                    utils.notify(language["title"],language["whiteadded"],16,1)
                end
            else
                if config["notify"] then
                    utils.notify(language["title"],language["whiteexists"],16,2)
                end
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
    if title_index == 6 then
        player.set_bounty(players[key_index], 9000, true)
    end
    if title_index == 7 then
        local pos = Vector3(0, 0, 0)
        if player.get_coordinates(player.get_index(players[key_index]), pos) then
            utils.teleport(player.id(), pos.x, pos.y, pos.z)
        end
    end
end
local time = system.time() + 5
function OnFrame()
    if time <= system.time() then
        kick_player_a()
        time = system.time() + 1
    end
    config = json.decode(files.load_file(config_path))
    if not config["enable"] then return end
    if menu.is_menu_opened() then
        local sub_r, sub_g, sub_b, sub_a = ToCol(menu.get_color(menu_color.ChildBg))
        local r, g, b, a = ToCol(menu.get_color(menu_color.WindowBg))
        local text_r, text_g, text_b, text_a = ToCol(menu.get_widget_color(menu_widget_color.Text))
        local textactive_r, textactive_g, textactive_b, textactive_a = ToCol(menu.get_color(menu_color.Text))
        local players = player.get_hosts_queue()
        local x = 0
        local y = 0
        local long_size = 0
        local text_size = draw.get_text_size(player.get_name(player.index()))
        if key_index > #players then
            key_index = #players
        end
        if key_index < 1 then
            key_index = 1
        end
        for i=1,#players do
            ply = players[i]
            
            if long_size < draw.get_text_size_x(player.get_name(ply)) then
                long_size = draw.get_text_size_x(player.get_name(ply))
            end
            if long_size < draw.get_text_size_x("Online:"..#players.."/30") then
                long_size = draw.get_text_size_x("Online:"..#players.."/30")
            end
            
        end
        
        for i=1,#players do
            ply = players[i]
            if player.get_name(ply) == player.get_name(players[key_index]) then
                target_text_size = draw.get_text_size(player.get_name(ply))
                draw.set_color(0,r, g, b, a)
                draw.rect_filled(menu.get_main_menu_pos().x+menu.get_main_menu_size().x, menu.get_main_menu_pos().y, menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size+10, menu.get_main_menu_pos().y+target_text_size.y)
                draw.rect_filled(menu.get_main_menu_pos().x+menu.get_main_menu_size().x, menu.get_main_menu_pos().y+target_text_size.y, menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size+10, menu.get_main_menu_pos().y+target_text_size.y*2)
                draw.set_color(0, textactive_r, textactive_g, textactive_b, textactive_a)
                oneline_text = "Online:"..#players.."/30"
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size/2-draw.get_text_size_x(oneline_text)/2, menu.get_main_menu_pos().y, oneline_text)
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size/2-draw.get_text_size_x(oneline_text)/2, menu.get_main_menu_pos().y, oneline_text)
                title_text = titles[title_index].."("..title_index.."/"..#titles..")"
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size/2-draw.get_text_size_x(title_text)/2, menu.get_main_menu_pos().y+target_text_size.y, title_text)
                draw.text(menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size/2-draw.get_text_size_x(title_text)/2, menu.get_main_menu_pos().y+target_text_size.y, title_text)
                draw_rect(menu.get_main_menu_pos().x+menu.get_main_menu_size().x, menu.get_main_menu_pos().y+target_text_size.y+target_text_size.y*key_index, menu.get_main_menu_pos().x+menu.get_main_menu_size().x+long_size+10, menu.get_main_menu_pos().y+target_text_size.y+target_text_size.y*(key_index+1),text_r, text_g, text_b, text_a,15)
                
            end
            if menu.get_main_menu_pos().y+text_size.y*x < menu.get_main_menu_pos().y+menu.get_main_menu_size().y then

                draw.set_color(0, textactive_r, textactive_g, textactive_b, textactive_a)
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