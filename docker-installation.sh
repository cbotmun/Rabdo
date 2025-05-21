#!/usr/bin/env bash
#
#SBATCH -J Alignment-Chimeric-Rabdo
#
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=48000
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --constraint=cal

# TERMINAL DE WINDOWS 
docker images
docker pull trinityctat/starfusion
docker run -it --rm -p27017:27017 --name star-fusion trinityctat/starfusion:latest /bin/bash
# Insertar comando de ejecucion2 o del workflow perteneciente a starfusion en workflow.sh