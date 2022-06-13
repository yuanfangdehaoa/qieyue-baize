function list_running_server()
{
    local ServList=$(ps -ef | grep beam | grep -v "grep")
    local OldIFS=${IFS}
    local IFS=$'\n'
    local Format="%-10s%-40s%-40s\n"
    printf ${Format} Pid Name Path
    printf "=========================================================================================\n"
    for Serv in ${ServList}; do
        local Pid=$(echo ${Serv} | awk '{print $2}')
        local Name=$(echo ${Serv} | grep -E -o "\-name \S+" | cut -d" " -f2)
        local Path=$(echo ${Serv} | grep -E -o "\-sdir \S+" | cut -d" " -f2)
        printf ${Format} ${Pid} ${Name} ${Path}
    done
    IFS=${OldIFS}
}

function list_deployed_server()
{
	local ServList=$(find /data/*/*/{center,cross,server} -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
	local OldIFS=${IFS}
    local IFS=$'\n'
    local Format="%-10s%-10s%-10s%-10s%-40s\n"
    printf ${Format} GameName Platform ServType ServerID ServPath
    printf "================================================================================\n"
    for Serv in ${ServList}; do
    	local Split=$(echo ${Serv} | sed 's|/data/||g' | sed 's|/|\t|g')
        local GameName=$(echo ${Split} | cut -f1)
        local Platform=$(echo ${Split} | cut -f2)
        local ServType=$(echo ${Split} | cut -f3)
        local ServerID=$(echo ${Split} | cut -f4)
        printf ${Format} ${GameName} ${Platform} ${ServType} ${ServerID} ${Serv}
    done
    IFS=${OldIFS}
}

alias llr="list_running_server"
alias lla="list_deployed_server"
