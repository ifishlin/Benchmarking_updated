#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["methylCtools", "faconv"]
arguments:
  - valueFrom: $(inputs.ref.nameroot).conv.fa
    position: 2


requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylctools
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  - id: ref
    type: File
    inputBinding:
      position: 1
  - id: output_name
    type: string

outputs: 
  convfa:
    type: File
    outputBinding:
      glob: $(inputs.ref.nameroot).conv.fa
