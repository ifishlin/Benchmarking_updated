#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["tabix"]
arguments:
  - valueFrom: "1"
    prefix: -s
    position: 1
  - valueFrom: "2"
    prefix: -b
    position: 2
  - valueFrom: "2"
    prefix: -e
    position: 3

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylctools
  InitialWorkDirRequirement:
    listing:
      - $(inputs.posgz)
  InlineJavascriptRequirement: {}

inputs:
  - id: posgz
    type: File
    inputBinding:
      position: 4

outputs:
  posgztbi:
    type: File
    secondaryFiles:
      - .tbi
    outputBinding:
      glob: $(inputs.posgz.basename)

