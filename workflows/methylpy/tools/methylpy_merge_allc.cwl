#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["methylpy", "merge-allc"]
arguments:
  - valueFrom: "16"
    prefix: "--num-procs"
  - valueFrom: "True"
    prefix: "--compress-output"
  - valueFrom: "merged.tsv.gz"
    prefix: "--output-file"

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/methylpy
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.allc_files)

inputs: 
  - id: allc_files
    type: File[]
    inputBinding:
      position: 1
      prefix: "--allc-files"

outputs: 
   merge_allc:
     type: File
     outputBinding:
        glob: "merged.tsv.gz"
