ALGNAMES := Case Common Distribution GenerateParams
			
INCFILES := $(addsuffix .h, $(ALGNAMES))
OBJFILES := main.o $(addsuffix .o, $(ALGNAMES))

EXEFILE  := casexec

NVCCCMD  := nvcc
NVCCFLAG := -arch=sm_20
NVLDFLAG := -lnppi

world: $(EXEFILE)

$(EXEFILE): $(OBJFILES)
	$(NVCCCMD) $(OBJFILES) -o $(EXEFILE) $(NVLDFLAG)

$(OBJFILES): %.o:%.cu $(INCFILES)
	$(NVCCCMD) -g -G -c $(filter %.cu, $<) -o $@ $(NVCCFLAG)

clean:
	rm -rf $(OBJFILES) $(EXEFILE)
