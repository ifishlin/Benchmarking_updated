#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["python", "/root/TWGBS_read_pair_reconstruction.py"]
requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylctools
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

arguments:
  - valueFrom: "R1_OUT.fq.gz"
    position: 3
    prefix: "--R1_out"
  - valueFrom: "R2_OUT.fq.gz"
    position: 4
    prefix: "--R2_out"
  - valueFrom: "R1_unassigned.fq.gz"
    position: 5
    prefix: "--R1_unassigned"
  - valueFrom: "R2_unassigned.fq.gz"
    position: 6
    prefix: "--R2_unassigned"
  - valueFrom: "log"
    position: 7
    prefix: "--log"

inputs:
  - id: fastq1
    type: File
    inputBinding:
      position: 1
      prefix: "--R1_in"

  - id: fastq2
    type: File
    inputBinding:
      position: 2
      prefix: "--R2_in"

stdout: "read_pair_reconstruction.log"

outputs: 
  R1_OUT:
    type: File
    outputBinding:
      glob: "R1_OUT.fq.gz"
  R2_OUT:
    type: File
    outputBinding:
      glob: "R2_OUT.fq.gz"
  R1_unassigned:
    type: File
    outputBinding:
      glob: "R1_unassigned.fq.gz"
  R2_unassigned:
    type: File
    outputBinding:
      glob: "R2_unassigned.fq.gz"
  log:
    type: stdout
