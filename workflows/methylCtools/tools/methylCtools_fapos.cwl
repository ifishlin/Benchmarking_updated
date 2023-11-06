#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["methylCtools", "fapos"]
arguments:
  - valueFrom: "-"
    position: 2
  - valueFrom: "|"
    position: 3
    shellQuote: false
  - valueFrom: bgzip
    position: 4
  - valueFrom: ">"
    position: 5
  - valueFrom: $(inputs.ref.nameroot).pos.gz
    position: 6

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

outputs: 
  gz:
    type: File
    outputBinding:
      glob: $(inputs.ref.nameroot).pos.gz
