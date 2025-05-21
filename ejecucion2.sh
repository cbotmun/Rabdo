#!/usr/bin/env bash
#
#SBATCH -J STARFusion_Arriba_Rabdo
#
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=64000
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --constraint=cal
#
# Cargar módulos
echo "=============== Carga de módulos ==============="
module load star/2.7.11b
module load samtools
module load R
echo "=============== Carga de módulos finalizada correctamente ==============="
#
#Establecer directorio de trabajo 
cd ~/DATA/Rabdo
#Variables
DIRECTORIO=~/DATA/Rabdo
#
#
#
#################################################################################################################################
# STAR-FUSION
# -----------------------------------------------
# Primero correr el STAR para generar el archivo bam y chimeric.junctions.out
for SAMPLE in Ra1_UDP0273 Ra2_UDP0274 S1_UDP0275 
do 
  cd ~/DATA/Rabdo/alignment-star
  echo "Alineando para star-fusion para la muestra ${SAMPLE}..."
  srun STAR --runThreadN 8 \
    --genomeDir ~/DATA/hg38_genome \
    --readFilesIn ~/DATA/Rabdo/trimmed/${SAMPLE}_MKDL250003653-1A_22LMFMLT4_L2_1_val_1.fq ~/DATA/Rabdo/trimmed/${SAMPLE}_MKDL250003653-1A_22LMFMLT4_L2_2_val_2.fq \
    --outFileNamePrefix ${SAMPLE}_ \
    --outSAMtype BAM SortedByCoordinate \
    --chimSegmentMin 12 \
    --chimJunctionOverhangMin 8 \
    --chimOutType Junctions SeparateSAMold \
    --alignSJDBoverhangMin 10 \
    --alignMatesGapMax 200000 \
    --alignIntronMax 100000 \
    --alignSJstitchMismatchNmax 5 -1 5 5
done

# Preparacion del nuevo genoma con las anotaciones de la fusion de genes
cd $DIRECTORIO
# Descarga de las anotaciones de fusion desde CTAT
wget https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/GRCh38_gencode_v44_CTAT_lib_Oct292023.plug-n-play.tar.gz
tar -xzvf GRCh38_gencode_v44_CTAT_lib_Oct292023.plug-n-play.tar.gz

# Ejecutar STAR-fusion
for SAMPLE in Ra1_UDP0273 Ra2_UDP0274 S1_UDP0275 
do 
  echo "Alineando con star-fusion la muestra ${SAMPLE}.."
  srun ~/DATA/tools/star-fusion/STAR-Fusion \
    --genome_lib_dir ~/DATA/Rabdo/GRCh38_gencode_v44_CTAT_lib_Oct292023.plug-n-play.tar.gz \
    --chimeric_junction ~/DATA/Rabdo/alignment-star/${SAMPLE}_Chimeric.out.junction \
    --aligned_bam ~/DATA/Rabdo/alignment-star/${SAMPLE}_Aligned.sortedByCoord.out.bam \
    --output_dir ~/DATA/Rabdo/starfusion
done

###############################################################################################################################
# ARRIBA
# ----------------------------------------------------
cd $DIRECTORIO
rm -rf alignment-star
mkdir alignment-star2

for SAMPLE in Ra1_UDP0273 Ra2_UDP0274 S1_UDP0275 
do 
  echo "PREPARACIÓN DE ARRIBA: Alineando con star la muestra ${SAMPLE}.."
  cd alignment-star2
  srun STAR --runThreadN 8 \
     --genomeDir ~/DATA/hg38_genome \
     --readFilesIn ~/DATA/Rabdo/trimmed/${SAMPLE}_MKDL250003653-1A_22LMFMLT4_L2_1_val_1.fq ~/DATA/Rabdo/trimmed/${SAMPLE}_MKDL250003653-1A_22LMFMLT4_L2_2_val_2.fq \
     --outSAMtype BAM SortedByCoordinate \
     --twopassMode Basic \
     --chimOutType WithinBAM SoftClip \
     --chimSegmentMin 10 \
     --chimJunctionOverhangMin 10 \
     --alignSJDBoverhangMin 1 \
     --alignMatesGapMax 100000 \
     --alignIntronMax 100000 \
     --chimSegmentReadGapMax 3 \
     --alignSJstitchMismatchNmax 5 -1 5 5 \
     --outFileNamePrefix ${SAMPLE}_
  cd ../
done

# Luego ejecutar Arriba
for SAMPLE in Ra1_UDP0273 Ra2_UDP0274 S1_UDP0275 
do 
  echo "Ejecutando 'arriba': Muestra ${SAMPLE}..."
  cd ~/DATA
  srun tools/arriba_v2.5.0/arriba \
    -x ~/DATA/Rabdo/alignment-star2/${SAMPLE}_Aligned.sortedByCoord.out.bam \
    -o ~/DATA/Rabdo/arriba/${SAMPLE}_fusions.tsv \
    -O ~/DATA/Rabdo/arriba/${SAMPLE}_fusions.discarded.tsv \
    -a ~/DATA/Rabdo/hg38_genome.fa \
    -g ~/DATA/Rabdo/hg38_genes+TEs-annotations.gtf \
    -b ~/DATA/tools/arriba_v2.5.0/database/blacklist_hg38_GRCh38_v2.5.0.tsv \
    -k ~/DATA/tools/arriba_v2.5.0/database/known_fusions_hg38_GRCh38_v2.5.0.tsv 
done

