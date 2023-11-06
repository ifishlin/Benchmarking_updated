cwlVersion: v1.0
class: Workflow

requirements:
 ScatterFeatureRequirement: {}
 SubworkflowFeatureRequirement: {}
 StepInputExpressionRequirement: {}
 InlineJavascriptRequirement: {}

inputs:
  - id: ref
    type: File
    secondaryFiles:
      - .fai
  - id: bam
    type: File
    secondaryFiles:
      - .bai
  - id: threads
    type: int
  - id: output_name
    type: string
  - id: header
    type: File

steps:
  callmethyl:
    run: "./BAT_callmethyl.cwl"
    in:
      ref: 
        source: ref
      bam: 
        source: bam
      threads: 
        source: threads
    out: [vcf]

  cat:
     run: "./BAT_cat.cwl"
     in:
       vcf: 
         source: callmethyl/vcf
       header:
         source: header
       output_name:
         source: output_name
     out: [vcf]

  bcftools:
    run: "./BAT_bcftools.cwl"
    in:
      vcf: 
        source: cat/vcf
    out: [vcfgz]

   
  tabix:
    run: "../../../tools/tabix.cwl"
    in:
      vcfgz:
       source: bcftools/vcfgz
    out: [vcfgztbi]

outputs:
  vcfgztbi:
    type: File
    outputSource: tabix/vcfgztbi  
