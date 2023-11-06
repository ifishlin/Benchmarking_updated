#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bwameth.py", "index"]

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/bwameth
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.ref)

stdout: stderr
stderr: $(inputs.ref.nameroot + ".bwameth.index.log")

inputs:
  - id: ref
    type: File
    inputBinding:
      position: 1

outputs:
  bam:
    type: File
    secondaryFiles:
      - .bwameth.c2t
      - .bwameth.c2t.amb
      - .bwameth.c2t.ann
      - .bwameth.c2t.bwt
      - .bwameth.c2t.pac
      - .bwameth.c2t.sa
    outputBinding:
      glob: "*.fa"
  log:
    type: stderr
