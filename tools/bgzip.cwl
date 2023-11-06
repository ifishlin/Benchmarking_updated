cwlVersion: v1.0
class: CommandLineTool
baseCommand: bgzip

requirements:
  DockerRequirement:
    dockerPull: lethalfang/tabix:1.2.1 
  InitialWorkDirRequirement:
    listing:
      - $(inputs.vcf)

inputs:
  - id: vcf
    type: File
    inputBinding:
      position: 1

outputs: 
  vcf.gz:
    type: File
    outputBinding:
       glob: "*.vcf.gz"
