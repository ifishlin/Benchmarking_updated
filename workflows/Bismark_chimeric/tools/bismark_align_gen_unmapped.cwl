cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["bismark"]
arguments:
  - valueFrom: --bam
  - valueFrom: --gzip
  - valueFrom: --unmapped

requirements:
  DockerRequirement:
    dockerPull: kerstenbreuer/bismark:0.22.3 
  InlineJavascriptRequirement: {}

inputs:
  - id: read1
    type: File
    inputBinding:
      position: 3
      prefix: "-1"
  - id: read2
    type: File
    inputBinding:
      position: 4
      prefix: "-2"
  - id: DB
    type: Directory
    inputBinding:
      position: 2
  - id: threads
    type: int
    inputBinding:
      prefix: -p
      position: 1

outputs: 
  bam:
    type: File
    outputBinding:
      glob: "*.bam"
  unmapped_r1:
    type: File
    outputBinding:
      glob: "*unmapped_reads_1.fq.gz"
  unmapped_r2:
    type: File
    outputBinding:
      glob: "*unmapped_reads_2.fq.gz"
