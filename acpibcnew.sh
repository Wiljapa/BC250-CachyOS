#!/bin/bash
# Script de Automação ACPI via HOOK Nativo e Ajuste de Compactação no CachyOS
set -e

echo "==> 1. Instalando dependências e clonando o repositório completo..."
sudo pacman -S iasl cpio --needed --noconfirm
sudo rm -rf bc250-acpi-fix

git clone https://github.com/bc250-collective/bc250-acpi-fix.git


echo "==> 2. Compilando as tabelas..."
(
    cd bc250-acpi-fix
    iasl -tc SSDT-CST.dsl
    iasl -tc SSDT-PST.dsl

    echo "==> 3. Movendo arquivos .aml para a pasta oficial do HOOK..."
    sudo mkdir -p /etc/initcpio/acpi_override
    sudo cp *.aml /etc/initcpio/acpi_override/
)

echo "==> 4. Forçando a desativação da compactação no mkinitcpio..."
# O kernel precisa ler o CPIO sem compressão no início da imagem de boot
if grep -q "^COMPRESSION=" /etc/mkinitcpio.conf; then
    sudo sed -i 's/^COMPRESSION=.*/COMPRESSION="cat"/' /etc/mkinitcpio.conf
else
    echo 'COMPRESSION="cat"' | sudo tee -a /etc/mkinitcpio.conf
fi

echo "==> 5. Garantindo o hook acpi_override no /etc/mkinitcpio.conf..."
if ! grep -q "acpi_override" /etc/mkinitcpio.conf; then
    sudo sed -i 's/autodetect/autodetect acpi_override/g' /etc/mkinitcpio.conf
    echo "[OK] Hook acpi_override ativado no arquivo de configuração."
else
    echo "[AVISO] O hook acpi_override já está presente."
fi

echo "==> 6. Configurando os parâmetros de boot permanentes no /etc/default/limine..."
# Criamos o arquivo sem a linha MODULES (já que ela falhou) e usando apenas "=" comum
sudo tee /etc/default/limine > /dev/null << 'EOF'
SP_PATH="/boot"
KERNEL_CMDLINE_default="acpi_override=1 quiet nowatchdog splash rw rootflags=subvol=/@ root=UUID=3a285744-1f0c-4683-9704-a4225cd6535b systemd.zram=0 zswap.enabled=1 zswap.max_pool_percent=25 zswap.compressor=lz4 loglevel=0 mitigations=off"
BOOT_ORDER="*, *lts, *fallback, Snapshots"
EOF

echo "==> 7. Rodando mkinitcpio e sincronizando com o Limine..."
# recria o initramfs com o hook embutido e atualiza o limine de forma oficial
yes "" | sudo limine-mkinitcpio

echo "===================================================================="
echo " Tudo pronto! O formato via HOOK com COMPRESSION='cat' foi aplicado. "
echo " A configuração está protegida contra futuras atualizações do CachyOS. "
echo " Reinicie usando o comando: 'sudo reboot' "
echo "===================================================================="


