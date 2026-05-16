#!/bin/bash
# Script de Automação ACPI via HOOK Nativo no CachyOS (Limine)
set -e

echo "==> 1. Instalando dependências e clonando o repositório completo..."
sudo pacman -S iasl --needed --noconfirm
rm -rf bc250-acpi-fix
git clone https://github.com/bc250-collective/bc250-acpi-fix.git

(
    echo "==> 2. Compilando as tabelas..."
    cd bc250-acpi-fix
    iasl -tc SSDT-CST.dsl
    iasl -tc SSDT-PST.dsl

    echo "==> 3. Movendo arquivos .aml para a pasta oficial do HOOK..."
    sudo mkdir -p /etc/initcpio/acpi_override
    sudo cp *.aml /etc/initcpio/acpi_override/
)

echo "==> 4. Garantindo o hook acpi_override no /etc/mkinitcpio.conf..."
if ! grep -q "acpi_override" /etc/mkinitcpio.conf; then
    sudo sed -i 's/autodetect/autodetect acpi_override/g' /etc/mkinitcpio.conf
    echo "[OK] Hook acpi_override ativado no arquivo de configuração."
else
    echo "[AVISO] O hook acpi_override já está presente."
fi

echo "==> 5. Rodando mkinitcpio e respondendo 'Sim' automaticamente ao Limine..."
# O comando 'yes ""' simula o pressionamento da tecla ENTER automaticamente
yes "" | sudo mkinitcpio -P

echo "===================================================================="
echo " Tudo pronto! O CachyOS aceitou o ENTER automático e gerou o boot. "
echo " Reinicie a sua AMD BC-250 usando o comando: 'sudo reboot' e vamos rezar rs          "
echo "===================================================================="
