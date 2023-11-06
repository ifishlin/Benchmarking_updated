cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bsbolt", "Align"]

requirements:
  DockerRequirement:
    dockerPull: ifishlin324/bsbolt_1.4.8
  InlineJavascriptRequirement: {}

inputs:
  - id: read1
    type: File
    inputBinding:
      position: 4
      prefix: -F1
  - id: read2
    type: File
    inputBinding:
      position: 5
      prefix: -F2
  - id: DB
    type: Directory
    inputBinding:
      position: 3
      prefix: -DB
  - id: threads
    type: int
    inputBinding:
      prefix: -t
      position: 2
  - id: output_name
    type: string
    inputBinding:
      prefix: -O
      position: 1
      valueFrom: $(inputs.output_name)

  - id: pbat
    type: boolean
    inputBinding:
      prefix: "-UN"
      position: 1

outputs: 
  bam:
    type: File
    outputBinding:
      glob: "*.bam"
