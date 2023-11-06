cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["deduplicate_bismark"]
arguments:
  - valueFrom: -s
  - valueFrom: --bam

requirements:
  DockerRequirement:
    dockerPull: kerstenbreuer/bismark:0.22.3 
  InlineJavascriptRequirement: {}

inputs:
  - id: bam
    type: File
    inputBinding:
      position: 1

outputs: 
  bam:
    type: File
    outputBinding:
      glob: "*.bam"
