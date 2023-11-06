#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bwa", "index"]
arguments:
  - valueFrom: bwtsw
    position: 1
    prefix: -a


requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylctools
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.convfa)

inputs:
  - id: convfa
    type: File
    inputBinding:
      position: 2

outputs: 
  fa:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
    outputBinding:
      glob: $(inputs.convfa.basename)
