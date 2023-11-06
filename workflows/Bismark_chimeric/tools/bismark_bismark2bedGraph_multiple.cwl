cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bismark2bedGraph"]

requirements:
  DockerRequirement:
    dockerPull: kerstenbreuer/bismark:0.22.3 
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - $(inputs.mapped)
      - $(inputs.unmapped_r1)
      - $(inputs.unmapped_r2)

inputs:
  - id: mapped
    type: File[]
    inputBinding:
      position: 2
  - id: unmapped_r1
    type: File[]
    inputBinding: 
      position: 3
  - id: unmapped_r2
    type: File[]
    inputBinding:
      position: 4
  - id: output_name
    type: string
    inputBinding:
      position: 1
      prefix: -o

outputs: 
  gz:
    type: File[]
    outputBinding:
      glob: "*.gz"
