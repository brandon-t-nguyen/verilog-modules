BINDIR = bin
SRCDIR = src
TESTDIR = test

TESTSRCS = $(shell find $(TESTDIR) -name 'test_*.sv')
BINS = $(TESTSRCS:$(TESTDIR)/test_%.sv=$(BINDIR)/test_%.iv)

$(BINDIR):
	mkdir -p $(BINDIR)

$(BINS): $(BINDIR)/test_%.iv : $(SRCDIR)/%.sv $(TESTDIR)/test_%.sv $(BINDIR)
	iverilog -g2005-sv -I$(TESTDIR)/inc -o $@ $^

test-% : $(BINDIR)/test_%.iv
	./$<

clean:
	rm -rf $(BINDIR)
	rm -f *.vcd

.PHONY: clean
