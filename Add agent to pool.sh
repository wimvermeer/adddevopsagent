# Update the list of packages
sudo apt-get update
# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
# Update the list of products
sudo apt-get update
# Enable the "universe" repositories
sudo add-apt-repository universe
# Install PowerShell
sudo apt-get install -y powershell

mkdir azagent
cd azagent
curl -fkSL -o vstsagent.tar.gz https://vstsagentpackage.azureedge.net/agent/2.182.1/vsts-agent-linux-x64-2.182.1.tar.gz
tar -zxvf vstsagent.tar.gz
 if [ -x "$(command -v systemctl)" ]
 then ./config.sh --replace --unattended --acceptteeeula --agent $HOSTNAME --url https://dev.azure.com/Dev-WGBV/ --work _work --projectname 'Sentinel_Pipeline_Dev' --auth PAT --token $1 --runasservice
 sudo ./svc.sh install
 sudo ./svc.sh start
 else ./config.sh --replace --unattended --acceptteeeula --agent $HOSTNAME --url https://dev.azure.com/Dev-WGBV/ --work _work --projectname 'Sentinel_Pipeline_Dev' --auth PAT --token $1
 ./run.sh
 fi
