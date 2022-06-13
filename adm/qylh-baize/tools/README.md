## 搭建运维机

1. 数据盘分区、挂载

```sh
```

2. 安装 svn
3. 迁出运维工具脚本
4. 安装 Erlang(21.2)
5. 安装 Go(1.13.8+)
6. 安装 Ansible

## 搭建后台

1. 数据盘分区、挂载
2. 安装 svn
3. 迁出后台代码
4. lnmp安装php,mysql,php memcached扩展
5. 安装memcached
6. 修改mysql目录

泰文: `lPN%9c3Ay9Pv`
英文: `esTRKi57*$B3`
繁体: `8ce&4YRv&dq!`
韩文: `46m%iz738Gc0`
一格: `ImdizP5dh7^9`
君海: `F6l0Dg2e*X@C`

君海海外ios审核后台: `BwQ$21#swA1c`

 ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'BwQ$21#swA1c';

GRANT ALL PRIVILEGES ON *.* TO 'xw_admin'@'%' IDENTIFIED BY '8ce&4YRv&dq!' WITH GRANT OPTION;

配置 .env

APP_DEBUG=true
APP_ENV=produce
TIMEZONE=XXX
DB_DATABASE=xw_admin
DB_DATABASE_LOGS=xw_logs
DB_USERNAME=xw_admin
DB_PASSWORD=ec44d04a9d

## 搭建cdn

root Ld@9X4%4YnFcgE&#G3


- 开发机 : `192.168.31.100`
- 运维机 : `47.106.78.222`

所有脚本都放在 `/data/tools` 目录下，操作时，先进入该目录。

注意：中心服必须先于跨服启动，否则跨服会启动失败。

---

## 签出项目

```bash
sh xrelx checkout Branch Target WorkDir
```

参数说明：

- `Branch` : 所要签出的分支，有效值为 `develop`, `release`, `banhao`
- `Target` : 有效值为 `server`, `client`, `both`
- `WorkDir` : 签出到哪个目录

---

## 发布版本

```bash
# 1. 发布分支(开发机)
sh xrelx branch
# 2. 发布客户端(开发机)
sh xrelx publish Version

# 3. 发布服务端(运维机)
sh xrelx publish Version
```

参数说明：

- `Version` : 新的版本号，如 `1.1`, `2.0`

---

## 版本升级

### 客户端

客户端升级流程：

1. 客户端打包并上传至cdn服务器(开发机)
2. 升级版本(运维机)

```bash
# 1. 打包并上传(开发机)
sh xrelx pack client -u
# 2. 升级版本(运维机)
sh xops upgrade client OSType Center
```

参数说明：

- `OSType` : 手机操作系统 android / ios
- `Center` : 中心服名称(查看后台)

### 服务端

服务端升级流程：

1. 服务端打包(运维机)
2. 上传包到各服务器上(运维机)
3. 升级版本(运维机)

```bash
# 1. 打包
sh xrelx pack server
# 2. 上传
sh xops send release Center
# 3. 升级版本
sh xops upgrade server Center
```

参数说明：

- `Center` : 中心服名称(查看后台)

---

## 热更新

### 客户端

客户端热更流程：

1. 客户端打包并上传至cdn服务器(开发机)
2. 热更(运维机)

```bash
# 1. 打包并上传(开发机)
sh xrelx patch client -u
# 2. 热更
sh xops update client OSType Center
```

参数说明：

- `OSType` : 手机操作系统 android / ios
- `Center` : 中心服名称(查看后台)

### 服务端

服务端热更流程：

1. 将需要更新的模块写入 `etc/update.txt` 文件(运维机)
2. 打包(运维机)
3. 上传包到各服务器上(运维机)
4. 热更(运维机)

```bash
# 1. 编辑更新模块(运维机)
vi /data/release/server/etc/update.txt
# 2. 打包(运维机)
sh xrelx patch server
# 3. 上传(运维机)
sh xops send patch Center
# 4. 热更(运维机)
sh xops update server Center
```

参数说明：

- `Center` : 中心服名称(查看后台)


---


## 装机

```bash
sh xops install Machines
```

参数说明：

- `Machines` : 服务器id(查看后台)，如 1 | 1,2 | 1-2 | 1-2,3

---

## 部署

### 部署中心服

```bash
sh xops deploy center Center
```

参数说明：

- `Center` : 中心服名称(查看后台)


### 部署跨服

```bash
sh xops deploy cross Crosses
```

参数说明：

- `Crosses` : 跨服id(查看后台)，如 1 | 1,2 | 1-2 | 1-2,3

### 部署游戏服

```bash
sh xops deploy server Platform Servers
```

参数说明：

- `Platform` : 平台名称(查看后台)
- `Servers` : 游戏服id(查看后台)，如 1 | 1,2 | 1-2 | 1-2,3

---

## 更新sys.config

```bash
sh xops config Center
```

更新所有连接到中心服 `Center` 的中心服、跨服和游戏服的 `sys.config` 配置。

参数说明：

- `Center` : 中心服名称(查看后台)




use xw_admin;
delete from role_infos where sid=2600001;
delete from act_stats where sid=2600001;
delete from role_statistics where sid=2600001;
delete from role_devices where sid=2600001;
delete from gold_retains where sid=2600001;

use xw_logs;
delete from coin_logs_2020_3 where sid=2600001 limit 100000;
delete from gold_logs_2020_3 where sid=2600001 limit 100000;
delete from item_logs_2020_3 where sid=2600001 limit 100000;
delete from task_logs_2020_3 where sid=2600001 limit 100000;
delete from equip_logs_2020_3 where sid=2600001;
delete from chat_logs_2020_3 where sid=2600001;
delete from mail_logs_2020_3 where sid=2600001;
delete from dunge_logs_2020_3 where sid=2600001;
delete from play_logs_2020_3 where sid = 2600001;
delete from level_logs_2020_1 where sid=2600001;
delete from mall_logs_2020_1 where sid=2600001;
delete from online_logs_2020_1 where sid=2600001;
delete from login_logout_logs_2020_1 where sid=2600001;
delete from boss_logs_2020_1 where sid=2600001;
delete from online_time_logs_2020_1 where sid=2600001;
delete from market_logs_2020_1 where sid=2600001;







韦超锦 13:01:00
新的高防ip：
170.33.9.170

新增高防回源ip：2020.03.30
170.33.88.0/24
170.33.92.0/24
170.33.93.0/24
170.33.90.0/24
8.208.75.0/26

韦超锦 13:01:40
即是原来的170.33.8.220 需改成 170.33.9.170





1.iftop -P能够查询到连接的ip和端口号
2.进入服务器，lsof -i:端口号，查看到进程pid
3.ps aux|grep pid查询到具体的进程


xingwan@1875924541378683.onaliyun.com
qiZBP5NX&L2pw|}3foa(LCTvmzlSUqL1

