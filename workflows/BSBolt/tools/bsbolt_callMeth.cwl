#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bsbolt", "CallMethylation"]
arguments:
  - valueFrom: "1"
    prefix: -min
  - valueFrom: -CG
  - valueFrom: -BG

hints:
  DockerRequirement:
    dockerPull: ifishlin324/bsbolt_1.4.8
inputs:
  - id: threads
    type: int
    inputBinding:
      prefix: -t
      position: 2
  - id: bam
    type: File
    inputBinding:
       prefix: -I
    secondaryFiles:
       - .bai
  - id: DB
    type: Directory
    inputBinding:
      prefix: -DB
  - id: output_name
    type: string
    inputBinding:
      prefix: -O

outputs: 
  bggz:
    type: File
    outputBinding:
      glob: "*.bg.gz"
