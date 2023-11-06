#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["java"]
arguments:
  - valueFrom: SE
    position: 2
  - valueFrom: trimmed.fastq
    position: 4

requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
hints:
  DockerRequirement:
    dockerPull: dukegcb/trimmomatic:latest

inputs:
  - id: fastq
    type: File
    inputBinding:
      position: 3

  - id: path_to_trimmomatic
    doc: |
      default path matching the applied docker container;
      if the container is not used please adapt
    type: string
    default: "/usr/share/java/trimmomatic.jar"
    inputBinding:
      position: 1
      prefix: "-jar"

  - id: CROP
    type: int?
    inputBinding:
      position: 5
      prefix: "CROP:"
      separate: False

  - id: HEADCROP
    type: int?
    inputBinding:
      position: 6
      prefix: "HEADCROP:"
      separate: False

outputs: 
  trimmed.fq:
    type: File
    outputBinding:
      glob: "trimmed.fastq"
   
