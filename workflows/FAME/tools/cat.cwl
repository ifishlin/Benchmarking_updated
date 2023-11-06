#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["cat"]
arguments:
  - valueFrom: ">"
    position: 2
    shellQuote: false
  - valueFrom: merged.$(inputs.output_name).fastq.gz
    position: 3


requirements:
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  - id: read1
    type: File[]
    inputBinding:
      position: 1
  - id: output_name
    type: string

outputs: 
  merged_fastq:
    type: File
    outputBinding:
       glob: merged.$(inputs.output_name).fastq.gz
