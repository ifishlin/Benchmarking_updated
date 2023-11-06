cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["biscuit", "index"]

requirements:
  DockerRequirement:
    dockerPull: mgibio/biscuit
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.ref)

stdout: stderr
stderr: $(inputs.ref.nameroot + ".biscuit.index.log")

inputs:
  - id: ref
    type: File
    inputBinding:
      position: 1 
outputs:
  bam:
    type: File
    secondaryFiles: 
      - .bis.amb
      - .bis.ann
      - .bis.pac
      - .dau.bwt
      - .dau.sa
      - .par.bwt
      - .par.sa
    outputBinding:
      glob: "*.fa"
  log:
    type: stderr
