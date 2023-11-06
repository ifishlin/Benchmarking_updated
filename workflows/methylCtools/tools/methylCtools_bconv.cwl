#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["methylCtools", "bconv"]
requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylctools 
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

arguments:
  - valueFrom: "-"
    position: 5
  - valueFrom: "|"
    position: 6
    shellQuote: false
  - valueFrom: samtools
    position: 7
  - valueFrom: sort
    position: 8
  - valueFrom: $(inputs.output_name).conv.bam
    position: 9
    prefix: "-o"

inputs:
  - id: bam
    type: File
    inputBinding:
      position: 1
  - id: output_name
    type: string
outputs:
  convbam:
    type: File
    outputBinding:
      glob: "*.conv.bam"
