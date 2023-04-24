`ifndef UTILS_SVH
`define UTILS_SVH

class Utils;
    extern task WaveformDump(string waveformName);
endclass

task Utils::WaveformDump(string waveformName);
    $fsdbDumpfile(waveformName);
    $fsdbDumpvars("+all");
endtask

`endif