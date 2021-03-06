% Automatically generated, do not edit
-module(cfg_mail).

-compile([export_all]).
-compile(nowarn_export_all).

find(1113001) -> {"市场购买成功", "恭喜您成功购买物品，以下是您购买获得的物品"};
find(1113002) -> {"挂售成功", "恭喜您成功出售物品，以下是您出售获得的钻石"};
find(1113003) -> {"指定交易失败", "您的物品指定失败，对方已拒绝了您的请求，以下是退还给您的物品"};
find(1113004) -> {"挂售超时", "市场挂售超时，挂售物品回退"};
find(1400001) -> {"帮派公告修改", ""};
find(1602001) -> {"公会争霸胜利奖励", "亲爱的玩家，您的公会在本场公会争霸中齐心协力击败了【~ts】公会，您获得的奖励为："};
find(1602002) -> {"公会争霸失败奖励", "亲爱的玩家，您的公会在本场公会争霸中不幸败给了【~ts】公会，您获得的奖励为："};
find(1602003) -> {"公会争霸个人奖励", "亲爱的玩家，您在本次公会争霸中占领~w水晶，击败~w玩家，排名~w，获得的奖励为："};
find(1603001) -> {"乱斗战场结算奖励", "您在此回合乱斗战场中，获得~w积分，排名第~w，获得以下奖励："};
find(1603002) -> {"乱斗战场总排名奖励", "您在乱斗战场中，总获得~w积分，排名第~w，获得以下奖励："};
find(1604001) -> {"糖果屋结算奖励", "亲爱的玩家，你在本场甜美糖果屋中人气~w，排名第~w，获得的奖励如下："};
find(1000000) -> {"活动奖励补发", "这是您在【~ts】活动中未领取的奖励，请查收"};
find(1000001) -> {"~ts奖励发放", "恭喜您在【~ts】活动，名次达到~w，以下是您的奖励，请查收"};
find(1000002) -> {"~ts获取超上限", "今日获得的钻石或绑钻已超上限
超出的部分：【~ts】*~w
将于明天发放，请注意查收邮件！
提醒：提升贵族等级会提高您的货币获取上限"};
find(1000003) -> {"~ts超上限补发", "以下是您于昨日获取超上限的部分，请查收"};
find(1000004) -> {"道具补发", "您的背包已满，以下是您通过【~ts】获得的道具"};
find(1605001) -> {"公会领地答题奖励", "亲爱的玩家，您在本次公会领地答题中排名~w，获得的奖励为："};
find(1134001) -> {"求婚失败", "【~ts】拒绝你的求婚，退还钻石。"};
find(1134002) -> {"离婚成功", "您已成功与【~ts】离婚，离婚发起者为【~ts】，结婚戒指变回单身戒指，结婚属性失效，重新结婚后生效"};
find(1135001) -> {"预约成功", "恭喜你已成功预约【~ts】的婚礼，请您携伴侣准时参加，预约婚礼的奖励已发放邮件，请查收。温馨提示：若婚礼期间角色未登录，系统也会自动进行哦。千万不要错过了哟！"};
find(1135002) -> {"婚礼举办通知", "您受邀参加【~ts】与【~ts】于【~ts】的婚礼，请您准时参加！附件为婚礼时使用的烟花，使用后可增加婚礼热度，获得海量奖励。馨提示：若婚礼期间角色未登陆，系统也会自动进行，千万不要错过哦"};
find(1135003) -> {"婚礼热度奖励", "以下是您在【~ts】与【~ts】的婚礼中未领取的婚礼热度奖励，请查收"};
find(1135004) -> {"婚礼重新预约通知", "因系统维护导致婚礼延期，已补偿您预约次数，请重新预约"};
find(1000005) -> {"系统通知", "亲爱的玩家，检测到您有使用加速器的行为！
游戏提倡公平公正的和谐游戏，使用加速器等行为将可能导致封号！"};
find(1111002) -> {"魂卡寻宝", "因为魂卡背包已满，您此次【~ts】的奖励如下"};
find(1203005) -> {"魔法塔通关", "因为魂卡背包已满，您此次【~ts】的奖励如下"};
find(1400002) -> {"申请公会失败通知", "很遗憾！【~ts】公会拒绝了你的加入申请"};
find(1400003) -> {"加入公会通知", "亲爱的玩家，恭喜您加入【~ts】公会！让我们共建强大和谐的公会，一起玩耍吧！"};
find(1400004) -> {"公会踢出通知", "很遗憾！你已经被踢出【~ts】公会！"};
find(1400005) -> {"职位变更通知", "你的职位变更为【~ts】。"};
find(1400006) -> {"会长转让通知", "因为您超过48小时没有上线，现将公会会长转让给【~ts】玩家。"};
find(1400007) -> {"会长转让通知", "因为会长【~ts】超过48小时没有上线，公会会长自动转让给【~ts】玩家。"};
find(1602006) -> {"公会争霸活动预告", "公会争霸活动将于今晚【~ts】开启，请所有参赛公会争霸成员做好参加活动的准备！！！
您所在的公会：【~ts】，已被分组到：【~ts】赛区。（可到公会争霸界面查看本公会所在赛区）"};
find(1602007) -> {"公会争霸第二轮预告", "内容：公会争霸活动第二轮将于今晚【~ts】开启，请所有参赛公会争霸成员做好参加活动的准备！！！
您所在的公会：【~ts】，已被分组到：【~ts】赛区。（可到公会争霸界面查看本公会所在赛区）"};
find(1602008) -> {"公会晋级通知书", "通过大家不懈努力，本公会晋级成功，已经成为“【~ts】”公会"};
find(1602009) -> {"公会降级通知书", "公会实力还需提升，本公会被降级为“【~ts】”公会"};
find(1602010) -> {"公会争霸总冠军", "通过大家同心协力，本公会勇夺公会争霸总冠军。记得去主宰神殿领取每日奖励哦。（每日0点刷新奖励）"};
find(1602004) -> {"分配奖励", "公会连胜奖励，会长已分配给你。"};
find(1602005) -> {"终结连胜奖励", "您的公会勇夺公会争霸总冠军，终结了总冠军连胜，获得以下分配奖励"};
find(1602011) -> {"主宰神殿会长奖励", "主宰神殿会长奖励"};
find(1605002) -> {"巅峰1v1排名奖励", "勇者必胜！您在上周的巅峰1v1中一路高跟猛进，段位为：【~ts】，排行上位居第~w名。发此奖励，以表祝贺！"};
find(1605003) -> {"巅峰1v1排名奖励", "勇者必胜！您在上周的巅峰1v1中一路高跟猛进，段位为：【~ts】，排行未上榜。发此奖励，以表祝贺！"};
find(1100001) -> {"好友改名通知", "您的好友【~ts】已更换新昵称：【~ts】，快去撩起来吧！"};
find(1606001) -> {"勇者圣坛排名奖励", "勇闯勇者圣坛！恭喜您在本次活动获得了~w积分，排名第~w名，如下发的是排名奖励。"};
find(1606002) -> {"勇者圣坛层数奖励", "勇闯勇者圣坛！恭喜您达到~w层，获得如下奖励。"};
find(1000006) -> {"守卫公会结算奖励", "您的公会成功守护了公会骑士团！根据您在活动中的表现，在此补发奖励。下次也要努力哦！"};
find(1000007) -> {"守卫公会结算奖励", "您的公会没能守护光之领主，根据您在活动中的表现，在此补发奖励。下次要更加努力哦！"};
find(1132001) -> {"竞技场被击败", "很遗憾！您在竞技场中被【~ts】击败，竞技场名次变为~w。"};
find(1000008) -> {"功能开启通知", "恭喜您达到【极地护送】开启等级，每天16:00-16:30,21:30-22:00期间完成【极地护送】可获得双倍奖励哦！"};
find(1000009) -> {"功能开启通知", "恭喜您达到【公会战】开启等级，每周日晚上开启公会战，称霸全服的机会来了，快来参与吧！"};
find(1000010) -> {"功能开启通知", "恭喜您达到【竞技场】开启等级，大量活动等您参与，还可获得丰厚的奖励哦！"};
find(1606003) -> {"子女点赞排名奖励", "亲爱的玩家，您在本次点赞榜中排名~w，获得的奖励为："};
find(1204001) -> {"世界首领参与奖励", "您在击杀世界首领【~ts】的过程中，输出排名第~w名，获得奖励如下！"};
find(1607001) -> {"报名成功", "恭喜您，报名成功，限时活动【钻石擂台】参赛资格将于活动前10分钟公布，请注意查看！"};
find(1607002) -> {"未进入海选赛补偿", "很遗憾，你未能获得海选赛参赛资格，将退还报名费用！"};
find(1607003) -> {"进入海选赛提醒", "恭喜您，已经获得海选赛参赛资格，【钻石擂台】将于10分钟后开始，18:57可提前进入预备场景，做好战斗准备。"};
find(1607004) -> {"天地争霸活动提醒", "恭喜您，积分排名名列前茅，获得天地争霸参赛资格，请提前做好准备哦！"};
find(1607005) -> {"天地争霸排名结算", "恭喜您，在钻石擂台天地争霸中排名【~w】名，获得以下奖励。"};
find(1607006) -> {"钻石擂台奖励", "钻石擂台奖励"};
find(1607007) -> {"竞猜成功", "恭喜您，竞猜成功！"};
find(1607008) -> {"竞猜失败", "恭喜您，竞猜失败！"};
find(1607009) -> {"晋级天榜奖励", "恭喜您，获得晋级天榜奖励！"};
find(1607010) -> {"晋级地榜奖励", "恭喜您，获得晋级地榜奖励！"};
find(1608001) -> {"跨服首领破盾奖励", "恭喜你在击杀跨服首领【~ts】的过程中，幸运降临，获得破盾奖励"};
find(1608002) -> {"跨服首领参与奖励", "恭喜你在击杀跨服首领【~ts】的过程中，获得参与奖励如下！"};
find(1608003) -> {"跨服首领排行奖励", "恭喜你在击杀跨服首领【~ts】的过程中，输出排名第~w名，荣获排名奖励"};
find(1608004) -> {"跨服首领宝箱奖励", "您开启了跨服首领【~ts】的宝箱，获得了丰厚奖励如下！"};
find(1609001) -> {"夺城战占领奖励", "恭喜您的公会在此轮夺城战中，占领了【~ts】城，获得奖励如下"};
find(1203001) -> {"【机甲竞速】奖励补发", "您在【机甲竞速】活动中排名第~w，以下给您补发的奖励，请查收"};
find(1700001) -> {"跨服云购", "恭喜勇士，您在跨服云购中获得了奖励，现已邮件发放，请接收"};
find(1000011) -> {"~ts奖励发放", "恭喜您在【~ts】（单服）活动，名次达到~w，以下是您的奖励，请查收"};
find(1000012) -> {"~ts奖励发放", "恭喜您在【~ts】（跨服）活动，名次达到~w，以下是您的奖励，请查收"};
find(1000013) -> {"个人名字补偿", "合服后您的名字与其他玩家的名字重复了，系统已自动为你更换名字，现在补偿您一张个人改名卡，请查收！"};
find(1000014) -> {"公会名字补偿", "合服后您所在公会的名字与其他公会的名字重复了，系统已自动为你的公会更换名字，现在补偿您一张公会改名卡，请查收！"};
find(1000015) -> {"跨服公会战预约开始", "跨服盟战预约开始了，所有盟主可以在周六3:00至周日3:00期间预约想要对战的仙盟，预约成功后，将在周日20:00与预约的仙盟进行对战"};
find(1000016) -> {"跨服公会战结算奖励", "您的公会在【跨服公会战】中,本轮成功战胜了敌对公会！根据您在活动中的表现，您获得以下奖励:"};
find(1000017) -> {"跨服公会战结算奖励", "您的公会在【跨服公会战】中,本轮被敌对公会击败！根据您在活动中的表现，您获得以下奖励:"};
find(1000018) -> {"跨服公会战月结算奖励", "您的公会在【跨服公会战】本月排行获得了第~w名，以下是您公会的奖励，请查收"};
find(1000019) -> {"第一轮公会战轮空", "由于您的公会在【跨服公会战】预约时未预约，因此您的公会本轮轮空，以下是您的轮空奖励，请查收"};
find(1000020) -> {"第二轮公会战轮空", "由于您的公会在【跨服公会战】预约时未被预约，因此您的公会第二轮公会战轮空，以下是您的轮空奖励，请查收"};
find(1000021) -> {"跨服公会战单回合胜利奖励", "您的公会在【跨服公会战】中,本轮成功战胜了敌对公会！根据您所在公会表现，您公会获得~w积分，其他奖励如下:"};
find(1000022) -> {"跨服公会战单回合失败奖励", "您的公会在【跨服公会战】中,本轮被敌对公会击败！根据您公会的表现，您公会获得~w积分，其他奖励如下:"};
find(1000023) -> {"合服补偿", "亲爱的玩家您好，由于合服之后主服开服天数小于20天，导致您不能正常进行跨服公会战，以下是给您补偿："};
find(1000024) -> {"跨月补偿", "亲爱的玩家您好，本周由于重新分配跨服，导致本周跨服公会战不能正常进行我们深感歉意，以下是本周不能参加公会战的补偿："};
find(_) -> undefined.

is_log(1113001) -> true;
is_log(1113002) -> true;
is_log(1113003) -> true;
is_log(1113004) -> true;
is_log(1400001) -> false;
is_log(1602001) -> true;
is_log(1602002) -> true;
is_log(1602003) -> true;
is_log(1603001) -> true;
is_log(1603002) -> true;
is_log(1604001) -> true;
is_log(1000000) -> true;
is_log(1000001) -> true;
is_log(1000002) -> true;
is_log(1000003) -> true;
is_log(1000004) -> true;
is_log(1605001) -> true;
is_log(1134001) -> true;
is_log(1134002) -> true;
is_log(1135001) -> true;
is_log(1135002) -> false;
is_log(1135003) -> true;
is_log(1135004) -> true;
is_log(1000005) -> false;
is_log(1111002) -> true;
is_log(1203005) -> true;
is_log(1400002) -> false;
is_log(1400003) -> false;
is_log(1400004) -> false;
is_log(1400005) -> false;
is_log(1400006) -> false;
is_log(1400007) -> false;
is_log(1602006) -> false;
is_log(1602007) -> false;
is_log(1602008) -> false;
is_log(1602009) -> false;
is_log(1602010) -> false;
is_log(1602004) -> true;
is_log(1602005) -> true;
is_log(1602011) -> true;
is_log(1605002) -> true;
is_log(1605003) -> true;
is_log(1100001) -> false;
is_log(1606001) -> true;
is_log(1606002) -> true;
is_log(1000006) -> true;
is_log(1000007) -> true;
is_log(1132001) -> true;
is_log(1000008) -> true;
is_log(1000009) -> true;
is_log(1000010) -> true;
is_log(1606003) -> true;
is_log(1204001) -> true;
is_log(1607001) -> true;
is_log(1607002) -> true;
is_log(1607003) -> true;
is_log(1607004) -> true;
is_log(1607005) -> true;
is_log(1607006) -> true;
is_log(1607007) -> true;
is_log(1607008) -> true;
is_log(1607009) -> true;
is_log(1607010) -> true;
is_log(1608001) -> true;
is_log(1608002) -> true;
is_log(1608003) -> true;
is_log(1608004) -> true;
is_log(1609001) -> true;
is_log(1203001) -> true;
is_log(1700001) -> true;
is_log(1000011) -> true;
is_log(1000012) -> true;
is_log(1000013) -> true;
is_log(1000014) -> true;
is_log(1000015) -> true;
is_log(1000016) -> true;
is_log(1000017) -> true;
is_log(1000018) -> true;
is_log(1000019) -> true;
is_log(1000020) -> true;
is_log(1000021) -> true;
is_log(1000022) -> true;
is_log(1000023) -> true;
is_log(1000024) -> true;
is_log(_) -> false.