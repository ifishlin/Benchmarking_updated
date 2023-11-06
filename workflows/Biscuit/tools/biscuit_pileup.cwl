cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["biscuit", "pileup"]
arguments:
  - valueFrom: $(inputs.output_name).vcf
    position: 1
    prefix: -o

requirements:
  DockerRequirement:
    dockerPull: mgibio/biscuit

inputs:
  - id: output_name
    type: string
  - id: ref
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - .fai
  - id: bam_sorted
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .bai

outputs: 
  vcf:
    type: File
    outputBinding:
      glob: "*.vcf"

