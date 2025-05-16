# Scripts empleados en el estudio bioinformático del Rabdomiosarcoma 

Se ha realizado un flujo de trabajo para el análisis de las muestras procedentes de pacientes con rabdomiosarcoma (Ra_1 y Ra_2, son dos formas distintas de cáncer) y una muestra de sangre (muestra control: S1). El análisis consta de los siguientes pasos: 
1. Descarga de las muestras.
2. Preprocesamiento de las muestras
3. Alineamiento con el genoma de referencia
4. Indexado de las muestras
5. Análisis DGEA en R
6. Estudio de los genes de fusión. Se conoce que en los tumores aparecen genes de fusión, que se forman cuando dos geens diferentes se combinan como resultado de una reorganización cromosómica (por translocaciones, inversiones, delecciones, duplicaciones). Se crea un nuevo gen híbrido, que puede producir una proteína de fusión con funciones alteradas o completamente nuevas,  como promover el crecimiento descontrolado de células. Así, muchas de estas proteínas de fusión pueden ser dianas terapéuticas. 

## _instalacion_local_star-fusion_arriba.sh_
Recoge los scripts necesarios para realizar una instalación local de las bioherramientas STAR-Fusion y Arriba. 

## _workflow.sh_
En _workflow.sh_ se recoge todo el flujo de trabajo de los distintos scripts empleados en bash. Las herramientas utilizadas han sido:
* FASTQC: control de calidad de la secuenciación de las muestras del estudio. 
* TrimGalore: versión 0.6.10: eliminación de las secuencias pertenecientes a adaptadores.
* STAR version 2.7.11b: alineamiento de las muestras con el genoma de referencia.
* Samtools: manejo de archivos bam y sam. Principalmente usado para el indexado de las muestras .bam generadas tras el alienamiento para su visualización en IGV.
* STAR-Fusion (instalación local): estudio de los genes de fusión. 
* Arriba (instalación local): estudio de los genes de fusión.

## _ejecucion2.sh_
Comando de ejecución de los scripts de las herramientas STAR-Fusion y Arriba
