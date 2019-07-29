#!/bin/bash
Block="/etc/nanobc" && [[ ! -d ${Block} ]] && exit
Block > /dev/null 2>&1

SCPdir="/etc/newadm"
SCPusr="${SCPdir}/ger-user"
SCPfrm="/etc/ger-frm"
SCPfrm3="/etc/adm-lite"
SCPinst="/etc/ger-inst"
SCPidioma="${SCPdir}/idioma"


fun_trans () {
#echo "$@"
#FUNCAO DENTRO DE FUNCAO KKKKKKKKK FDC
#apt-get install jq -y 2&>1 /dev/null
#apt-get install php -y 2&>1 /dev/null
func_tradu () {
local msg
message=($@)
key_api="trnsl.1.1.20190727T075223Z.750e23e6753a85b7.cdf2fd60fa8d836b334793524a40f87182da67f1"
lang="$1"
text=$(echo "${message[@]:1}"| php -r 'echo urlencode(fgets(STDIN));' // Or: php://stdin)
link=$(curl -s -d "key=$key_api&format=plain&lang=$lang&text=$text" https://translate.yandex.net/api/v1.5/tr.json/translate)
ms="$(echo $link|jq -r '.text[0]')"
echo "$ms"
}
local texto
local retorno
declare -A texto
SCPidioma="${SCPdir}/idioma"
[[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
local LINGUAGE=$(cat ${SCPidioma})
[[ -z $LINGUAGE ]] && LINGUAGE=es
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z "$(echo ${texto[$@]})" ]]; then
#ENGINES=(aspell google deepl bing spell hunspell apertium yandex)
#NUM="$(($RANDOM%${#ENGINES[@]}))"
retorno="$(func_tradu ${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
echo "texto[$@]='$retorno'"  >> /etc/texto-adm
echo "$retorno"
else
echo "${texto[$@]}"
fi
}

declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\e[1;33m=-=-=-=-=-=-=-==-=-=-=--=-==-=-=-=-=-=-=-==-=-=-=--=-==-=-=-=-=-=-=-=\e[0m"
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}
fun_ip () {
if [[ -e /etc/MEUIPADM ]]; then
IP="$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}
fun_eth () {
eth=$(ifconfig | grep -v inet6 | grep -v lo | grep -v 127.0.0.1 | grep "encap:Ethernet" | awk '{print $1}')
    [[ $eth != "" ]] && {
    echo -e "$barra"
    echo -e "${cor[3]} $(fun_trans "Aplicar el sistema para mejorar los paquetes SSH?")"
    echo -e "${cor[3]} $(fun_trans "Opcion para usuarios avanzados")"
    echo -e "$barra"
    read -p " [S/N]: " -e -i n sshsn
           [[ "$sshsn" = @(s|S|y|Y) ]] && {
           echo -e "${cor[1]} $(fun_trans "Correccion de problemas de paquetes en SSH ...")"
           echo -e " $(fun_trans "¿Cuál es la tasa RX?")"
           echo -ne "[ 1 - 999999999 ]: "; read rx
           [[ "$rx" = "" ]] && rx="999999999"
           echo -e " $(fun_trans "¿Cuál es la tarifa TX")"
           echo -ne "[ 1 - 999999999 ]: "; read tx
           [[ "$tx" = "" ]] && tx="999999999"
           apt-get install ethtool -y > /dev/null 2>&1
           ethtool -G $eth rx $rx tx $tx > /dev/null 2>&1
           }
     echo -e "$barra"
     }
}

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.2
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1 && tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}
fun_dropbear () {
 [[ -e /etc/default/dropbear ]] && {
 echo -e "\033[1;32m $(fun_trans "REMOVIENDO DROPBEAR")\n$barra"
 service dropbear stop & >/dev/null 2>&1
 fun_bar "apt-get remove dropbear -y"
 echo -e "$barra\n\033[1;32m $(fun_trans "Dropbear Removido Con Exito!!!")\n$barra"
 [[ -e /etc/default/dropbear ]] && rm /etc/default/dropbear
 return 0
 }
echo -e "\033[1;32m $(fun_trans "INSTALADOR DROPBEAR NEW - ADM")\n$barra"
echo -e "\033[1;31m $(fun_trans "Seleccione Puertos Válidos en orden secuencial:")\033[1;32m 22 80 81 82 85 90\033[1;37m"
echo -e "$barra"
echo -ne "\033[1;31m $(fun_trans "Introduzca el puerto"): \033[1;37m" && read DPORT
tput cuu1 && tput dl1
TTOTAL=($DPORT)
    for((i=0; i<${#TTOTAL[@]}; i++)); do
        [[ $(mportas|grep "${TTOTAL[$i]}") = "" ]] && {
        echo -e "\033[1;33m $(fun_trans "Puerta Elegida:")\033[1;32m ${TTOTAL[$i]} OK"
        PORT="$PORT ${TTOTAL[$i]}"
        } || {
        echo -e "\033[1;33m $(fun_trans "Puerta Elegida:")\033[1;31m ${TTOTAL[$i]} FALLO"
        }
   done
  [[  -z $PORT ]] && {
  echo -e "\033[1;31m $(fun_trans "No se ha elegido ninguna puerta válida")\033[0m"
  return 1
  }
sysvar=$(cat -n /etc/issue |grep 1 |cut -d' ' -f6,7,8 |sed 's/1//' |sed 's/      //' | grep -o Ubuntu)
[[ ! $(cat /etc/shells|grep "/bin/false") ]] && echo -e "/bin/false" >> /etc/shells
[[ "$sysvar" != "" ]] && {
echo -e "Port 22
Protocol 2
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes" > /etc/ssh/sshd_config
echo -e "${cor[2]} $(fun_trans "Instalando dropbear")"
echo -e "$barra"
fun_bar "apt-get install dropbear -y"
echo -e "$barra"
touch /etc/dropbear/banner
echo -e "${cor[2]} $(fun_trans "Configurando dropbear")"
cat <<EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_EXTRA_ARGS="VAR"
DROPBEAR_BANNER="/etc/dropbear/banner"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
for dpts in $(echo $PORT); do
sed -i "s/VAR/-p $dpts VAR/g" /etc/default/dropbear
done
sed -i "s/VAR//g" /etc/default/dropbear
}
fun_eth
service ssh restart > /dev/null 2>&1
service dropbear restart > /dev/null 2>&1
echo -e "${cor[3]} $(fun_trans "Seu dropbear foi configurado com sucesso")\n$barra"
#UFW
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
}
fun_dropbear
