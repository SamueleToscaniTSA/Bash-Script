#!/bin/bash

#made by Samuele Toscani TSA

#cercare ricorsivamente in ogni directory passata come argomento ogni file semplice che includa nel finale del nome una data stringa passata come f e nel contenuto una stringa passata come s

#stampare dei file trovati solo quelli con un numero di linee maggiori di un intero positivo l, se non passato il valore di l defualt è 10. stampare oltre al nome anche le dimensioni in byte e in linee del file

#se passato d, attivare una funzione di debug per salvare nella directory links i collegamenti ai file trovati. per evitare duplicati editare il nome come counter.basename

#se passato a, attivare una funzione aggiuntiva di stampa file su un file appoggio app interno alla directory links. stampare su file, sulla stessa riga, il nome base del file e la 10 riga, stampare poi la directory di appartenenza del file nella riga successiva e spaziare gli out put da una riga vuota


#----------------VAR----------------#
L=10
DEBUG=FALSE
FILEAPP=FALSE
LINKS=/home/sem/Scrivania/Bash/Script/Devel/my/links
APP=app

#----------------USAGE----------------#
usage()
{
  echo "usage: $0 [-h] [-l] lines [-d] debug [-a] appfile -f filename -s string  d1 .. dn"
  exit 1
}

#----------------CHECK CMD LINE----------------#
while getopts "f:s:l:dah" o; do
  case "$o" in
    f)
      F="$OPTARG"
      case "$F" in
        */*)
          usage
          ;;
        *)
          ;;
      esac
      ;;
    s)
      S="$OPTARG"
      ;; 
    l)
      L="$OPTARG"
      expr "$L" + 0 1>/dev/null 2>&1 || usage
      [ "$L" -le 0 ] && usage
      ;;
    d)
      DEBUG=TRUE
      ;;
    a)
      FILEAPP=TRUE
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

shift $(expr $OPTIND - 1)

#----------------CHECK ARGUMENT----------------#
[ "$#" -lt 1 ] && usage
[ -z "$F" ] && usage
[ -z "$S" ] && usage
for dir in $*; do
  case "$dir" in
    /*)
      ;;
    *)
      usage
      ;;
  esac
  [ ! -d "$dir" ] && usage
  [ ! -e "$dir" ] && usage
done

#----------------MAIN----------------#
if [ "$DEBUG" == "TRUE" ]; then
  rm -rf "$LINKS"
  mkdir -p "$LINKS"
fi

if [ "$FILEAPP" == "TRUE" ]; then
  rm -rf "$LINKS/$APP"
  touch "$LINKS/$APP"
fi

cntFiles=0
for dir in $*; do
  listDir=$(find "$dir" -type d -executable 2>/dev/null)
  for subDir in $listDir; do
    listFile=$(find "$subDir" -maxdepth 1 -type f -name "*$F" -readable 2>/dev/null)
    for file in $listFile; do
      grep "$S" "$file" 1>/dev/null 2>&1
      if [ "$?" -eq 0 ]; then
        l=$(cat "$file" | wc -l)
        if [ "$l" -gt "$L" ]; then
          c=$(cat "$file" | wc -c)
          echo "[c:$c] [l:$l] $file"
          if [ "$DEBUG" == "TRUE" ]; then
            ln -s "$file" "$LINKS/$cntFiles.$(basename $file)"
            cntFiles=$(expr "$cntFiles" + 1)
          fi
          if [ "$FILEAPP" == "TRUE" ]; then
            echo -n "[$(basename $file)]" >> "$LINKS/$APP"
            head "$file" | tail -1 >>"$LINKS/$APP"
            #echo "[$(dirname $file)]" >> "$LINKS/$APP"
            echo "[$subDir]" >> "$LINKS/$APP"
            echo "" >>"$LINKS/$APP"
          fi
        fi
      fi
    done
  done
done

exit 0
