/***********
 * Testbench macros
 ***********/

`ifndef __TEST_DEFS_VH__
`define __TEST_DEFS_VH__

// Initialize testbench variables
`define T_VARS\
    integer test_num = 0;\
    string  test_name;\
    logic   test_alive;\
    logic   test_pass;\
    string  test_s;\
    string  test_s_temp;\
    logic   tests_pass = 1;

// Initialize a single test of a given name
`define T_TEST(name)\
    test_name  = name;\
    test_num   = test_num + 1;\
    test_pass  = 1;\
    test_alive = 1;

// "Test Expect": non-fatal check
`define T_EXPECT(prop, str)\
    if (test_alive && !(prop)) begin\
        test_pass = 0;\
        tests_pass = 0;\
        $display("@@@[%0d:%s] %s (t=%0d)", test_num, test_name, str, $time);\
    end

// "Test Assert": fatal check
`define T_ASSERT(prop, str)\
    if (test_alive && !(prop)) begin\
        test_pass  = 0;\
        tests_pass = 0;\
        test_alive = 0;\
        $display("@@@[%0d:%s] %s (t=%0d) [FATAL]", test_num, test_name, str, $time);\
    end

// Format string version
// str is actually parenthesized format string e.g. ("%d",some_var)
`define T_EXPECT_F(prop, str)\
    begin\
        test_s = $sformatf``str;\
        `T_EXPECT(prop, test_s);\
    end

// Format string version
// str is actually parenthesized format string e.g. ("%d",some_var)
`define T_ASSERT_F(prop, str)\
    begin\
        test_s = $sformatf``str;\
        `T_ASSERT(prop, test_s);\
    end

// "Test Expect Equals": wrapper for equality checking
// actual, expected
// format is the string formatting you want to use (e.g. %0d, %08h etc)
`define T_EXPECT_EQ(act, exp, format)\
    begin\
        test_s_temp = $sformatf("%s = %s, expected %s", `"act`", format, format);\
        test_s = $sformatf(test_s_temp, act, exp);\
        `T_EXPECT((act === exp), test_s);\
    end

`define T_ASSERT_EQ(act, exp, format)\
    begin\
        test_s_temp = $sformatf("%s = %s, expected %s", `"act`", format, format);\
        test_s = $sformatf(test_s_temp, act, exp);\
        `T_ASSERT((act === exp), test_s);\
    end

`define T_FINISH\
    $display("@@@%s", tests_pass ? "PASS" : "FAIL");\
    $finish();

`endif// __TEST_DEFS_VH__
