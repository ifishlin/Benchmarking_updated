#!/bin/bash

declare -A mydict=(
  ["gembs"]="gemBS"
)

exec_array=("WGBS" "EMSEQ" "SWIFT" "TWGBS")

for yml_file in $(find . -name "*.yml"|sort); do
 
  filename=$(basename -- "$yml_file")
  extension="${filename##*.}"
  filename="${filename%.*}"

  IFS='_' read -r -a array <<< "$filename"
  echo $yml_file
  workflow=${array[0]}
  workflow_formal=${mydict["$workflow"]}
  echo $workflow
  echo $workflow_formal
  sub=${array[1]}
  method=${array[2]}
  echo $method
  sample=${array[3]}
  #outdir="/data/auto/results/$workflow_formal/$method/$sample"
  #cwldir="/data/auto/Benchmarking_CWL/workflows/$workflow_formal"
  outdir="./"$method"/"$sample
  cwl=$workflow"_"$sub".cwl"

  found=0
  for element in "${exec_array[@]}"
  do
    if [[ "$element" == "$method" ]]; then
      found=1
      break
    fi
  done


  if [[ -f outdir ]]; then
      echo "$outdir exist" 
  else
      mkdir -p $outdir
      touch $outdir/start
      echo "cwltool --outdir $outdir ./gembs.cwl $yml_file > $outdir/cwl.log 2>&1"
      cwltool --outdir $outdir ./gembs.cwl $yml_file > $outdir/cwl.log 2>&1
      touch $outdir/done
  fi
done
