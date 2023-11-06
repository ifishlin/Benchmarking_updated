#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: []
arguments:
  - valueFrom: "|"
    position: 6
    shellQuote: false
  - valueFrom: samtools
    position: 7
  - valueFrom: sort
    position: 8
  - prefix: "-@"
    valueFrom: $(inputs.threads)
    position: 9
  - prefix: "-o"
    valueFrom: $(inputs.output_name).bam
    position: 10
  - valueFrom: "-"
    position: 11

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/bwameth
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

stdout: stderr
stderr: $(inputs.output_name + ".bwamethaln.log")

inputs:
  - id: read1
    type: File
    inputBinding:
      position: 4
  - id: read2
    type: File
    inputBinding:
      position: 5
  - id: ref
    type: File
    inputBinding:
      position: 3
      prefix: --reference
    secondaryFiles:
      - .bwameth.c2t
      - .bwameth.c2t.amb
      - .bwameth.c2t.ann
      - .bwameth.c2t.bwt
      - .bwameth.c2t.pac
      - .bwameth.c2t.sa
  - id: threads
    type: int
    inputBinding:
      prefix: -t
      position: 2
  - id: output_name
    type: string
  - id: pbat
    type: boolean
    inputBinding:
      position: 1
      valueFrom: ${if(inputs.pbat) return "bwameth_pbat.py" ;else return "bwameth.py"}

outputs:
  bam:
    type: File
    outputBinding:
      glob: "*.bam"
  log:
    type: stderr
