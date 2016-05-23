// 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
// 〈程式檔名〉 - 〈程式描述文字（一言以蔽之）〉
// 〈程式智慧財產權擁有者名諱、地址（選用）〉 © 〈智慧財產權生效年〉

//時脈產生器半週期
//`define CLOCK_PERIOD_HALF 10

module module_name_testbench();
//宣告port類型
  //reg ;
  //wire ;

	//D.U.T. instantiation

  /* 時脈產生器
  always begin
    #`CLOCK_PERIOD_HALF Clk = !Clk;
	end
  */
  
  initial begin
		//初始化
		$dumpfile ("Simulation/module_name_testbench.vcd");
		$dumpvars;
		$display("\t\t時間\t");
		$monitor("%d\t", $time);

		//模擬
	end
endmodule