onbreak resume
onerror resume
vsim -voptargs=+acc work.filter_tb
add wave sim:/filter_tb/u_filter_cx_2/clk
add wave sim:/filter_tb/u_filter_cx_2/clk_enable
add wave sim:/filter_tb/u_filter_cx_2/reset
add wave sim:/filter_tb/u_filter_cx_2/filter_in
add wave sim:/filter_tb/u_filter_cx_2/filter_out
add wave sim:/filter_tb/filter_out_ref
run -all
