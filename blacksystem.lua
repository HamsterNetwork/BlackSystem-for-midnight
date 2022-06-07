local blacklist = {
    kickplayerbythis = function(grl,this,reason)
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
    outputlog = function(ply,word,text)
        if fs.file_load_txt("./blacklog.txt") == "" then
            if string.find(fs.file_load_txt("./blacklog.txt"),"Rid: "..player.get_rid(ply)) == nil then
                fs.file_write("./blacklog.txt", "Rid: "..player.get_rid(ply).."\n原因: 发出违禁词("..word..")\n内容:\n"..text)
            end
        else
            if string.find(fs.file_load_txt("./blacklog.txt"),"Rid: "..player.get_rid(ply)) == nil then
                fs.file_append("./blacklog.txt", "\n----------------------------------------------\nRid: "..player.get_rid(ply).."\n原因: 发出违禁词("..word..")\n内容:\n"..text)
            end
        end
    end,
    blackwords = {
        ".cn",
        ".com",
        ".net",
        ".xyz",
        ".top",
        ".me",
        "刷金",
        "淘宝搜索",
        "代刷",
        "辅助",
        "Q群",
        "qq群",
        "元一亿",
        "毛一亿",
        "块一亿",
        "淘宝",
        "有妹子",
        "手工",
        "解封",
        "另售外挂-",
        "下单",
        "全网最低",
        "加QQ群",
        "萌新加群",
        "不要挂",
        "地堡解锁",
        "恶搞",
        "恶搞套笼",
        "元=一亿",
        "微信QQ同号",
        "自瞄",
        "福利",
        "保底",
        "有妹妹",
        "带上岛",
        "gta5kk.com!",
        "gta5",
        "GTA5",
        "单场百万",
        "GTA带上岛",
        "另售",
        "有抽奖",
        "加群领取",
        "麻豆",
        "传媒",
        "蜜桃星空",
        "买挂加群",
        "AV",
        "欧美大片",
        "美女荷官",
        "在线观看",
        "处男",
        "强奸",
        "孤儿",
        "幼女",
        "自慰",
        "挂逼",
        "强奸",
        "高级VIP",
        "线上充值",
        "价格优惠",
        "不过百",
        "加入我们",
        "修仙联盟",
        "加我免费",
        "网站H778",
        "调教人妻",
        "充值观看",
        "科技优惠",
        "2元",
        "一亿",
        "萌新加",
        "不要挂",
        "免费带岛",
        "日本",
        "性爱",
        "官方网站",
        "滚",
        "再见",
        "QQ搜索",
        "妹子多",
        "加我送",
        "挂狗",
        "百分百",
        "拍照保留",
        "截图保存",
        "截图保留",
        "开挂勿进",
        "萌新加群",
        "萌新组队",
        "限时限量",
        "嘎嘎强",
        "挂壁死妈",
        "挂壁",
        "死妈",
        "nmsl",
        "处女",
        "低价科技",
        "乱伦",
    },
    whitewords = {
        "bilibili.com",
        "github.com",
        "baidu.com",
        "gov.cn",
        "fearless.icu",
        "google.com",
    },
    blackplayername = {
        "lIlIIllIlIIIlII",
        "HUKL",
    },
    blackplayer = {
        ["广告机"] = {
            203500197,
            170272593,
            210534168,
            132982415,
            66109167,
            149899256,
            169788782,
            116553499,
            139093087,
            144934559,
            180651931,
            133509737,
            120814188,
            187672143,
            194827164,
            130896213,
            204047921,
            176831661,
            113317643,
            175041085,
            191004280,
            145495965,
            139210010,
            91548043,
            200718736,
            140717037,
            144804788,
            147933569,
            131818383,
            133396503,
            120423228,
            177739403,
            133626303,
            93520453,
            189352818,
            127658299,
            186085225,
            183555860,
            133651559,
            143058862,
            183556277,
            147899783,
            172910942,
            109089813,
            142815147,
            116203599,
            173849291,
            129890433,
            203330080,
            114059319,
            135639601,
            194818135,
            186809768,
            210184518,
            173956091,
            194398616,
            196427889,
            135906903,
            186728768,
            184503061,
            205356220,
            191871456,
            183556440,
            186085429,
            145540578,
            150807458,
            195765502,
            174162955,
            149581094,
            178899979,
            125146841,
            113741221,
            204807626,
            205589715,
        },
        ["狗叫"] = {
        
        }
    },
    whiteplayer = {
        210152382,
        129879190,
        156630607,
    }
}


function OnChatMsg(ply, text)
    for x = 1,#blacklist.whiteplayer do
        if blacklist.whiteplayer[x] == player.get_rid(ply) then
            utils.notify("踢出玩家 "..player.get_name(ply),"白名单",10,4)
        else
            for i = 1,#blacklist.blackwords do
                if string.find(text, blacklist.blackwords[i]) ~= nil then
                    for y = 1,#blacklist.whitewords do
                        if string.find(text, blacklist.whitewords[y]) == nil then
                            if not player.is_local(ply) then
                                player.kick(ply)
                                player.kick_idm(ply)
                                player.kick_brute(ply)
                                utils.notify("踢出玩家 "..player.get_name(ply),"踢出原因: 发出违禁词("..blacklist.blackwords[i]..")",10,4)
                                utils.send_chat("踢出玩家: "..player.get_name(ply).."  踢出原因: 发出违禁词("..blacklist.blackwords[i]..")", false)
                                blacklist.outputlog(ply,blacklist.blackwords[i],text)
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
    blacklist.kickplayerbythis(blacklist.blackplayer["广告机"],player.get_rid(ply),"广告机")
    blacklist.kickplayerbythis(blacklist.blackplayername,player.get_name(ply),"黑名单名字")
end
function OnScriptEvent(ply, event, args)
    blacklist.kickplayerbythis(blacklist.blackplayer["广告机"],player.get_rid(ply),"广告机")
    blacklist.kickplayerbythis(blacklist.blackplayername,player.get_name(ply),"黑名单名字")
end
function OnNetworkEvent(ply, event, buf)
    blacklist.kickplayerbythis(blacklist.blackplayer["广告机"],player.get_rid(ply),"广告机")
    blacklist.kickplayerbythis(blacklist.blackplayername,player.get_name(ply),"黑名单名字")
end
function OnInit()
    utils.notify("黑名单","加载完毕",19,1)
end
function OnDone()
    utils.notify("黑名单","卸载完毕",19,1)
end
