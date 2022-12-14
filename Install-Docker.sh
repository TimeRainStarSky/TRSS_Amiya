#TRSS Amiya Docker 安装脚本 作者：时雨🌌星空
NAME=v1.0.0;VERSION=202301120
R="[1;31m" G="[1;32m" Y="[1;33m" C="[1;36m" B="[1;m" O="[m"
echo "$B——————————————————————————
$R TRSS$Y Amiya$G Docker$C Script$O
    $G$NAME$C ($VERSION)$O
$B——————————————————————————
     $G作者：$C时雨🌌星空$O

$Y- 正在检查环境$O
"
DIR="${DIR:-$HOME/TRSS_Amiya}"
CMD="${CMD:-tsai}"
CMDPATH="${CMDPATH:-/usr/local/bin}"
DKNAME="${DKNAME:-TRSS_Amiya}"
DKURL="${DKURL:-dockerproxy.com}"
abort(){ echo "
$R! $@$O";exit 1;}
mktmp(){ TMP="$DIR/tmp"&&rm -rf "$TMP"&&mkdir -p "$TMP"||abort "缓存目录创建失败";}
if type docker;then
  echo "
$G- Docker 已安装$O
"
elif type pacman &>/dev/null;then
  echo "
$Y- 正在使用 pacman 安装 Docker$O
"
  pacman -Syu --noconfirm --needed --overwrite "*" docker||abort "Docker 安装失败"
elif type apt &>/dev/null;then
  echo "
$Y- 正在使用 apt 安装 Docker$O
"
  apt update&&apt install -y docker.io||abort "Docker 安装失败"
else
  echo "
$Y- 正在使用 官方脚本 安装 Docker$O
"
  DOWNLOAD_URL="https://mirrors.ustc.edu.cn/docker-ce" bash <(curl -L get.docker.com)||abort "官方脚本 执行失败，请自行安装 Docker 后重试：https://docker.com"
fi
docker info||{ systemctl enable --now docker||service docker start&&docker info;}&&echo "
$G- Docker 已启动$O"||abort "Docker 启动失败"
abort_update(){ echo "
$R! $@$O";[ "$N" -lt 10 ]&&{ ((N++));download;}||abort "脚本下载失败，请检查网络，并尝试重新下载";}
download(){ case "$N" in
  2)SERVER="GitHub" URL="https://github.com/TimeRainStarSky/TRSS_Amiya/raw/main";;
  1)SERVER="Gitee" URL="https://gitee.com/TimeRainStarSky/TRSS_Amiya/raw/main";;
  3)SERVER="Agit" URL="https://agit.ai/TimeRainStarSky/TRSS_Amiya/raw/branch/main";;
  4)SERVER="Coding" URL="https://trss.coding.net/p/TRSS/d/Amiya/git/raw/main";;
  5)SERVER="GitLab" URL="https://gitlab.com/TimeRainStarSky/TRSS_Amiya/raw/main";;
  6)SERVER="GitCode" URL="https://gitcode.net/TimeRainStarSky1/TRSS_Amiya/raw/main";;
  7)Server="GitLink" URL="https://gitlink.org.cn/api/TimeRainStarSky/TRSS_Amiya/raw?ref=main&filepath=";;
  8)SERVER="JiHuLab" URL="https://jihulab.com/TimeRainStarSky/TRSS_Amiya/raw/main";;
  9)SERVER="Jsdelivr" URL="https://cdn.jsdelivr.net/gh/TimeRainStarSky/TRSS_Amiya@main";;
  10)SERVER="Bitbucket" URL="https://bitbucket.org/TimeRainStarSky/TRSS_Amiya/raw/main"
esac
echo "
  正在从 $SERVER 服务器 下载版本信息"
GETVER="$(geturl "$URL/version")"||abort_update "下载失败"
NEWVER="$(sed -n s/^version=//p<<<"$GETVER")"
NEWNAME="$(sed -n s/^name=//p<<<"$GETVER")"
NEWMD5="$(sed -n s/^md5=//p<<<"$GETVER")"
[ -n "$NEWVER" ]&&[ -n "$NEWNAME" ]&&[ -n "$NEWMD5" ]||abort_update "下载文件版本信息缺失"
echo "
$B  最新版本：$G$NEWNAME$C ($NEWVER)$O

  开始下载"
