del/S/Q _rst
if not exist _rst mkdir _rst
cd _rst
call saxon -s:"..\CDI-Workflow description EOSC Future_v5.xml" -xsl:"..\DDI-CDI_process.xslt" -o:"index.rst" "DDI33_Study=EOSC_study_xml_v3_validated.xml" "PortalPrefix=https://ess-search.nsd.no/en/variable/"
cd ..