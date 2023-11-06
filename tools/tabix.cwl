cwlVersion: v1.0
class: CommandLineTool
baseCommand: tabix
arguments:
  - valueFrom: vcf
    prefix: -p
    position: 1

requirements:
  DockerRequirement:
    dockerPull: lethalfang/tabix:1.2.1 
  InitialWorkDirRequirement:
    listing:
      - $(inputs.vcfgz)
  InlineJavascriptRequirement: {}

inputs:
  - id: vcfgz
    type: File
    inputBinding:
      position: 2

outputs: 
  vcfgztbi:
    type: File
    secondaryFiles: 
      - .tbi
    outputBinding:
      glob: $(inputs.vcfgz.basename)
