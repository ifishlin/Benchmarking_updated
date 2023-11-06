#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bwa", "mem"]
arguments:
  - valueFrom: "-p"
  - valueFrom: "|"
    position: 6
    shellQuote: false
  - valueFrom: samtools
    position: 7
  - valueFrom: view
    position: 8
#  - prefix: "-@"
#    valueFrom: $(inputs.threads)
#    position: 9
  - valueFrom: "-Sb"
    position: 10
  - prefix: "-o"
    valueFrom: $(inputs.output_name).bam
    position: 11
  - valueFrom: "-"
    position: 12

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylctools
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

#stdout: stderr
#stderr: $(inputs.output_name + ".bwamethaln.log")

inputs:
  - id: ref_conv_fa
    type: File
    inputBinding:
      position: 2
      prefix: -M
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
  - id: read_conv_fq
    type: File
    inputBinding:
      position: 3
  - id: output_name
    type: string
  - id: threads
    type: int
outputs:
  bam:
    type: File
    outputBinding:
      glob: "*.bam"
#  log:
#    type: stderr
