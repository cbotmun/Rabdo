#!/usr/bin/env bash
#
#SBATCH -J Alignment-Chimeric-Rabdo
#
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=48000
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --constraint=cal


#####################################################################################################################################
# STAR-FUSSION
#####################################################################################################################################
# Crear una carpeta de trabajo
mkdir -p ~/DATA/tools/star-fusion
cd ~/DATA/tools/star-fusion

# Clonar el repositorio oficial
git clone --recursive https://github.com/STAR-Fusion/STAR-Fusion.git
cd STAR-Fusion

# Load required modules to install 
module load R
module load samtools
module load star

# compilar las dependencias internas
make

# More information in: https://github.com/STAR-Fusion/STAR-Fusion/wiki



#####################################################################################################################################
# ARRIBA
#####################################################################################################################################
# Descargar datos en Docker:
# scp twidmann@picasso.scbi.uma.es:'/mnt/home/users/bio_028_genyo/twidmann/DATA/Rabdo/alignment-star/*.bam' /home/ubuntu/Rabdo_data/bam

# Descargar el repositorio
wget https://github.com/suhrig/arriba/releases/download/v2.5.0/arriba_v2.5.0.tar.gz
tar -xzf arriba_v2.5.0.tar.gz

cd arriba_v2.5.0 && make # or use precompiled binaries

# More information in: https://github.com/suhrig/arriba/wiki
