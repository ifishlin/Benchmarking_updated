#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["MethylDackel", "extract"]
arguments:
  - valueFrom: "0"
    prefix: -q
  - valueFrom: "1"
    prefix: -p
  - valueFrom: "1"
    prefix: --minDepth

requirements:
  DockerRequirement:
    dockerPull: nfcore/methylseq
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  - id: ref
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .bwameth.c2t
      - .bwameth.c2t.amb
      - .bwameth.c2t.ann
      - .bwameth.c2t.bwt
      - .bwameth.c2t.pac
      - .bwameth.c2t.sa
      - .fai
  - id: threads
    type: int
    inputBinding:
      prefix: -t
      position: 1
  - id: output_name
    type: string
    inputBinding:
      prefix: "-o"
      position: 2
      valueFrom: $(self)
  - id: bam
    type: File
    inputBinding:
      position: 4
    secondaryFiles:
      - .bai

outputs: 
  call:
     type: File
     outputBinding:
       glob: "*.bedGraph"
