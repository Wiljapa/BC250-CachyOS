Se estiver instalado o cachyos a partir dessa data 2026/06/30
Houve mudanças no sistema, desabilitaram o aur e retiraram o paru, que são necessários para o script funcionar. 
Habilite o aur pelo shelly
Instale o paru : sudo pacman -S paru. 
Agora pode rodar o script. 

Depois que baixar o arquivo dar permissão de excutável chmod +x novoacpifix
Execute ./novoacpifix

Esse script instala o acpi fix na bc250 de modo permanente (só para quem usa cachyos com limine), mesmo o cachyos atualizando ele será gerado por ter um HOOK que injeta no limine.
Instala o modulo da fan NCT6687 para os sensores apareceram no cooler control
Não preciso dizer que é por sua conta e risco.
Ajudando a comunidade em geral e a comunidade amd BC 250 Brasil 

Substituir o daemon e utilitários do kde para poder controlar a cpu pelo icone de energia na tray do kde

sudo pacman -Rs cpupower power-profiles-daemon

Instale o tuned

sudo pacman -Sy tuned-cachy tuned-cachy-ppd

Habilite os serviços

sudo systemctl enable --now tuned.service
sudo systemctl enable --now tuned-ppd.service

Reinicie
