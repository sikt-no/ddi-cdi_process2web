del/S/Q _rst
rem rmdir/q/s _rst
rem mkdir _rst
cd _rst
rem call saxon -s:"..\CDI-Workflow description EOSC Future.xml" -xsl:"..\DDI-CDI_process.xslt" -o:"index.rst" "Name=SP9_Process"
rem DDI33_Study - source is https://colectica-ess-processing.nsd.no/item/int.esseric/71586b4f-ef66-4b90-aed7-e7e7ad7406ce/11/ddi-set
call saxon -s:"..\CDI-Workflow description EOSC Future_v3_validated.xml" -xsl:"..\DDI-CDI_process.xslt" -o:"index.rst" "DDI33_Study=EOSC_study_xml_v3_validated.xml"
rem call saxon -s:"..\CDI-Workflow description EOSC Future JW2.xml" -xsl:"..\DDI-CDI_process.xslt" -o:"index.rst" "Name=SP9_Process"
rem call saxon -s:"..\EOSC_process_review_v1_JW.xml" -xsl:"..\DDI-CDI_process.xslt" -o:"index.rst" "Name=SP9_Process"
cd ..