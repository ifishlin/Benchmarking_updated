cwlVersion: v1.0
class: Workflow

requirements:
 ScatterFeatureRequirement: {}
 SubworkflowFeatureRequirement: {}
 StepInputExpressionRequirement: {}
 InlineJavascriptRequirement: {}

inputs:
  ref:
    type: File

steps:
  gsnap_build:
    run: "./gsnap_build.cwl"
    in:
       ref:
         source: ref
    out:
       - genome_dir


  gsnap_cmetindex:
    run: "./gsnap_cmetindex.cwl"
    in:
       ref_dir:
         source: gsnap_build/genome_dir
    out:
       - cmet_dir

outputs: 
  cmet_dir:
    type: Directory
    outputSource: gsnap_cmetindex/cmet_dir

