MIXED sc_dACC BY Run Performance Instruction 
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE) 
  /FIXED= Performance Run*Performance | SSTYPE(3) 
  /METHOD=ML 
  /PRINT=DESCRIPTIVES  SOLUTION 
  /RANDOM=INTERCEPT | SUBJECT(Participant) COVTYPE(ID) 
  /EMMEANS=TABLES(Run*Performance) COMPARE(Performance) ADJ(BONFERRONI) .