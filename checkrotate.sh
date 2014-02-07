#!/bin/bash
#Comprobar la ultima fecha de rotacion de los logs indicados en rotaciones.txt

#Contador
n=1
#Fecha actual en formato logrotate-friendly
#Si los dias/meses son de un digito logrotate no añade el cero inicial
#Pero date si lo hace, asi que hay que adaptarlo
hoy=$(date +%Y-%m-%d | sed 's/-0/-/g')
ficheros=$(cat rotaciones.txt)
for fichero in $ficheros
do
        #Obtenemos la fecha de la ultima rotacion del fichero actual
        #Para evitar posibles coincidencias multiples hacemos el grep con -m 1
        ultimaRotacionFichero=$(cat /var/lib/logrotate/status | grep -m 1 $fichero | awk '{ print $NF }')
        n=1
        #Si el fichero se ha rotado hoy, todo va bien
        if [ "$ultimaRotacionFichero" == "$hoy" ]
                then
                        echo "[OK] Fichero $fichero rotado hoy"
                #Pero si no empezamos a iterar para ver desde cuando no se actualiza
                else
                        haceEneDias=$(date +%Y-%m-%d --date="$n days ago" | sed 's/-0/-/g')
                        while [ "$ultimaRotacionFichero" != "$haceEneDias" ]
                                do
                                        let n=n+1
                                        haceEneDias=$(date +%Y-%m-%d --date="$n days ago" | sed 's/-0/-/g')
                                done
                        echo "[WARNING] Fichero $fichero rotado por ultima vez hace $n dias"
        fi
done
