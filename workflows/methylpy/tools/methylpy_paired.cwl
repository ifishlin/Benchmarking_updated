#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["methylpy", "paired-end-pipeline"]
arguments:
  - valueFrom: "True"
    prefix: "--remove-clonal"
  - valueFrom: "False"
    prefix: "--trim-reads"
  - valueFrom: "--path-to-picard=/root"
  - valueFrom: $(inputs.ref_fasta.basename)_f
    prefix: "--forward-ref"
    position: 4
  - valueFrom: $(inputs.ref_fasta.basename)_r
    prefix: "--reverse-ref"
    position: 5

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylpy
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.ref_fasta)

#stdout: stderr
#stderr: $(inputs.output_name + ".bwamethaln.log")

inputs:
  - id: read1
    type: File[]
    inputBinding:
      position: 1
      prefix: "--read1-files"
  - id: read2
    type: File[]
    inputBinding:
      position: 2
      prefix: "--read2-files"
  - id: sample
    type: string
    inputBinding:
      position: 3
      prefix: "--sample"
      valueFrom: $(inputs.read1[0].basename)
  - id: ref_fasta
    type: File
    secondaryFiles:
      - _f.1.bt2
      - _f.2.bt2
      - _f.3.bt2
      - _f.4.bt2
      - _f.rev.1.bt2
      - _f.rev.2.bt2
      - _r.1.bt2
      - _r.2.bt2
      - _r.3.bt2
      - _r.4.bt2
      - _r.rev.1.bt2
      - _r.rev.2.bt2
    inputBinding: 
      position: 6
      prefix: "--ref-fasta"
  - id: pbat
    type: boolean
    inputBinding:
      position: 7
      prefix: "--pbat"
      valueFrom: ${if(inputs.pbat)return "True";else return "False"}

outputs: 
   tsvgz:
      type: File
      outputBinding: 
         glob: "*.tsv.gz"
   bam:
      type: File[]
      outputBinding:
         glob: "*.bam"
