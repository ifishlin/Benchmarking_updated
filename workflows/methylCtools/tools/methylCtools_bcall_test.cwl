#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["methylCtools"]
requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylctools 
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

arguments:
  - valueFrom: ${if(inputs.twgbs) return "bcall_tag"; else return "bcall"}
    position: 1
  - valueFrom: "-"
    position: 5
  - valueFrom: "|"
    position: 6
    shellQuote: false
  - valueFrom: bgzip
    position: 7
  - valueFrom: ">"
    position: 8
  - valueFrom: $(inputs.output_name).call.gz
    position: 9

inputs:
  - id: bam
    type: File
    inputBinding:
      position: 2
  - id: ref_pos
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .tbi
  - id: output_name
    type: string
  - id: twgbs
    type: boolean

outputs:
  callgz:
    type: File
    outputBinding:
      glob: "*.call.gz"
