#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["FAME"]
arguments:
  - valueFrom: $(inputs.ref.nameroot)_index
    position: 2
    prefix: "--store_index"

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/fame
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.ref)

inputs:
  - id: ref
    type: File
    inputBinding:
      position: 1
      prefix: "--genome"

outputs:
  genome:
    type: File
    secondaryFiles:
      - _strands
    outputBinding:
      glob: $(inputs.ref.nameroot)_index
