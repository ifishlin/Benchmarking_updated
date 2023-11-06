cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["java", "-Xmx64g","-jar", "/usr/local/BisSNP-1.0.1.jar", "-T", "BisulfiteGenotyper", "-vfn1", "cpg.raw.vcf", "-vfn2", "snp.raw.vcf", "--filter_reads_with_N_cigar"]
requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: ifishlin324/bissnp
  InitialWorkDirRequirement:
    listing:
      - $(inputs.bam)
      - $(inputs.ref)

stdout: stderr
stderr: $(inputs.output_name + ".bissnp.log")

inputs: 
  ref:
    type: File
    inputBinding:
      prefix: -R
      position: 1
    secondaryFiles:
      - ^.dict
      - .fai
  dbsnp:
    doc: dbSNP file
    type: File
    inputBinding:
      prefix: -D
      position: 2
  bam:
    type: File
    inputBinding:
      prefix: -I
      position: 3
    secondaryFiles:
      - .bai
  stand_call_conf:
    type: int
    inputBinding:
      prefix: -stand_call_conf
      position: 4
  threads:
    type: int
    inputBinding:
      prefix: -nt
      position: 5
  output_name:
    type: string

## OUTPUT PART
outputs: 
  cpg_vcf:
    type: File
    outputBinding:
      glob: cpg.raw.vcf
  snp_vcf:
    type: File
    outputBinding:
      glob: snp.raw.vcf
  log:
    type: stderr
