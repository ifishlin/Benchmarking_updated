cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bismark"]

requirements:
  DockerRequirement:
    dockerPull: kerstenbreuer/bismark:0.22.3 
  InlineJavascriptRequirement: {}

inputs:
  - id: read1
    type: File
    inputBinding:
      position: 4
  - id: DB
    type: Directory
    inputBinding:
      position: 3
  - id: threads
    type: int
    inputBinding:
      prefix: -p
      position: 2
  - id: pbat
    type: boolean
    inputBinding:
      prefix: "--pbat"
      position: 1

outputs: 
  bam:
    type: File
    outputBinding:
      glob: "*.bam"
