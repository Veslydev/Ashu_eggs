#!/bin/bash
if [[ -f "./frps" ]]; then
    bash <(curl -s https://raw.githubusercontent.com/Ashu11-A/Ashu_eggs/main/Frp/start.sh)
else

cd /mnt/server

GITHUB_PACKAGE=fatedier/frp
LATEST_JSON=$(curl --silent "https://api.github.com/repos/$GITHUB_PACKAGE/releases" | jq -c '.[]' | head -1)
RELEASES=$(curl --silent "https://api.github.com/repos/$GITHUB_PACKAGE/releases" | jq '.[]')
ARCH=$([ "$(uname -m)" == "x86_64" ] && echo "amd64" || echo "arm64")

if [ "${ARCH}" == "arm64" ]; then
    if [ -z "$VERSION" ] || [ "$VERSION" == "latest" ]; then
        echo -e "defaulting to latest release"
        DOWNLOAD_LINK=$(echo $LATEST_JSON | jq .assets | jq -r .[].browser_download_url | grep -i frp | grep -i linux | grep -i arm64)
    else
        VERSION_CHECK=$(echo $RELEASES | jq -r --arg VERSION "$VERSION" '. | select(.tag_name==$VERSION) | .tag_name')
    if [ "$VERSION" == "$VERSION_CHECK" ]; then
        DOWNLOAD_LINK=$(echo $RELEASES | jq -r --arg VERSION "$VERSION" '. | select(.tag_name==$VERSION) | .assets[].browser_download_url' | grep -i frp | grep -i linux | grep -i arm64)
    else
        echo -e "defaulting to latest release"
        DOWNLOAD_LINK=$(echo $LATEST_JSON | jq .assets | jq -r .[].browser_download_url | grep -i frp | grep -i linux | grep -i arm64)
    fi
fi
else
    if [ -z "$VERSION" ] || [ "$VERSION" == "latest" ]; then
        echo -e "defaulting to latest release"
        DOWNLOAD_LINK=$(echo $LATEST_JSON | jq .assets | jq -r .[].browser_download_url | grep -i frp | grep -i linux | grep -i amd64)
    else
        VERSION_CHECK=$(echo $RELEASES | jq -r --arg VERSION "$VERSION" '. | select(.tag_name==$VERSION) | .tag_name')
    if [ "$VERSION" == "$VERSION_CHECK" ]; then
        DOWNLOAD_LINK=$(echo $RELEASES | jq -r --arg VERSION "$VERSION" '. | select(.tag_name==$VERSION) | .assets[].browser_download_url' | grep -i frp | grep -i linux | grep -i amd64)
    else
        echo -e "defaulting to latest release"
        DOWNLOAD_LINK=$(echo $LATEST_JSON | jq .assets | jq -r .[].browser_download_url | grep -i frp | grep -i linux | grep -i amd64)
        fi
    fi
fi

mv ./* Frp_OLD

mkdir Logs

cat <<EOF > ./Logs/log_install.txt
Versão: ${VERSION}
Link: ${DOWNLOAD_LINK}
Arquivo: ${DOWNLOAD_LINK##*/}
EOF

echo -e "running 'curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/}'"
curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/}
echo -e "Unpacking server files"
tar -xvzf ${DOWNLOAD_LINK##*/}
cp -R frp*/* ./
rm -rf frp*linux*
rm -rf ${DOWNLOAD_LINK##*/}

cat <<EOF > frpc.ini
[common]
#Aqui conecta no servidor externo (pode ser ip tambem)
server_addr = apenas-um.exemplo.net
server_port = $bind_port
bind_udp_port = $bind_udp_port
#Aqui ira criar um http localmente para voce acessar
admin_addr = 0.0.0.0
admin_port = 7500
admin_user = admin
admin_pwd = admin
#aqui ira autenticar com o seu servidor externo (Mais seguro desse jeito)
authenticate_heartbeats = true
authenticate_new_work_conns = false
token = $token
#Exemplo de liberação de porta
[seu_serviço_ou_jogo]
type = tcp
local_ip = 0.0.0.0
local_port = 7777
remote_port = 25310
use_compression = true
EOF

cat <<EOF > frps.ini
[common]
#As portas que serão usadas para permitir que seu frpc externo se conecte no seu servidor
bind_port =
bind_udp_port =
#Aqui ira criar um dashboard no seu servidor local para voce acessar
dashboard_addr =
dashboard_port =
dashboard_user =
dashboard_pwd =
#Como medida de segurança, é preciso uma gerar uma senha de autenticação.
authentication_method =
authenticate_heartbeats =
token =
EOF

mkdir Frps
mv frps* ./Frps

mkdir Frpc
mv frpc* ./Frpc

if [ "${INSTALL_EX}" == "1" ]; then
    mkdir Exemplo_Frpc_Windows64
    cp -f ./Frpc/frpc.ini ./Exemplo_Frpc_Windows64/frpc.ini
    cd Exemplo_Frpc_Windows64
        if [ -z "$VERSION" ] || [ "$VERSION" == "latest" ]; then
            echo -e "defaulting to latest release"
            DOWNLOAD_LINK_EX=$(echo $LATEST_JSON | jq .assets | jq -r .[].browser_download_url | grep -i frp | grep -i windows | grep -i amd64)
        else
            VERSION_CHECK=$(echo $RELEASES | jq -r --arg VERSION "$VERSION" '. | select(.tag_name==$VERSION) | .tag_name')
        if [ "$VERSION" == "$VERSION_CHECK" ]; then
            DOWNLOAD_LINK_EX=$(echo $RELEASES | jq -r --arg VERSION "$VERSION" '. | select(.tag_name==$VERSION) | .assets[].browser_download_url' | grep -i frp | grep -i windows | grep -i amd64)
        else
            echo -e "defaulting to latest release"
            DOWNLOAD_LINK_EX=$(echo $LATEST_JSON | jq .assets | jq -r .[].browser_download_url | grep -i frp | grep -i windows | grep -i amd64)
        fi
    fi

cat <<EOF > ../Logs/log_install_win.txt
Versão: ${VERSION}
Link: ${DOWNLOAD_LINK_EX}
Arquivo: ${DOWNLOAD_LINK_EX##*/}
EOF

echo -e "running 'curl -sSL ${DOWNLOAD_LINK_EX} -o ${DOWNLOAD_LINK_EX##*/}'"
curl -sSL ${DOWNLOAD_LINK_EX} -o ${DOWNLOAD_LINK_EX##*/}
echo -e "Unpacking server files"
unzip ${DOWNLOAD_LINK_EX##*/}
cp -R frp*/* ./
rm -rf frp*windows*
rm -rf ${DOWNLOAD_LINK_EX##*/}
rm frps*
rm LICENSE
cat <<EOF > start.bat
frpc.exe -c frpc.ini
EOF
else
    echo "Pulando Instalação do Exemplo Windows64"
fi

echo -e "Instalação Completa"
exit 0
fi