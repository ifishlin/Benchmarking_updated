#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["methylCtools", "fqconv"]
arguments:
  - valueFrom: "reads.conv.fq"
    position: 5
requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylctools 

#stdout: stderr
#stderr: $(inputs.output_name + ".bwamethaln.log")

inputs:
  - id: read1
    type: File
    inputBinding:
      position: 3
      prefix: "-1"
  - id: read2
    type: File
    inputBinding:
      position: 4
      prefix: "-2"
  - id: output_name
    type: string
outputs:
  convfq:
    type: File
    outputBinding:
      glob: "*.conv.fq"
