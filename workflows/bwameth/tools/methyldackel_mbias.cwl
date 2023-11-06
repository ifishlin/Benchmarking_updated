#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["MethylDackel", "mbias"]

requirements:
  DockerRequirement:
    dockerPull: nfcore/methylseq
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

stdout: stderr
stderr: $(inputs.output_name + ".mbias.log")

inputs:
  - id: ref
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - .fai
  - id: threads
    type: int
    inputBinding:
      prefix: -@
      position: 1
  - id: output_name
    type: string
    inputBinding:
      position: 4
      valueFrom: $(self)
  - id: bam
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .bai

outputs: 
  mbias:
     type: File
     outputBinding:
       glob: "*.log"
  svg:
     type: File[]
     outputBinding:
       glob: "*.svg"
