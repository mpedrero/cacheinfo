#!/bin/bash

# Aqui convertimos el parametro del script en la carpeta que 
# queremos mirar
if [ "$1" = "1" ]; then
	dir="index0"
elif [ "$1" = "1i" ]; then
	dir="index1"
elif [ "$1" = "2" ]; then
	dir="index2"
elif [ "$1" = "3" ]; then
	dir="index3"
else
	echo "Especifica nivel de cache como parámetro del script:"
	echo "1:  Caché de datos L1"
	echo "1i: Caché de instrucciones L1"
	echo "2: Caché L2"
	echo "3: Caché L3 (si existe)"
	exit
fi


# Nos movemos al directorio donde está la información de la cache
cd /sys/devices/system/cpu/cpu0/cache/$dir

# Recogemos los datos relevantes

# Numero de conjuntos de la cache
num_conjuntos=$(cat number_of_sets)
# Numero de vias de asociatividad
num_vias=$(cat ways_of_associativity)
# Tamaño total de la cache (en bruto, esta en KB)
tam_total=$(cat size)
# Tamaño de bloque (en bytes)
tam_bloque=$(cat coherency_line_size)
# Tamaño de palabra (en bytes)
tam_palabra=$(uname -m)

# Damos formato al tamaño total de la cache y al
# tamaño de la palabra
tam_total=`expr "$tam_total" : '\([0-9]*\)'`
tam_total=$(expr $tam_total \* 1024)
if [ "$tam_palabra" = "x86_64" ]; then
	tam_palabra="8"
else
	tam_palabra="4"
fi

# Calculamos el resto de datos

# Numero total de bloques (lineas)
total_bloques=$(expr $tam_total / $tam_bloque)
# Tamaño del conjunto en Bytes
tam_conjunto=$(expr $tam_total / $num_conjuntos)
# Numero de bloques en cada conjunto
bloques_conjunto=$(expr $tam_conjunto / $tam_bloque)
# Numero de conjuntos en cada via
conjuntos_via=$(expr $num_conjuntos / $num_vias)
# Numero de bloques en cada via
bloques_via=$(expr $bloques_conjunto \* $conjuntos_via)
# Palabras por bloque
palabras_bloque=$(expr $tam_bloque / $tam_palabra)

# Mostramos la informacion
clear
echo "Caché de datos L"$1
echo
echo "Tamaño total: \t\t" $(expr $tam_total / 1024) "KB ("$tam_total "Bytes)"
echo "Tamaño de palabra: \t" $(expr $tam_palabra \* 8) "bits ("$tam_palabra "Bytes)"
echo "Número de conjuntos: \t" $num_conjuntos "conjuntos"
echo "Número de vías: \t" $num_vias "vías"
echo "Tamaño de bloque: \t" $tam_bloque "Bytes"
echo
echo "Conjuntos por vía: \t" $conjuntos_via "Conjuntos/vía"
echo "Bloques por vía: \t" $bloques_via "Bloques/vía"
echo "Tamaño de conjunto: \t" $tam_conjunto "Bytes/conjunto"
echo "Total de bloques: \t" $total_bloques "bloques"
echo "Bloques por conjunto: \t" $bloques_conjunto "Bloques/conjunto"
echo "Palabras/bloque: \t" $palabras_bloque "Palabras/bloque"
echo
echo "C: "$num_conjuntos
echo "L: "$bloques_conjunto
echo "W: "$palabras_bloque
