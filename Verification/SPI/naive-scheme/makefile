DESIGN_NAME = "tb_SPI"
LOG_VCS     = "vcs.log"
LOG_SIMV    = "simv.log"
FILE_LIST   = "./list.f"
UVM_HOME    = "/data1/share/uvm-1.1d"

# Code Coverage
CM      = -cm line+cond+tgl+fsm+branch+assert
CM_DIR  = -cm_dir cvrg

# Makefile body
.PHONY: env vcs uvm simv uvms verdi urg clean cleanall sim

env : 
	@echo "Design Name: $(DESIGN_NAME)"
	@echo "Log File   : $(LOG_VCS)"
	@echo "Log File   : $(LOG_SIMV)"
	@echo "File List  : $(FILE_LIST)"

	export UVM_HOME=$(UVM_HOME)

# find . -name "*.v"  > list.f
vcs : env
	vcs -nc -j32 -full64 -sverilog -debug_access+all \
		-l $(LOG_VCS) -f $(FILE_LIST) $(CM) $(CM_DIR)

uvm : env
	vcs -nc -j32 -full64 -sverilog -debug_access+all -timescale=1ns/1ps \
		+acc +vpi +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
		+incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv \
		$(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
		-l $(LOG_VCS) -f $(FILE_LIST) $(CM) $(CM_DIR)

simv : env vcs
	./simv -nc +COMPARE +fsdb+parallel \
		   -l $(LOG_SIMV) $(CM) $(CM_DIR)

uvms : env uvm
	./simv -nc +COMPARE +fsdb+parallel \
		   -l $(LOG_SIMV) $(CM) $(CM_DIR)

verdi :
	verdi $(DESIGN_NAME).fsdb

urg :
	verdi -full64 -cov -covdir ./cvrg.vdb

clean :
	rm -rf simv ucli.key novas.* *.log
	rm -rf csrc simv.daidir verdiLog cvrg.vdb vdCovLog

cleanall : clean
	rm -rf *_Golden*.txt *_DUT.txt

sim : cleanall simv verdi