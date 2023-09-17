# ddi-cdi_process2web #

ddi-cdi_process2web is a prototype tool for rendering (DDI-CDI)[ https://ddialliance.org/Specification/DDI-CDI/] Process XML files.
The focus is limited to elements related to [sequences](https://ddi-alliance.bitbucket.io/DDI-CDI/DDI-CDI_v1.0-rc1/field-level-documentation/DDICDILibrary/Classes/Process/Sequence.html).

The tool works in a two-step approach.

1. XSLT

An XSLT stylesheet creates [reStructuredText](https://docutils.sourceforge.io/rst.html)
and [Graphviz](https://graphviz.org/) dot files on the basis of a DDI-CDI XML file containing the process description.

2. Sphinx

The documentation generator [Sphinx](https://www.sphinx-doc.org/) converts the reStructuredText and dot files into an HTML website.

## Example Application

An [example application](https://eosc-provenance.sikt.no/) is available at the Science Project (SP) Climate Neutral and Smart Cities of EOSC Future.

## Disclaimer

The tool is a prototype developed to explore issues around the presentation of process information to researchers.
As such, only limited time and resources were available for its creation. It is not intended to be used as a production tool
in its current form, but to serve as an example for developers interested in these types of applications.
The current tool is intended for display on a PC screen, without consideration of mobile design or other possible scenarios
which might require support in a production tool. It does not cover all of the possible fields in the DDI-CDI model for describing processes,
but only the selection of fields used in the example for the EOSC Futures Science Project 9 "Climate Neutral and Smart Cities"
which focus on a process sequence.