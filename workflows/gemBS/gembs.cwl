#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["run_gembs.sh"] 
requirements:
  DockerRequirement:
    dockerPull: ifishlin324/gembs 
      # ./docker_ext/gemBS_main
    dockerOutputDirectory: /opt
  InitialWorkDirRequirement:
    listing:
      - $(inputs.fastq)
      - $(inputs.ref)
      - $(inputs.conf)
      - $(inputs.csv)

inputs: 
  conf:
    type: File
    doc: "Configuration (please refer to the gemBS docs)."
    inputBinding:
      position: 1
  csv:
    type: File
    doc: "List of input datasets (please refer to the gemBS docs)."
    inputBinding:
      position: 2
  ref:
    type: Directory  
    doc: "Directory of reference (please refer to the gemBS docs)."
  fastq:
    type: Directory  
    doc: "Directory of FASTQ Files (please refer to the gemBS docs)."
outputs:           
  report:
    type:
      type: array
      items: Directory
    outputBinding:
      glob: "report"
  indexes:
    type:
      type: array
      items: Directory
    outputBinding:
      glob: "indexes"
  mapping:
    type:
      type: array
      items: Directory
    outputBinding:
      glob: "mapping"         
  calls:
    type:
      type: array
      items: Directory
    outputBinding:
      glob: "calls" 
  exract:
    type:
      type: array
      items: Directory
    outputBinding:
      glob: "extract"                       
