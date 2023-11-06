cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["biscuit", "vcf2bed"]
arguments:
  - valueFrom: cg
    position: 1
    prefix: -t

requirements:
  DockerRequirement:
    dockerPull: mgibio/biscuit

inputs:
  - id: vcfgz
    type: File
    inputBinding:
       position: 2
    secondaryFiles:
       - .tbi

stdout: $(inputs.vcfgz.nameroot).CG.bed

outputs: 
  bed:
    type: stdout

