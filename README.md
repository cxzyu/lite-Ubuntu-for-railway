# Railway · Ubuntu 24.04 轻量系统（带公网访问）

在 Railway 上跑一个**最小化 Ubuntu 24.04 环境**，并且能从公网用浏览器直接进去敲命令。

无桌面、无 SSH，全部操作走网页终端。

## 这一版改了什么

上一版只有 `sleep infinity`，没有程序监听端口，所以 Railway 不给域名，你也连不进去。

这一版装了 **ttyd**（网页版终端），它会监听端口并对外提供一个网页，你在浏览器里打开就能看到完整的 bash 命令行。

- ttyd 本身也是常驻进程，替掉了原来的 `sleep`，容器不会退出
- 因为是 HTTP 服务，Railway 会**自动分配公网域名**，不用手动配 TCP Proxy
- 带账号密码基础认证，公网暴露 shell 不至于裸奔

## 文件说明

| 文件 | 作用 |
| --- | --- |
| `Dockerfile` | 基于 `ubuntu:24.04`，最小化安装 curl / wget / git / ttyd 等 |
| `railway.json` | 指定 Dockerfile 构建 + 端口健康检查策略 |

## 部署步骤

1. GitHub 新建空仓库，把本目录所有文件推上去。
2. Railway → **New Project** → **Deploy from GitHub repo**，选中该仓库。
3. 部署完成后进入服务 → **Settings → Networking → Public Networking**，点 **Generate Domain**，Railway 会给出一个 `xxx.up.railway.app` 域名。
4. 浏览器打开这个域名，输入账号密码即可进入命令行。

## 必须做的一件事：改密码

Dockerfile 里的默认密码是 `changeme`，**公网暴露 shell 用默认密码等于送人头**。

在 Railway 服务的 **Variables** 面板加两个变量：

```
TTYD_USER = 你自己起的用户名
TTYD_PASS = 一个强密码
```

保存后会自动重新部署，新密码生效。

⚠️ 顺带提醒：这个终端是 root 权限，域名别随便发给别人。

## 费用和之前一样低

ttyd 非常轻，跟原来的 `sleep` 差不多：

- CPU 空闲时接近 $0
- 常驻内存约 50–100 MB

按 Railway 官方价（2026-09，内存 $10/GB/月、CPU $20/vCPU/月）折算，用量约 **$0.5–1/月**，Hobby 计划 $5 额度完全盖得住，**每月实际就是 $5 订阅费**。

只有你在里面跑吃内存的东西，费用才会涨上去 —— 这时候去看 Railway 面板的内存曲线就知道。

## 注意事项

- **命令会执行，但重启就丢**：容器是临时的，你在里面装的软件、建的文件，重新部署后全部重置。想永久保存就挂个 Volume（Settings → Volumes，挂载路径比如 `/data`），单独计费 $0.15/GB/月。
- **网页终端不能后台跑长任务**：关掉浏览器标签，里面跑的进程可能中断。要跑长时间任务，用 `nohup xxx &` 或装 `tmux`。
- **防超支**：Project Settings → Usage 里可以设用量硬上限（最低 $10），到点自动停机，75% / 90% 时邮件提醒。

## 可选扩展

- **跑定时任务**：apt 装 `cron`，但需要改 CMD 让 cron 和 ttyd 一起跑。
- **装更多工具**：在 Dockerfile 的 apt 列表里加，重新部署即可。
- **想换成自己的服务**：把 Dockerfile 最后的 `CMD` 换掉就行，比如 `CMD ["python3", "app.py"]`。
