#!/usr/bin/env bash
#
#SBATCH -J Picos_TEs_ChIPseq
#
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=16000
#SBATCH --cpus-per-task=2
#SBATCH --nodes=1
#SBATCH --constraint=cal
#
#
###############################################
# ====== CONDICIONES ======
#   - Ra_1: muestra Rabdomiosarcoma 1 con tumor 1 
#   - Ra_2: muestra Rabdomiosarcoma 2 con tumor 2 
#   - S1: muestra de sangre
#
###############################################
#
# Cargar módulos
echo "=============== Carga de módulos ==============="
module load fastqc
module load star/2.7.11b
module load TrimGalore/0.6.10
module load samtools
module load kallisto
echo "=============== Carga de módulos finalizada correctamente ==============="
#
#Establecer directorio de trabajo 
cd ~/DATA/Rabdo
#
# Gunzip los archivos del genoma (annot. + seq.) y TEs (annot + seq)
echo "=============== Descarga del genoma de referencia de humano desde UCSC Genome Browser... ==============="
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
echo "=============== Extraer todos los archivos para el genoma de referencia ==============="
gunzip hg38*.gz
#
# Fusionar las anotaciones del genoma y secuencias del genoma
cat hg38_genes-annotations.gtf hg38_TEs-annotations.gtf > hg38_genes+TEs-annotations.gtf
#
# Extraer los archivos a alinear de archivo tar
tar -xf X204SC25035360-Z01-F001.tar -C ~/DATA/Rabdo/raw_data
#
#  Descomprimir todos los datos de las distintas condiciones
for CONDICION in Ra1_UDP0273 Ra2_UDP0274 S1_UDP0275
do
    echo "=============== Actualmente, en carpeta ${CONDICION} ... ==============="
    gunzip ~/DATA/Rabdo/raw_data/RawData/${CONDICION}/*.fq.gz
done
#
#
# 1. CONTROL DE CALIDAD INICIAL
#       Así nos aseguramos de la calidad de la secuenciación, y de la presencia/ausencia de adaptadores***
DIRECTORIO=~/DATA/Rabdo
for CONDICION in Ra1_UDP0273 Ra2_UDP0274 S1_UDP0275
do
    echo "=============== Realizando control de calidad (fastqc) en carpeta ${CONDICION} ... ==============="
    cd $DIRECTORIO/raw_data/RawData/${CONDICION}
    fastqc *L2_1.fq -o $DIRECTORIO/qc_reports
    fastqc *L2_2.fq -o $DIRECTORIO/qc_reports
done
#
# *** ELIMINAR ADAPTADORES DE LAS SECUENCIAS mediante TrimGalore
for CONDICION in Ra1_UDP0273 Ra2_UDP0274 S1_UDP0275
do
    echo "=============== Eliminando los adapatadores de la condicion ${CONDICION} ==============="
    trim_galore --paired $DIRECTORIO/raw_data/RawData/$CONDICION/*L2_1.fq $DIRECTORIO/raw_data/RawData/$CONDICION/*L2_2.fq -o $DIRECTORIO/trimmed
done
# trim_galore --help -> visualizar todos los argumentos
#
# Consejo: volver a correr fastqc para ver si los datasets tienen la calidad esperada
echo "=============== Realizando control de calidad (fastqc) de los fq trimmed ==============="
fastqc $DIRECTORIO/trimmed/*.fq -o $DIRECTORIO/qc_reports_trimmed
#
#
#
# 2. ALINEAMIENTO DE LAS SECUENCIAS CON STARSOLO
## Generar el genoma de referencia
cd ~/DATA
echo "=============== Generando el genoma de referencia para humano (hg38) ==============="
srun STAR --runMode genomeGenerate \
          --genomeDir ~/DATA/hg38_genome \
          --genomeFastaFiles $DIRECTORIO/hg38_genome.fa \
          --sjdbGTFfile $DIRECTORIO/hg38_genes+TEs-annotations.gtf \
          --sjdbOverhang 100 \
          --limitGenomeGenerateRAM 40000000000 \
          --limitSjdbInsertNsj 6000000 
echo "=============== Genoma de referencia generado ==============="
#
# Alineamiento con el genoma de referencia
# OJO: --runThreadN (4) tiene que ser igual al número de CPUs-per-task del nodo, sino no va a funcionar :D
# Alineamiento con el genoma de referencia
echo "=============== Alineando condición Ra1_UDP0273 con el genoma de referencia ==============="
cd ~/DATA/Rabdo/alignment_star
srun STAR --genomeDir ~/DATA/hg38_genome \
          --readFilesIn ~/DATA/Rabdo/trimmed/Ra1_UDP0273_MKDL250003653-1A_22LMFMLT4_L2_1_val_1.fq ~/DATA/Rabdo/trimmed/Ra1_UDP0273_MKDL250003653-1A_22LMFMLT4_L2_2_val_2.fq \
          --runThreadN 4 \
          --quantMode GeneCounts \
          --outSAMtype BAM SortedByCoordinate \
          --outFileNamePrefix ~/DATA/Rabdo/alignment_star/Ra1_UDP0273_
echo "=============== Código ejecutado correctamente para la condición Ra1_UDP0273 ==============="
# 
echo "=============== Alineando condición Ra2_UDP0274 con el genoma de referencia ==============="
cd ~/DATA/Rabdo/alignment_star
srun STAR --genomeDir ~/DATA/hg38_genome \
          --readFilesIn ~/DATA/Rabdo/trimmed/Ra2_UDP0274_MKDL250003653-1A_22LMFMLT4_L2_1_val_1.fq ~/DATA/Rabdo/trimmed/Ra2_UDP0274_MKDL250003653-1A_22LMFMLT4_L2_2_val_2.fq \
          --runThreadN 4 \
          --quantMode GeneCounts \
          --outSAMtype BAM SortedByCoordinate \
          --outFileNamePrefix ~/DATA/Rabdo/alignment_star/Ra2_UDP0274_
echo "=============== Código ejecutado correctamente para la condición Ra2_UDP0274 ==============="
# 
echo "=============== Alineando condición S1_UDP0275 con el genoma de referencia ==============="
cd ~/DATA/Rabdo/alignment_star
srun STAR --genomeDir ~/DATA/hg38_genome \
          --readFilesIn ~/DATA/Rabdo/trimmed/S1_UDP0275_MKDL250003653-1A_22LMFMLT4_L2_1_val_1.fq ~/DATA/Rabdo/trimmed/S1_UDP0275_MKDL250003653-1A_22LMFMLT4_L2_2_val_2.fq \
          --runThreadN 4 \
          --quantMode GeneCounts \
          --outSAMtype BAM SortedByCoordinate \
          --outFileNamePrefix ~/DATA/Rabdo/alignment_star/S1_UDP0275
echo "=============== Código ejecutado correctamente para la condición S1_UDP0275 ==============="
#
# 
# echo "Indexar archivos .bam"
samtools index ~/DATA/Rabdo/alignment_data/*Aligned.sortedByCoord.out.bam

#
#
# Correr rseqc: conocer si es stranded-forward o stranded-reverse
#
#
# Para usar isoDE, hay que usar kallisto
kallisto index -i transcripts.idx transcripts.fa # Crear índice (solo una vez)
# Cuantificación con bootstrap (ej: 100 réplicas)
kallisto quant -i transcripts.idx -o tumor_out -b 100 tumor.fastq
kallisto quant -i transcripts.idx -o blood_out -b 100 blood.fastq
#
#
# DESeq2: genes diferencialmente expresados (si triplicamos las muestras: 3 réplicas identicas) 
#   Se podría fusionar los Ra ()
# NOISeq: genes diferencialmente expresados (sin réplicas)
# isoDE: DGEA sin réplicas
#
#
####################################################################################################################################################################################
# GENES DE FUSION
# -----------------------------------------------
# Primero correr el STAR para generar el archivo bam y chimeric.junctions.out
cd ~/DATA/Rabdo/starfusion
echo "Alineando para star-fusion para la muestra Ra1..."
srun STAR --runThreadN 8 \
  --genomeDir /ruta/al/genomeDir \
  --readFilesIn ~/DATA/Rabdo/trimmed/Ra1_UDP0273_MKDL250003653-1A_22LMFMLT4_L2_1_val_1.fq ~/DATA/Rabdo/trimmed/Ra1_UDP0273_MKDL250003653-1A_22LMFMLT4_L2_2_val_2.fq \ \
  --outFileNamePrefix Ra1_ \
  --outSAMtype BAM SortedByCoordinate \
  --chimSegmentMin 12 \
  --chimJunctionOverhangMin 8 \
  --chimOutType Junctions SeparateSAMold \
  --alignSJDBoverhangMin 10 \
  --alignMatesGapMax 200000 \
  --alignIntronMax 100000 \
  --alignSJstitchMismatchNmax 5 -1 5 5


# STAR-fusion
# Preparacion del nuevo genoma
# Descarga de las anotaciones de fusion desde CTAT
wget https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/GRCh38_gencode_v44_CTAT_lib_Oct292023.plug-n-play.tar.gz
tar -xzvf GRCh38_gencode_v44_CTAT_lib_Oct292023.plug-n-play.tar.gz
# Ejecutar STAR-fusion
srun srun ~/DATA/tools/star-fusion/STAR-Fusion \
  --genome_lib_dir ~/DATA/Rabdo/GRCh38_gencode_v44_CTAT_lib_Oct292023.plug-n-play.tar.gz \
  --chimeric_junction ~/DATA/Rabdo/alignment-star/S1_Chimeric.out.junction \
  --aligned_bam ~/DATA/Rabdo/alignment-star/S1_Aligned.sortedByCoord.out.bam \
  --output_dir ~/DATA/Rabdo/starfusion



# ARRIBA
cd $DIRECTORIO
rm -rf ~/DATA/Rabdo/alignment-star
mkdir alignment-star2

cd alignment-star2

STAR --runThreadN 8 \
     --genomeDir ~/DATA/hg38_genome \
     --readFilesIn ~/DATA/Rabdo/trimmed/S1_UDP0275_MKDL250003653-1A_22LMFMLT4_L2_1_val_1.fq ~/DATA/Rabdo/trimmed/S1_UDP0275_MKDL250003653-1A_22LMFMLT4_L2_2_val_2.fq \
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
     --outFileNamePrefix Ra1_

# Luego ejecutar Arriba
cd ~/DATA
tools/arriba_v2.5.0/arriba \
  -x ~/DATA/Rabdo/alignment-star2/Ra1_Aligned.sortedByCoord.out.bam \
  -o ~/DATA/Rabdo/arriba/Ra1_fusions.tsv \
  -O ~/DATA/Rabdo/arriba/Ra1_fusions.discarded.tsv \
  -a ~/DATA/Rabdo/hg38_genome.fa \
  -g ~/DATA/Rabdo/hg38_genes+TEs-annotations.gtf \
  -b ~/DATA/tools/arriba_v2.5.0/database/blacklist_hg38_GRCh38_v2.5.0.tsv \
  -k ~/DATA/tools/arriba_v2.5.0/database/known_fusions_hg38_GRCh38_v2.5.0.tsv 


#
#