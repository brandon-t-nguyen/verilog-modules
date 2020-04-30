BINDIR = bin
SRCDIR = src
TESTDIR = test

$(BINDIR):
	mkdir -p $(BINDIR)

$(BINDIR)/test_%.iv : $(SRCDIR)/%.sv $(TESTDIR)/test_%.sv
	iverilog -g2005-sv -I$(TESTDIR)/inc -o $@ $^

test-% : $(BINDIR)/test_%.iv
	./$<

clean:
	rm -rf $(BINDIR)
	rm -f *.vcd

.PHONY: clean
