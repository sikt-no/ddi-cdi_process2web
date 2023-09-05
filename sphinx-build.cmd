rmdir /q/s _build
sphinx-build.exe							^
  -b html									^
  -c sphinx									^
  -D html_logo="_static\ess_logo_2023-08-17 - image001.png"	^
  -D html_title="ESS Labs Process"			^
  _rst										^
  _build

rem   -D html_logo="_static\ess-logo-top.png"	^