mkdir -vp "$DIR"
geturl "$URL/Main.sh">"$DIR/Main.sh"||abort_update "下载失败"
[ "$(md5sum "$DIR/Main.sh"|head -c 32)" = "$NEWMD5" ]||abort_update "下载文件校验错误"
echo "
$G- 脚本下载完成$O

$Y- 正在构建 Docker 容器$O
"
mktmp&&cd "$TMP"
case "$(uname -m)" in
  aarch64|arm64|armv8*|armv9*)echo 'Server = https://mirrors.ustc.edu.cn/archlinuxarm/$arch/$repo
Server = https://mirrors.bfsu.edu.cn/archlinuxarm/$arch/$repo
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/$arch/$repo
Server = https://mirrors.aliyun.com/archlinuxarm/$arch/$repo
Server = https://mirrors.163.com/archlinuxarm/$arch/$repo
Server = https://mirrors.tencent.com/archlinuxarm/$arch/$repo
Server = https://mirror.archlinuxarm.org/$arch/$repo'>mirrorlist;echo '[options]
Architecture = aarch64'>pacman.conf;;
  *)echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch
Server = https://mirrors.163.com/archlinux/$repo/os/$arch
Server = https://mirrors.tencent.com/archlinux/$repo/os/$arch'>mirrorlist;echo '[options]
Architecture = auto'>pacman.conf
esac
echo 'Color
ParallelDownloads = 5
SigLevel = Never
[core]
Include = /etc/pacman.d/mirrorlist
[extra]
Include = /etc/pacman.d/mirrorlist
[community]
Include = /etc/pacman.d/mirrorlist
[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
Server = https://mirrors.bfsu.edu.cn/archlinuxcn/$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
Server = https://mirrors.aliyun.com/archlinuxcn/$arch
Server = https://mirrors.163.com/archlinux-cn/$arch
Server = https://mirrors.tencent.com/archlinuxcn/$arch
Server = https://repo.archlinuxcn.org/$arch
[arch4edu]
Server = https://mirrors.bfsu.edu.cn/arch4edu/$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/arch4edu/$arch
Server = https://mirrors.aliyun.com/arch4edu/$arch
Server = https://mirrors.tencent.com/arch4edu/$arch'>>pacman.conf
echo "FROM $DKURL"'/menci/archlinuxarm
ENV LANG=zh_CN.UTF-8 TERM=xterm-256color
COPY mirrorlist /etc/pacman.d
COPY pacman.conf /etc
RUN echo "zh_CN.UTF-8 UTF-8">/etc/locale.gen\
 && locale-gen\
 && ln -vsf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime\
 && pacman -Syu --noconfirm --needed --overwrite "*" curl dialog git tmux tmate perl micro ranger fastfetch unzip fish btop htop nethogs ncdu ripgrep fd fzf bat catimg clash proxychains-ng lolcat ffmpeg chromium python-poetry noto-fonts-emoji\
 && { pacman -Rdd --noconfirm adobe-source-code-pro-fonts cantarell-fonts ttf-liberation;rm -rf /var/cache;}
RUN pacman -Syu --noconfirm --needed --overwrite "*" jre-openjdk\
 && rm -rf /var/cache
RUN echo -n '\''exec bash /root/TRSS_Amiya/Main.sh "$@"'\''>/usr/local/bin/tsai\
 && chmod 755 /usr/local/bin/tsai'>Dockerfile
docker build -t trss:amiya .||abort "Docker 容器构建失败"
docker image prune -f
echo "
$Y- 正在启动 Docker 容器$O
"
docker run -itd -h TRSS-Amiya --name $DKNAME -v "$DIR":/root/TRSS_Amiya --restart always $([ $DKNAME = TRSS_Amiya ]&&echo "-p 8088:8088"||echo "-p 8088") trss:amiya||abort "Docker 容器启动失败，若要重装容器，请先删除已安装容器，若要多开容器，请修改容器名"
mkdir -vp "$CMDPATH"&&echo -n "exec docker exec -it $DKNAME bash /root/TRSS_Amiya/Main.sh "'"$@"'>"$CMDPATH/$CMD"&&chmod 755 "$CMDPATH/$CMD"||abort "脚本执行命令 $CMDPATH/$CMD 设置失败，手动执行命令：docker exec -it $DKNAME bash /root/TRSS_Amiya/Main.sh"
echo "
$G- Docker 容器安装完成，启动命令：$CMD$O";exit;}
echo "
$Y- 正在下载脚本$O"
geturl(){ curl -L --retry 2 --connect-timeout 5 "$@";}
N=1
download