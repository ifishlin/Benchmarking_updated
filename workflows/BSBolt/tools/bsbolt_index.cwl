cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bsbolt", "Index"]

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/bsbolt_1.4.8
  InlineJavascriptRequirement: {}

inputs:
  - id: ref
    type: File
    inputBinding:
      prefix: -G
      position: 2
  - id: output_name
    type: string
    inputBinding:
      prefix: -DB
      position: 1
      valueFrom: $(inputs.output_name)

outputs: 
  bam:
    type: Directory
    outputBinding:
      glob: $(inputs.output_name)
