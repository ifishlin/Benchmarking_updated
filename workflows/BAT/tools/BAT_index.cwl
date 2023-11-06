cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["segemehl.x"] 
arguments:
  - valueFrom: $(inputs.ref.nameroot).ctidx
    position: 1
    prefix: "-x"
  - valueFrom: $(inputs.ref.nameroot).gaidx
    position: 2
    prefix: "-y"
  - valueFrom: "1"
    position: 4
    prefix: "-F"

requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  DockerRequirement:
    dockerPull: ifishlin324/bat

stdout: stderr
stderr: $(inputs.ref.nameroot + ".bat.idx.log")

inputs: 
  - id: ref
    type: File
    inputBinding:
      position: 3
      prefix: "-d"

outputs: 
  ctidx:
    type: File
    outputBinding:
      glob: $(inputs.ref.nameroot).ctidx
  gaidx:
    type: File
    outputBinding:
      glob: $(inputs.ref.nameroot).gaidx
  log:
    type: stderr

