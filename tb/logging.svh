//------------------------------------------------------------------------------
// logging.svh
// Icarus-Verilog compatible logging utilities
//------------------------------------------------------------------------------

// Logging levels
`define LOGLEVEL_OFF     0
`define LOGLEVEL_ERROR   1
`define LOGLEVEL_WARNING 2
`define LOGLEVEL_INFO    3
`define LOGLEVEL_DEBUG   4

// Default log level (can be overridden with -DLOG_LEVEL=LEVEL)
`ifndef LOG_LEVEL
`define LOG_LEVEL `LOGLEVEL_INFO
`endif

// ANSI color codes
`define COLOR_RESET  "\033[0m"
`define COLOR_RED    "\033[91m"
`define COLOR_YELLOW "\033[93m"
`define COLOR_GREEN  "\033[92m"
`define COLOR_CYAN   "\033[96m"

//------------------------------------------------------------------------------
// Logging macros
//------------------------------------------------------------------------------

`ifdef SIMULATION
`define LOG_MSG(color, label, msg) \
        $display("%s[%0t][%-5s][%-30m] %s%s", color, $time, label, msg, `COLOR_RESET)
`else
`define LOG_MSG(color, label, msg)
`endif

`define LOG_DEBUG(msg) \
    if (`LOG_LEVEL >= `LOGLEVEL_DEBUG) \
        `LOG_MSG(`COLOR_CYAN, "DEBUG", msg)

`define LOG_INFO(msg) \
    if (`LOG_LEVEL >= `LOGLEVEL_INFO) \
        `LOG_MSG(`COLOR_GREEN, "INFO ", msg)

`define LOG_WARNING(msg) \
    if (`LOG_LEVEL >= `LOGLEVEL_WARNING) \
        `LOG_MSG(`COLOR_YELLOW, "WARN ", msg)

`define LOG_ERROR(msg) \
    if (`LOG_LEVEL >= `LOGLEVEL_ERROR) \
        `LOG_MSG(`COLOR_RED, "ERROR", msg)
